#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$NL = [Environment]::NewLine
function Fail([string]$m){ throw $m }

$marker = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\Brain_EGO_Dateien\BRAIN_SYNC_LAST.txt"
$round  = (Join-Path $PSScriptRoot "round-closeout.ps1")

function Get-LastCommitLocal {
  $s = (git log -1 --format=%cd --date=iso-strict 2>$null)
  if([string]::IsNullOrWhiteSpace($s)){ return $null }
  try { [datetimeoffset]::Parse($s) } catch { $null }
}

function Get-MarkerTime {
  param([string]$p)
  if(-not (Test-Path -LiteralPath $p)){ return $null }
  $raw = [System.IO.File]::ReadAllText($p,[System.Text.Encoding]::UTF8).Trim()
  if([string]::IsNullOrWhiteSpace($raw)){ return $null }
  # accept either key=value format or plain timestamp line
  $first = ($raw -split "\r?\n")[0].Trim()
  if($first -match "^ts_local="){ $first = $first.Substring(9).Trim() }
  try { [datetimeoffset]::Parse($first) } catch { $null }
}

function Check-Closeout {
  $c = Get-LastCommitLocal
  $m = Get-MarkerTime -p $marker
  if($null -eq $c){ return @{ Ok=$true; Why="NO_COMMIT_FOUND" } }
  if($null -eq $m){ return @{ Ok=$false; Why="NO_MARKER" } }
  if($m -lt $c){ return @{ Ok=$false; Why="MARKER_OLDER_THAN_COMMIT"; Commit=$c; Marker=$m } }
  return @{ Ok=$true; Why="BrainSync >= last commit" }
}

$r = Check-Closeout
if(-not $r.Ok){
  # Auto-fix ONCE
  if(Test-Path -LiteralPath $round){
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $round | Out-Host
  } else {
    Fail ("FAIL: CLOSEOUT_REQUIRED (missing round-closeout) Run: pwsh -NoProfile -ExecutionPolicy Bypass -File " + $round)
  }
  $r2 = Check-Closeout
  if(-not $r2.Ok){
    $msg=@()
    $msg += "FAIL: CLOSEOUT_REQUIRED (auto-run did not produce valid marker)"
    $msg += ("MarkerPath={0}" -f $marker)
    if($r2.ContainsKey("Marker")){ $msg += ("Marker={0}" -f $r2.Marker) }
    if($r2.ContainsKey("Commit")){ $msg += ("Commit={0}" -f $r2.Commit) }
    $msg += ("Run: pwsh -NoProfile -ExecutionPolicy Bypass -File {0}" -f $round)
    Fail ($msg -join $NL)
  }
}

Write-Host ("PASS: gate-closeout-after-commit (" + (Check-Closeout).Why + ")")
exit 0

# EGO_LEARNING_SYNC_WIRE_START
$EgoLearningSyncAssert = Join-Path $PSScriptRoot "assert-no-pending-learning-sync.ps1"
if (Test-Path -LiteralPath $EgoLearningSyncAssert) {
    & $EgoLearningSyncAssert -AutoDrainSynced
}
# EGO_LEARNING_SYNC_WIRE_END

#region GOVERNANCE_ROOT_SYNC_HARDGATE_V2
$govRootSyncTool = Join-Path $PSScriptRoot "sync-governance-root-files.ps1"
$govRootGateTool = Join-Path $PSScriptRoot "gate-governance-root-files-sync.ps1"

if ((Test-Path -LiteralPath $govRootSyncTool -PathType Leaf) -and (Test-Path -LiteralPath $govRootGateTool -PathType Leaf)) {
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $govRootSyncTool
    if ($LASTEXITCODE -ne 0) { throw "FAIL: sync-governance-root-files" }

    & pwsh -NoProfile -ExecutionPolicy Bypass -File $govRootGateTool
    if ($LASTEXITCODE -ne 0) { throw "FAIL: gate-governance-root-files-sync" }
}
#endregion GOVERNANCE_ROOT_SYNC_HARDGATE_V2

#region GOVERNANCE_CORE_LF_HARDGATE_V2
$govCoreLfNormalizeTool = Join-Path $PSScriptRoot "normalize-governance-core-lf.ps1"
$govCoreLfGateTool      = Join-Path $PSScriptRoot "gate-governance-core-lf.ps1"

if ((Test-Path -LiteralPath $govCoreLfNormalizeTool -PathType Leaf) -and (Test-Path -LiteralPath $govCoreLfGateTool -PathType Leaf)) {
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $govCoreLfNormalizeTool
    if ($LASTEXITCODE -ne 0) { throw "FAIL: normalize-governance-core-lf" }

    & pwsh -NoProfile -ExecutionPolicy Bypass -File $govCoreLfGateTool
    if ($LASTEXITCODE -ne 0) { throw "FAIL: gate-governance-core-lf" }
}
#endregion GOVERNANCE_CORE_LF_HARDGATE_V2
