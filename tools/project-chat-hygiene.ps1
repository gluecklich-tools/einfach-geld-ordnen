#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$ChatRootPath,
  [int]$KeepSessions = 50,
  [string]$ReportsRoot = "C:\Users\carst\Projekte\_reports",
  [string]$ArchiveRoot = "C:\Users\carst\Projekte\99_ARCHIVE\chats",
  [string]$TrashRoot   = "C:\Users\carst\Projekte\99_TRASH\chats",
  [switch]$WhatIfMove
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Write-Utf8NoBom([string]$p,[string]$s){
  $dir = Split-Path -Parent $p
  if($dir -and -not (Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [IO.File]::WriteAllText($p,$s,$utf8)
}
function Read-Utf8NoBom([string]$p){ [IO.File]::ReadAllText($p,$utf8) }

trap {
  Write-Host ""
  Write-Host "=== project-chat-hygiene ERROR ==="
  Write-Host $_.Exception.Message
  if ($_.InvocationInfo) { Write-Host $_.InvocationInfo.PositionMessage }
  throw
}

function Ensure-Dir([string]$p){ if(-not (Test-Path -LiteralPath $p)){ New-Item -ItemType Directory -Path $p -Force | Out-Null } }
function NowUtc(){ (Get-Date).ToUniversalTime().ToString("o") }

function Load-State([string]$p){
  if(Test-Path -LiteralPath $p){
    try { return (Get-Content -LiteralPath $p -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { }
  }
  return [pscustomobject]@{ run_id = 0; last_run_utc = $null; items = @{} }
}

function Save-State([string]$p,$state){
  $json = $state | ConvertTo-Json -Depth 8
  Write-Utf8NoBom $p ($json + "`r`n")
}

function Is-PinnedName([string]$name){
  if($name -match "(?i)KEEP"){ return $true }
  if($name -match "(?i)PINNED"){ return $true }
  return $false
}

function Get-SessionKey([System.IO.DirectoryInfo]$dir){
  # use folder name as stable session key
  return $dir.FullName
}

$ChatRootPath = (Resolve-Path -LiteralPath $ChatRootPath).Path
if(-not (Test-Path -LiteralPath $ChatRootPath -PathType Container)){ throw "ChatRootPath not found: $ChatRootPath" }

Ensure-Dir $ReportsRoot
Ensure-Dir $ArchiveRoot
Ensure-Dir $TrashRoot

$statePath = Join-Path $ReportsRoot "CHAT_HYGIENE_STATE.json"
$state = Load-State $statePath
$state.run_id = [int]$state.run_id + 1
$state.last_run_utc = NowUtc()

if(-not $state.items){ $state | Add-Member -NotePropertyName items -NotePropertyValue (@{}) -Force }

# Sessions = immediate subfolders
$sessions = Get-ChildItem -LiteralPath $ChatRootPath -Directory -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending

# Determine KEEP set: last N sessions + pinned
$keepSet = New-Object 'System.Collections.Generic.HashSet[string]'
$pinnedSet = New-Object 'System.Collections.Generic.HashSet[string]'

$idx=0
foreach($s in $sessions){
  $key = Get-SessionKey $s
  $pinned = (Is-PinnedName $s.Name)
  if($pinned){ $pinnedSet.Add($key) | Out-Null }
  if($idx -lt $KeepSessions -or $pinned){
    $keepSet.Add($key) | Out-Null
  }
  $idx++
}

# Build actions: non-keep -> archive; obvious trash -> trash
$toArchive = New-Object 'System.Collections.Generic.List[string]'
$toTrash   = New-Object 'System.Collections.Generic.List[string]'

foreach($s in $sessions){
  $key = Get-SessionKey $s
  $item = $state.items[$key]

  if(-not $item){
    $item = [pscustomobject]@{ first_seen_run = $state.run_id; last_seen_run = $state.run_id; pinned = $false; moved_archive_run=$null; moved_trash_run=$null }
    $state.items[$key] = $item
  } else {
    $item.last_seen_run = $state.run_id
  }

  if($pinnedSet.Contains($key)){ $item.pinned = $true }

  if(-not $keepSet.Contains($key)){
    # Heuristic trash: empty folder
    $hasAny = @(Get-ChildItem -LiteralPath $s.FullName -Recurse -File -ErrorAction SilentlyContinue).Count -gt 0
    if(-not $hasAny){
      $toTrash.Add($s.FullName) | Out-Null
    } else {
      $toArchive.Add($s.FullName) | Out-Null
    }
  }
}

function Move-Dir([string]$src,[string]$dstRoot,[string]$tag){
  $name = Split-Path -Leaf $src
  $dst = Join-Path $dstRoot $name
  if(Test-Path -LiteralPath $dst){
    $dst = Join-Path $dstRoot ("{0}_{1}" -f $name, (Get-Date -Format "yyyyMMdd_HHmmss"))
  }
  if($WhatIfMove){ "WHATIF: MOVE $tag $src -> $dst"; return $dst }
  Move-Item -LiteralPath $src -Destination $dst -Force
  return $dst
}

$reportMd = New-Object 'System.Collections.Generic.List[string]'
$reportMd.Add("# Chat Hygiene Report") | Out-Null
$reportMd.Add("") | Out-Null
$reportMd.Add(("* run_id: {0}" -f $state.run_id)) | Out-Null
$reportMd.Add(("* chat_root: {0}" -f $ChatRootPath)) | Out-Null
$reportMd.Add(("* keep_sessions: {0}" -f $KeepSessions)) | Out-Null
$reportMd.Add(("* pinned: {0}" -f $pinnedSet.Count)) | Out-Null
$reportMd.Add(("* archive_candidates: {0}" -f $toArchive.Count)) | Out-Null
$reportMd.Add(("* trash_candidates: {0}" -f $toTrash.Count)) | Out-Null
$reportMd.Add("") | Out-Null

# Execute moves
if($toArchive.Count -gt 0){
  $reportMd.Add("## Archived") | Out-Null
  foreach($p in $toArchive){
    $dst = Move-Dir $p $ArchiveRoot "ARCHIVE"
    $reportMd.Add(("- {0} -> {1}" -f $p, $dst)) | Out-Null
  }
  $reportMd.Add("") | Out-Null
}

if($toTrash.Count -gt 0){
  $reportMd.Add("## Trashed") | Out-Null
  foreach($p in $toTrash){
    $dst = Move-Dir $p $TrashRoot "TRASH"
    $reportMd.Add(("- {0} -> {1}" -f $p, $dst)) | Out-Null
  }
  $reportMd.Add("") | Out-Null
}

# Save state + report
Save-State $statePath $state
$repPath = Join-Path $ReportsRoot ("CHAT_HYGIENE_{0}.md" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
Write-Utf8NoBom $repPath (($reportMd -join "`r`n") + "`r`n")

"OK: chat hygiene done"
"STATE: $statePath"
"REPORT: $repPath"