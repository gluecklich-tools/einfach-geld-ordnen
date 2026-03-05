param(
  [Parameter(Mandatory=$true)][string]$Pattern,
  [switch]$Open
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

$step = Get-ChildItem -LiteralPath $Scratch -Filter "$Pattern" -File |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $step) { Fail "No step found for pattern '$Pattern' in $Scratch" }

$stepPath = $step.FullName

if ($Open) {
  # open is optional; never chain execution
  & code -g ("{0}:1" -f $stepPath) | Out-Null
}

# always run via tools\step-run.ps1
$runner = Join-Path $RepoRoot "tools\step-run.ps1"
& pwsh -NoProfile -ExecutionPolicy Bypass -File $runner -StepPath $stepPath
