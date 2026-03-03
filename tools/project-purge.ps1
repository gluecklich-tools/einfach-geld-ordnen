#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][string]$RootPath
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
$reports = Join-Path $RootPath "_reports"
New-Item -ItemType Directory -Path $reports -Force | Out-Null

function Parse-Note([string]$p){
  $h=@{}
  foreach($l in (Get-Content -LiteralPath $p -Encoding UTF8)){
    if($l -match "^(?<k>[^=]+)=(?<v>.*)$"){ $h[$matches.k]=$matches.v }
  }
  return $h
}

$now = (Get-Date).ToUniversalTime()

$deleted = 0
$scanRoots = @(
  Join-Path $RootPath "99_TRASH",
  Join-Path $RootPath "99_ARCHIVE"
) | Where-Object { Test-Path -LiteralPath $_ }

foreach($r in $scanRoots){
  $notes = Get-ChildItem -LiteralPath $r -Recurse -Force -File -Filter "_*_NOTE.txt" -ErrorAction SilentlyContinue
  foreach($n in $notes){
    $meta = Parse-Note $n.FullName
    if(-not $meta.ContainsKey("DELETE_AFTER_UTC")){ continue }
    $delAfter = [DateTime]::Parse($meta["DELETE_AFTER_UTC"]).ToUniversalTime()
    if($now -lt $delAfter){ continue }

    # delete folder where note lives
    $dir = Split-Path -Parent $n.FullName
    if(Test-Path -LiteralPath $dir){
      Remove-Item -LiteralPath $dir -Recurse -Force
      $deleted++
    }
  }
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$report = Join-Path $reports ("PURGE_REPORT_{0}.md" -f $ts)
Set-Content -LiteralPath $report -Value ("DeletedFolders={0}`r`nUTC={1}`r`n" -f $deleted, $now.ToString("o")) -Encoding UTF8

"OK: purge done"
"DELETED_FOLDERS: $deleted"
"REPORT: $report"