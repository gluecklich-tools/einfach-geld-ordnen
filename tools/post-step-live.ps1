param(
  [switch]$SkipSsotRefresh,
  [switch]$SkipBrainSync
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repoRoot = Split-Path -Parent $PSCommandPath
$repoRoot = Split-Path -Parent $repoRoot  # ...\einfach-geld-ordnen

$ssotRun  = Join-Path $repoRoot 'tools\ssot-refresh-run.ps1'
$brainRun = Join-Path $repoRoot 'tools\brain-sync-run.ps1'

$brainAlreadyDone = $false

if(-not $SkipSsotRefresh){
  if(Test-Path -LiteralPath $ssotRun){
    $out = @(& $ssotRun 2>&1)
    foreach($ln in @($out)){ "$ln" }
    if(($out -join "`n") -match '(?m)^SSOT_REFRESH:\s*BRAIN_DONE\s*$'){
      $brainAlreadyDone = $true
    }
    "POST_STEP: SSOT_REFRESH_DONE"
  } else {
    "POST_STEP: SSOT_REFRESH_SKIP (tool missing)"
  }
} else {
  "POST_STEP: SSOT_REFRESH_SKIP (switch)"
}

if(-not $SkipBrainSync){
  if($brainAlreadyDone){
    "POST_STEP: BRAIN_SYNC_SKIP (already done by SSOT refresh)"
  } else {
    if(Test-Path -LiteralPath $brainRun){
      & $brainRun -FailIfMissing
      "POST_STEP: BRAIN_SYNC_DONE"
    } else {
      throw "STOP: brain-sync-run missing: $brainRun"
    }
  }
} else {
  "POST_STEP: BRAIN_SYNC_SKIP (switch)"
}