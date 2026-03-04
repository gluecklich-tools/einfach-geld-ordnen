#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$StepPath
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }


# P0_STEP_PARSER_GATE
function Assert-StepParses([string]$Path){
  if(-not (Test-Path -LiteralPath $Path -PathType Leaf)){ Fail ("FAIL: StepPath not found: {0}" -f $Path) }
  $s = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  $t = $null
  $e = $null
  [void][System.Management.Automation.Language.Parser]::ParseInput($s,[ref]$t,[ref]$e)
  if($null -ne $e -and $e.Count -gt 0){
    $first = $e[0]
    $line = $first.Extent.StartLineNumber
    $col  = $first.Extent.StartColumnNumber
    Fail ("P0_STEP_PARSER_GATE: ParserError in step: {0} (line {1}, col {2}): {3}" -f $Path,$line,$col,$first.Message)
  }
}
# Resolve repo root
$RepoRoot=$null
try{ $t=(git rev-parse --show-toplevel 2>$null); if($t){ $RepoRoot=(Resolve-Path -LiteralPath $t).Path } }catch{}
if(-not $RepoRoot){ Fail "FAIL: RepoRoot could not be determined via git." }

# Resolve step path
$sp = $StepPath
try{ $sp = (Resolve-Path -LiteralPath $sp).Path }catch{ Fail "FAIL: StepPath not found: $StepPath" }
if(-not (Test-Path -LiteralPath $sp -PathType Leaf)){ Fail "FAIL: StepPath not a file: $sp" }

# Read step text once (never null)
$stepText = Get-Content -LiteralPath $sp -Raw -Encoding UTF8
if([string]::IsNullOrWhiteSpace($stepText)){ Fail "FAIL: Step file is empty or unreadable: $sp" }

# Enforce allowlist literal presence (P0)
$rx = [regex]::new('\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\(', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if(-not $rx.IsMatch($stepText)){
  Fail "FAIL: step missing `$EGO_STEP_WRITE_ALLOWLIST = @(...)."
}

# Run step via step-run (file-first, no inline)
$runner = Join-Path $RepoRoot "tools\step-run.ps1"
if(-not (Test-Path -LiteralPath $runner -PathType Leaf)){ Fail "FAIL: Missing runner: $runner" }

Assert-StepParses -Path $sp
# P0_KNOWN_FAILURES_GATESET
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\gatesets\p0-known-failures.ps1")
& pwsh -NoProfile -ExecutionPolicy Bypass -File $runner -StepPath $sp
$ec = $LASTEXITCODE
if($ec -ne 0){ Fail "STOP: step-run failed (exit=$ec)" }

"PASS: step-run"