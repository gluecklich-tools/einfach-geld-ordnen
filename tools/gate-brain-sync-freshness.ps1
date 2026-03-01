#requires -Version 7.0
param(
  [string]$BrainDir = $env:EGO_BRAIN_DIR,
  [int]$MaxAgeHours = 24
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}

function Fail([string]$m){ throw $m }

# CI runners do not have access to the user's local Brain directory.
if($env:GITHUB_ACTIONS -eq 'true' -or $env:CI -eq 'true'){
  "PASS: gate-brain-sync-freshness (CI skip: local Brain not available)"
  exit 0
}

if(!$BrainDir){ Fail "STOP: EGO_BRAIN_DIR not set" }
if(!(Test-Path -LiteralPath $BrainDir)){ Fail "STOP: BrainDir not found: $BrainDir" }

$latest = Join-Path $BrainDir "latest"
if(!(Test-Path -LiteralPath $latest)){ Fail "STOP: Brain latest missing: $latest" }

# Prefer explicit marker if present
$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
$refTime = $null

if(Test-Path -LiteralPath $marker){
  $line = (Get-Content -LiteralPath $marker -Encoding UTF8 | Select-Object -First 1).Trim()
  # Accept ISO or yyyyMMdd_HHmmss_fff
  try{
    $refTime = [datetime]::Parse($line)
  }catch{
    try{
      $refTime = [datetime]::ParseExact($line,'yyyyMMdd_HHmmss_fff',$null)
    }catch{
      $refTime = (Get-Item -LiteralPath $marker).LastWriteTime
    }
  }
}else{
  $refTime = (Get-Item -LiteralPath $latest).LastWriteTime
}

$age = (Get-Date) - $refTime
$ageHours = [math]::Round($age.TotalHours,2)

if($ageHours -gt $MaxAgeHours){
  Fail ("STOP: Brain snapshot too old ({0}h > {1}h). Run Brain sync. Ref={2}" -f $ageHours,$MaxAgeHours,$refTime.ToString('s'))
}

"OK: gate-brain-sync-freshness (ageHours=" + $ageHours + ", ref=" + $refTime.ToString('s') + ")"
exit 0