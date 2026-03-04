#requires -Version 7.0
param(
  [Parameter(Mandatory)][string]$Pattern
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel 2>$null)).Path
if(-not $RepoRoot){ throw "REPO_ROOT_NOT_FOUND" }

$dir = Join-Path $RepoRoot "_local\_scratch"
$step = Get-ChildItem -LiteralPath $dir -Filter $Pattern -File |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1 -ExpandProperty FullName

if(-not $step){ throw "NO_STEP_MATCH: $Pattern" }

& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\ego-step.ps1") -StepPath $step
exit $LASTEXITCODE