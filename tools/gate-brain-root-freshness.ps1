#requires -Version 7.0
param(
  [Parameter(Mandatory)][string]$RepoRoot
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$Up2 = Split-Path -Parent (Split-Path -Parent $RepoRoot)
$InternGov = Join-Path $Up2 "_INTERN\governance"
$BrainRoot = Join-Path $Up2 "Brain_EGO_Dateien"
$Stamp = Join-Path $BrainRoot "BRAIN_SYNC_LAST.txt"

if(-not (Test-Path -LiteralPath $Stamp)){
  throw "FAIL: BRAIN_ROOT_NOT_SYNCED (missing BRAIN_SYNC_LAST.txt). Run step_p0_brain_sync_root_and_latest_*"
}

$tStamp = (Get-Item -LiteralPath $Stamp).LastWriteTime

$ssotFiles = @(
  "BOOTSTRAP_INTERNAL.md",
  "QA_GATE_INTERNAL.md",
  "LEARNINGS_INTERNAL.md"
) | ForEach-Object { Join-Path $InternGov $_ }

foreach($f in $ssotFiles){
  if(-not (Test-Path -LiteralPath $f)){ throw "FAIL: MISSING_SSOT_FILE: $f" }
}

$tMax = ($ssotFiles | ForEach-Object { (Get-Item -LiteralPath $_).LastWriteTime } | Sort-Object -Descending | Select-Object -First 1)

if($tStamp -lt $tMax){
  throw ("FAIL: BRAIN_ROOT_STALE (stamp={0} < ssotMax={1}). Run step_p0_brain_sync_root_and_latest_*" -f @($tStamp, $tMax))
}

"PASS: BRAIN_ROOT_FRESH (stamp >= ssotMax)"
