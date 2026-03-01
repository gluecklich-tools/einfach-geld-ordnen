[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$RepoRoot,
  [int]$StepsKeepDays = 7,
  [int]$StepsKeepLast = 30,
  [int]$PatchBackupsKeepDays = 30,
  [int]$PatchBackupsKeepLast = 200
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{if($IsWindows){chcp 65001|Out-Null}}catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

if(!(Test-Path -LiteralPath $RepoRoot)){ throw "STOP: RepoRoot missing: $RepoRoot" }

function Get-OldItems([string]$Path,[int]$KeepDays,[int]$KeepLast){
  if(!(Test-Path -LiteralPath $Path)){ return @() }
  $cutoff = (Get-Date).AddDays(-1 * [Math]::Abs($KeepDays))
  $items = Get-ChildItem -LiteralPath $Path -Force -ErrorAction Stop | Where-Object { $_.Name -ne '.gitkeep' }
  $sorted = $items | Sort-Object LastWriteTimeUtc -Descending
  $keep=@(); if($KeepLast -gt 0){ $keep = $sorted | Select-Object -First $KeepLast }
  $keepSet=@{}; foreach($k in @($keep)){ $keepSet[$k.FullName]=$true }
  $del=@()
  foreach($it in @($sorted)){
    if($keepSet.ContainsKey($it.FullName)){ continue }
    if($it.LastWriteTime -lt $cutoff){ $del += $it }
  }
  return @($del)
}

function Try-Remove([System.IO.FileSystemInfo]$Item){
  try{
    if($Item.PSIsContainer){ Remove-Item -LiteralPath $Item.FullName -Recurse -Force -ErrorAction Stop }
    else{ Remove-Item -LiteralPath $Item.FullName -Force -ErrorAction Stop }
    return $true
  }catch{ return $false }
}

$local = Join-Path $RepoRoot '_local'
$steps = Join-Path $local 'steps'
$adhoc = Join-Path $steps '_adhoc'
$patch = Join-Path $local 'patch_backups'

$deleted = New-Object System.Collections.Generic.List[string]
$failed  = New-Object System.Collections.Generic.List[string]

foreach($it in @(Get-OldItems -Path $steps -KeepDays $StepsKeepDays -KeepLast $StepsKeepLast)){
  if(Try-Remove $it){ $deleted.Add("DEL steps: $($it.FullName)") } else { $failed.Add("FAIL steps: $($it.FullName)") }
}
foreach($it in @(Get-OldItems -Path $adhoc -KeepDays $StepsKeepDays -KeepLast $StepsKeepLast)){
  if(Try-Remove $it){ $deleted.Add("DEL adhoc: $($it.FullName)") } else { $failed.Add("FAIL adhoc: $($it.FullName)") }
}
foreach($it in @(Get-OldItems -Path $patch -KeepDays $PatchBackupsKeepDays -KeepLast $PatchBackupsKeepLast)){
  if(Try-Remove $it){ $deleted.Add("DEL patch: $($it.FullName)") } else { $failed.Add("FAIL patch: $($it.FullName)") }
}

if(Test-Path -LiteralPath $local){
  $dirs = Get-ChildItem -LiteralPath $local -Recurse -Directory -Force | Sort-Object FullName -Descending
  foreach($d in @($dirs)){
    try{
      $hasChildren = @(Get-ChildItem -LiteralPath $d.FullName -Force -ErrorAction Stop).Count -gt 0
      if(-not $hasChildren){
        Remove-Item -LiteralPath $d.FullName -Force -ErrorAction Stop
        $deleted.Add("DEL emptydir: $($d.FullName)")
      }
    }catch{}
  }
}

"HygieneDone: RepoRoot=$RepoRoot"
"Deleted: $($deleted.Count)"
foreach($x in @($deleted)){ $x }
if($failed.Count -gt 0){
  "Failed: $($failed.Count)"
  foreach($x in @($failed)){ $x }
  throw "STOP: HYGIENE had failures."
}