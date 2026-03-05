param(
  [Parameter(Mandatory=$true)][string]$Pattern
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

function Get-RepoRoot {
  $p = (& git rev-parse --show-toplevel 2>$null)
  if (-not $p) { Fail "RepoRoot konnte nicht bestimmt werden (git rev-parse)." }
  return (Resolve-Path -LiteralPath $p).Path
}

$RepoRoot = Get-RepoRoot
$Scratch = Join-Path $RepoRoot "_local\_scratch"
if (-not (Test-Path -LiteralPath $Scratch)) { Fail "Scratch not found: $Scratch" }

$step = Get-ChildItem -LiteralPath $Scratch -Filter "$Pattern" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $step) { Fail "No step found for pattern '$Pattern' in $Scratch" }

$runner = Join-Path $RepoRoot "tools\step-run.ps1"
& pwsh -NoProfile -ExecutionPolicy Bypass -File $runner -StepPath $step.FullName
