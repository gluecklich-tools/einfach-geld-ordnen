#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [string]$RootPath,

  [ValidateRange(1,3650)]
  [int]$TrashRetentionDays = 14,

  [ValidateRange(1,3650)]
  [int]$ArchiveRetentionDays = 90
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Write-Utf8NoBom([string]$p,[string]$s){ [IO.File]::WriteAllText($p,$s,$utf8) }

trap {
  Write-Host ""
  Write-Host "=== project-classify ERROR ==="
  Write-Host $_.Exception.Message
  if ($_.InvocationInfo) { Write-Host $_.InvocationInfo.PositionMessage }
  throw
}

$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
$reports = Join-Path $RootPath "_reports"
New-Item -ItemType Directory -Path $reports -Force | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$outKeep    = Join-Path $reports ("CLASSIFY_KEEP_{0}.tsv" -f $ts)
$outArch    = Join-Path $reports ("CLASSIFY_ARCHIVE_{0}.tsv" -f $ts)
$outTrash   = Join-Path $reports ("CLASSIFY_TRASH_{0}.tsv" -f $ts)
$outSummary = Join-Path $reports ("CLASSIFY_SUMMARY_{0}.md" -f $ts)

function Is-Trash([string]$p){
  $n = [IO.Path]::GetFileName($p)
  if($n -eq "Thumbs.db"){ return $true }
  if($n -eq ".DS_Store"){ return $true }
  if($p -match "\\__MACOSX\\"){ return $true }
  if($p -match "\\node_modules\\"){ return $true }
  if($p -match "\.tmp$"){ return $true }
  return $false
}
function Is-Archive([string]$p){
  if($p -match "\\Archiv_GitHub_Clone_Dateien\\"){ return $true }
  if($p -match "\\snapshots\\"){ return $true }
  if($p -match "\\ego_pack_.*_parts\\"){ return $true }
  return $false
}

$files = Get-ChildItem -LiteralPath $RootPath -Recurse -Force -File -ErrorAction SilentlyContinue |
  Select-Object FullName, Length, LastWriteTimeUtc

$keep  = New-Object 'System.Collections.Generic.List[object]'
$arch  = New-Object 'System.Collections.Generic.List[object]'
$trash = New-Object 'System.Collections.Generic.List[object]'

foreach($f in $files){
  $p = [string]$f.FullName
  $sz = [int64]$f.Length
  $lw = $f.LastWriteTimeUtc.ToString("o")

  if(Is-Trash $p){
    $trash.Add([pscustomobject]@{path=$p; size=$sz; last_write_utc=$lw; retention_days=$TrashRetentionDays; note="auto-trash-rule"})
    continue
  }
  if(Is-Archive $p){
    $arch.Add([pscustomobject]@{path=$p; size=$sz; last_write_utc=$lw; retention_days=$ArchiveRetentionDays; note="auto-archive-rule"})
    continue
  }
  $keep.Add([pscustomobject]@{path=$p; size=$sz; last_write_utc=$lw; note=""})
}

function To-Tsv($list, $path, $cols){
  $lines = New-Object 'System.Collections.Generic.List[string]'
  $lines.Add(($cols -join "`t"))
  foreach($x in $list){
    $vals = foreach($c in $cols){
      $v = $x.$c
      if($null -eq $v){ "" } else { ([string]$v).Replace("`t"," ") }
    }
    $lines.Add(($vals -join "`t"))
  }
  Write-Utf8NoBom $path (($lines -join "`r`n") + "`r`n")
}

To-Tsv $keep  $outKeep  @("path","size","last_write_utc","note")
To-Tsv $arch  $outArch  @("path","size","last_write_utc","retention_days","note")
To-Tsv $trash $outTrash @("path","size","last_write_utc","retention_days","note")

$sum = @()
$sum += "# Classify Summary"
$sum += ""
$sum += "* Root: $RootPath"
$sum += "* KEEP:   $([int]$keep.Count)"
$sum += "* ARCH:   $([int]$arch.Count)"
$sum += "* TRASH:  $([int]$trash.Count)"
$sum += ""
$sum += "Next: run project-move.ps1 with the TSV files."
Write-Utf8NoBom $outSummary (($sum -join "`r`n") + "`r`n")

"OK: classify done"
"KEEP:   $outKeep"
"ARCH:   $outArch"
"TRASH:  $outTrash"
"SUM:    $outSummary"