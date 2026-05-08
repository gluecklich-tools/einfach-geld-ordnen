param(
  [Parameter(Mandatory=$true)][string]$Pattern,

  [ValidateSet(
    'Active-Scope-Lock',
    'Produkt-Loop',
    'Governance-Änderung',
    'Workbook-Product-Finish',
    'Stage-Only-Visual-Finalizer',
    'Sheet-Finalizer',
    'Tool-Repair',
    'Documentation-Sync',
    'Learning-Sync',
    'Truth-Relock',
    'Screenshot-Acceptance',
    'OpenXML-Recovery-PreRepair',
    'Claude-Prompting',
    'Brain-Intern-Struktur',
    'Folgeprojekt-Klon',
    'OpenAI-Regress-Governance',
    'Tool-Entrypoint-Failure',
    'Workbook-Artifact-Identity',
    'Visible-Surface-Rebuild',
    'Workbook-Masterpass',
    'Hash-Mismatch-Relock',
    'Parameter-Compact-Screenshot-Verify',
    'Project-Housekeeping-Size-Gate',
    'Lean-Handoff-Zip',
    'Project-Hygiene-Cleanup',
    'Excel-Sheet-Rebuild-Contract'
)]
    [string]$RequiredReadsTaskType
)

. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1')

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

function Get-RepoRoot {
  $p = (& git rev-parse --show-toplevel 2>$null)
  if (-not $p) { Fail "RepoRoot konnte nicht bestimmt werden (git rev-parse)." }
  return (Resolve-Path -LiteralPath $p).Path
}

function Get-LatestMatchingFile {
  param(
    [Parameter(Mandatory=$true)][string]$DirectoryPath,
    [Parameter(Mandatory=$true)][string]$Pattern
  )

  $dirInfo = [System.IO.DirectoryInfo]::new($DirectoryPath)
  if (-not $dirInfo.Exists) { return $null }

  $best = $null
  foreach($f in $dirInfo.EnumerateFiles($Pattern, [System.IO.SearchOption]::TopDirectoryOnly)){
    if ($null -eq $best) {
      $best = $f
      continue
    }
    if ($f.LastWriteTimeUtc -gt $best.LastWriteTimeUtc) {
      $best = $f
      continue
    }
    if ($f.LastWriteTimeUtc -eq $best.LastWriteTimeUtc -and $f.Name -gt $best.Name) {
      $best = $f
    }
  }

  return $best
}

if ($RequiredReadsTaskType -eq 'OpenXML-Recovery-PreRepair') {
  Fail 'OpenXML-Recovery-PreRepair darf nicht ueber step-run-latest laufen. Verwende step-run.ps1 mit hartem literal StepPath.'
}

$RepoRoot = Get-RepoRoot
$Scratch = Join-Path $RepoRoot "_local\_scratch"
if (-not (Test-Path -LiteralPath $Scratch)) { Fail "Scratch not found: $Scratch" }

$step = Get-LatestMatchingFile -DirectoryPath $Scratch -Pattern $Pattern
if (-not $step) { Fail "No step found for pattern '$Pattern' in $Scratch" }

$runner = Join-Path $RepoRoot "tools\step-run.ps1"

$RunnerArgs = @(
  '-NoProfile'
  '-ExecutionPolicy'
  'Bypass'
  '-File'
  $runner
  '-StepPath'
  $step.FullName
)

if (-not [string]::IsNullOrWhiteSpace($RequiredReadsTaskType)) {
  $RunnerArgs += @('-RequiredReadsTaskType', $RequiredReadsTaskType)
}

& pwsh @RunnerArgs

# EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_STEPRUN_LATEST:START
# step-run-latest bleibt fuer den aktiven Recovery-Strang verboten; OpenXML-Recovery-PreRepair failt bewusst und verlangt step-run mit literal StepPath.
# EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_STEPRUN_LATEST:END

# EGO_MANAGED_BLOCK:20260430_TRUTH_RELOCK_TASKTYPES:START
# 2026-04-30 Truth/Documentation/Learning Sync:
# RequiredReadsTaskType/TaskType parity must include Documentation-Sync, Learning-Sync, Truth-Relock, Screenshot-Acceptance and OpenXML-Recovery-PreRepair.
# TASK_REQUIRED_READS_MATRIX.tsv must stay 5-column valid and in parity with ValidateSet values.
# EGO_MANAGED_BLOCK:20260430_TRUTH_RELOCK_TASKTYPES:END
