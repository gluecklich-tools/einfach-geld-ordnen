#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$Marker = Join-Path $ProjectRoot "Brain_EGO_Dateien\BRAIN_SYNC_LAST.txt"

$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){ Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)" }
$commitTime = [DateTimeOffset]::Parse($commitIso)

$markerRaw = ""
$brainTime = $null

if(Test-Path -LiteralPath $Marker -PathType Leaf){
  $markerRaw = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim()
  if(-not [string]::IsNullOrWhiteSpace($markerRaw)){
    try { $brainTime = [DateTimeOffset]::Parse($markerRaw) } catch { $brainTime = $null }
  }
}

if($null -eq $brainTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (no valid marker) MarkerPath={0} MarkerRaw={1} Commit={2} Run: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $Marker,$markerRaw,$commitIso)
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit) MarkerPath={0} MarkerRaw={1} Brain={2:O} Commit={3:O} Run: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $Marker,$markerRaw,$brainTime,$commitTime)
}

"PASS: gate-closeout-after-commit (BrainSync >= last commit)"
exit 0
