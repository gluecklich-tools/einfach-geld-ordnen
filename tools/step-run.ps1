#requires -Version 7.0
param(
  [string]$StepPath
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

function Resolve-RepoRoot {
  $t = (git rev-parse --show-toplevel 2>$null)
  if([string]::IsNullOrWhiteSpace($t)){ Fail "RepoRoot not found (git rev-parse failed)." }
  (Resolve-Path -LiteralPath $t).Path
}

# P0: Never prompt. Missing/empty StepPath must hard-fail.
if(-not $PSBoundParameters.ContainsKey("StepPath") -or [string]::IsNullOrWhiteSpace($StepPath)){
  Fail "STEPFILE_REQUIRED: -StepPath must be provided (no prompting)."
}

$RepoRoot = Resolve-RepoRoot

# Gate: block unsafe $var: patterns in the step file (double-quoted strings)
& (Join-Path $PSScriptRoot "gate-step-no-invalid-var-colon.ps1") -StepPath $StepPath

# Resolve step path
$sp = $StepPath
try { $sp = (Resolve-Path -LiteralPath $StepPath).Path } catch { Fail "STOP: StepPath not found: $StepPath" }

# Enterprise: repo must be clean before step (ignoring _local)
function Get-ChangedPathsFromPorcelain([string[]]$lines){
  $out = @()
  foreach($ln in @($lines)){
    if(-not $ln){ continue }
    if($ln.Length -ge 4){
      $p = $ln.Substring(3).Trim()
      if($p){
        $p = $p -replace "\\","/"
        if($p -notlike "_local/*"){ $out += $p }
      }
    }
  }
  return $out
}

$preLines = @((git status --porcelain=v1))
$preChanged = Get-ChangedPathsFromPorcelain $preLines
if(@($preChanged).Count -gt 0){
  Fail ("REPO_DIRTY_BEFORE_STEP: make repo clean before running steps.`n" + ($preChanged -join "`n"))
}

# Run step
& $sp
$code = $LASTEXITCODE
if($code -ne 0){
  Fail "STOP: step failed (exit=$code) Step=$sp"
}

# Enforce STEP_WRITE_ALLOWLIST (post must still be clean OR only allowlisted by step)
$postLines = @((git status --porcelain=v1))
$postChanged = Get-ChangedPathsFromPorcelain $postLines

if(@($postChanged).Count -gt 0){
  $gate = Join-Path $RepoRoot "tools\gate-step-write-allowlist.ps1"
  if(-not (Test-Path -LiteralPath $gate)){
    Fail "FAIL: missing gate-step-write-allowlist.ps1 (expected at tools\gate-step-write-allowlist.ps1)"
  }
  pwsh -NoProfile -ExecutionPolicy Bypass -File $gate -RepoRoot $RepoRoot -StepPath $sp -ChangedPaths $postChanged
}

"PASS: step-run"
exit 0