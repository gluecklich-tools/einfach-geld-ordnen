param(
  [Parameter(Mandatory=$true)][string]$StepPath
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

function Read-AllowlistFromStepText([Parameter(Mandatory=$true)][string]$Text){
  if([string]::IsNullOrWhiteSpace($Text)){ return @() }

  $t = $Text -replace "`r`n","`n" -replace "`r","`n"

  # Match allowlist assignment; allow whitespace/newlines inside @(...)
  $m = [regex]::Match($t, '(?ms)^\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\((?<inner>.*?)\)\s*$', [Text.RegularExpressions.RegexOptions]::None)
  if(-not $m.Success){ return @() }

  $inner = $m.Groups['inner'].Value
  $vals = @()

  foreach($mm in [regex]::Matches($inner, '''([^'']*)''', [Text.RegularExpressions.RegexOptions]::None)){
    $v = $mm.Groups[1].Value
    if($v){ $vals += $v }
  }
  foreach($mm in [regex]::Matches($inner, '"([^"]*)"', [Text.RegularExpressions.RegexOptions]::None)){
    $v = $mm.Groups[1].Value
    if($v){ $vals += $v }
  }

  return @($vals)
}

function Get-RepoRoot {
  $p = (& git rev-parse --show-toplevel 2>$null)
  if (-not $p) { Fail "RepoRoot konnte nicht bestimmt werden (git rev-parse)." }
  return (Resolve-Path -LiteralPath $p).Path
}
$RepoRoot = Get-RepoRoot
$StepFull = (Resolve-Path -LiteralPath $StepPath).Path
if (-not (Test-Path -LiteralPath $StepFull)) { Fail "Step not found: $StepFull" }

# Gate: Tools parse (existing scripts call this upstream; keep local minimal)
# Gate: Step Allowlist MUST exist (read from file, not from session scope)

$txt = Get-Content -LiteralPath $StepFull -Raw
$allow = Read-AllowlistFromStepText $txt
if (-not $allow) { Fail "FAIL: step missing `$EGO_STEP_WRITE_ALLOWLIST = @(...)." }

# Execute step
& pwsh -NoProfile -ExecutionPolicy Bypass -File $StepFull
if ($LASTEXITCODE -ne 0) { Fail "STOP: step-run failed (exit=$LASTEXITCODE)" }

"PASS: step-run"
