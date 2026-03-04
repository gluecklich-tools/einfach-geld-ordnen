#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][string]$RootPath,
  [Parameter(Mandatory=$true)][string]$ArchiveTsv,
  [Parameter(Mandatory=$true)][string]$TrashTsv
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)
function Write-Utf8NoBom([string]$p,[string]$s){ [IO.File]::WriteAllText($p,$s,$utf8) }

$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
$ArchiveTsv = (Resolve-Path -LiteralPath $ArchiveTsv).Path
$TrashTsv   = (Resolve-Path -LiteralPath $TrashTsv).Path

$reports = Join-Path $RootPath "_reports"
New-Item -ItemType Directory -Path $reports -Force | Out-Null

$trashRoot = Join-Path $RootPath "99_TRASH\$(Get-Date -Format yyyy)\$(Get-Date -Format MM)"
$archRoot  = Join-Path $RootPath "99_ARCHIVE\$(Get-Date -Format yyyy)\$(Get-Date -Format MM)"
New-Item -ItemType Directory -Path $trashRoot -Force | Out-Null
New-Item -ItemType Directory -Path $archRoot  -Force | Out-Null

function Read-TsvPaths([string]$p){
  $lines = Get-Content -LiteralPath $p -Encoding UTF8
  if($lines.Count -lt 2){ return @() }
  $out = @()
  for($i=1;$i -lt $lines.Count;$i++){
    $cols = $lines[$i].Split("`t")
    if($cols.Count -ge 1 -and $cols[0]){ $out += $cols[0] }
  }
  return $out
}

function Move-One([string]$src, [string]$destRoot, [string]$noteName, [int]$retentionDays){
  if(-not (Test-Path -LiteralPath $src -PathType Leaf)){ return $false }
  $rel = $src.Substring($RootPath.Length).TrimStart("\")
  $dest = Join-Path $destRoot $rel
  $destDir = Split-Path -Parent $dest
  New-Item -ItemType Directory -Path $destDir -Force | Out-Null
  Move-Item -LiteralPath $src -Destination $dest -Force

  $notePath = Join-Path $destDir $noteName
  if(-not (Test-Path -LiteralPath $notePath)){
    $utc = (Get-Date).ToUniversalTime().ToString("o")
    $del = (Get-Date).ToUniversalTime().AddDays($retentionDays).ToString("o")
    $note = @(
      "MOVED_UTC=$utc",
      "SOURCE=$src",
      "RETENTION_DAYS=$retentionDays",
      "DELETE_AFTER_UTC=$del"
    ) -join "`r`n"
    Write-Utf8NoBom $notePath ($note + "`r`n")
  }
  return $true
}

$archPaths  = Read-TsvPaths $ArchiveTsv
$trashPaths = Read-TsvPaths $TrashTsv

$archMoved = 0
foreach($p in $archPaths){
  if(Move-One -src $p -destRoot $archRoot -noteName "_ARCHIVE_NOTE.txt" -retentionDays 90){ $archMoved++ }
}
$trashMoved = 0
foreach($p in $trashPaths){
  if(Move-One -src $p -destRoot $trashRoot -noteName "_TRASH_NOTE.txt" -retentionDays 14){ $trashMoved++ }
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$report = Join-Path $reports ("MOVE_REPORT_{0}.md" -f $ts)
$md = @()
$md += "# Move Report"
$md += ""
$md += "* Root: $RootPath"
$md += "* Archive moved: $archMoved"
$md += "* Trash moved: $trashMoved"
$md += "* Archive root: $archRoot"
$md += "* Trash root: $trashRoot"
Write-Utf8NoBom $report (($md -join "`r`n") + "`r`n")

"OK: move done"
"REPORT: $report"
