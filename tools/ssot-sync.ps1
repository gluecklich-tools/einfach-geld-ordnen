param(
  # If provided, use this chatpack directory; otherwise use newest under _local\chatpack
  [string]$ChatpackPath,
  # If set, only show what would change
  [switch]$WhatIf
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

$RepoRoot = Resolve-Path (Join-Path (Get-Location).Path ".")
$env = (& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot.Path "tools\ego-env.ps1") -AsJson) | ConvertFrom-Json

$ProjectRoot  = $env.ProjectRoot
$BrainDir     = $env.BrainDir
$InternGovDir = $env.InternGovDir
$InternMirror = Join-Path $InternGovDir "brain_mirror"

if(-not (Test-Path -LiteralPath $BrainDir)) { throw "Missing BrainDir: $BrainDir" }
if(-not (Test-Path -LiteralPath $InternGovDir)) { throw "Missing InternGovDir: $InternGovDir" }
if(-not (Test-Path -LiteralPath $InternMirror)) { throw "Missing InternMirror: $InternMirror" }

# Resolve chatpack
$chatpackRoot = Join-Path $RepoRoot.Path "_local\chatpack"
if(-not (Test-Path -LiteralPath $chatpackRoot)) { throw "Missing: $chatpackRoot" }

if($ChatpackPath -and $ChatpackPath.Trim()){
  $cp = Resolve-Path $ChatpackPath
} else {
  $cp = Get-ChildItem -LiteralPath $chatpackRoot -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if(-not $cp){ throw "No chatpack found in $chatpackRoot" }
}

$srcSSOT = Join-Path $cp.FullName "SSOT"
if(-not (Test-Path -LiteralPath $srcSSOT)) { throw "Missing SSOT in chatpack: $srcSSOT" }

function Write-Utf8NoBomLf([string]$Path, [string]$Text) {
  $dir = Split-Path -Parent $Path
  if(-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $norm = ($Text -replace "`r`n","`n") -replace "`r","`n"
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $norm, $enc)
}

function Backup-File([string]$Src, [string]$BackupDir, [string]$Tag) {
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  if(-not (Test-Path -LiteralPath $Src)) { throw "Missing file: $Src" }
  if(-not (Test-Path -LiteralPath $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }
  $name = Split-Path -Leaf $Src
  $dst  = Join-Path $BackupDir ("{0}.{1}.{2}.bak" -f $name, $Tag, $ts)
  Copy-Item -LiteralPath $Src -Destination $dst -Force
  return $dst
}

function Get-MarkedBlock([string]$Text, [string]$Begin, [string]$End) {
  $pattern = [regex]::Escape($Begin) + "(?s)(?<body>.*?)" + [regex]::Escape($End)
  $m = [regex]::Match($Text, $pattern)
  if(-not $m.Success){ return $null }
  return ($Begin + "`n" + $m.Groups["body"].Value.Trim("`r","`n") + "`n" + $End)
}

function Upsert-MarkedBlock([string]$Text, [string]$Begin, [string]$End, [string]$BlockFull) {
  $pattern = [regex]::Escape($Begin) + "(?s).*?" + [regex]::Escape($End)
  if([regex]::IsMatch($Text, $pattern)) { return [regex]::Replace($Text, $pattern, $BlockFull, 1) }
  return ($Text.TrimEnd() + "`n`n" + $BlockFull + "`n")
}

$markers = @(
  @{ Begin="<!-- EGO_LAW_FULLSWAP_TEXT_ALWAYS_FILEFIRST_BEGIN -->"; End="<!-- EGO_LAW_FULLSWAP_TEXT_ALWAYS_FILEFIRST_END -->" },
  @{ Begin="<!-- EGO_LAW_SELECTSTRING_SIMPLEMATCH_ONLY_BEGIN -->"; End="<!-- EGO_LAW_SELECTSTRING_SIMPLEMATCH_ONLY_END -->" },
  @{ Begin="<!-- EGO_LAW_NO_PASTE_CONCAT_STEP_RUN_BEGIN -->"; End="<!-- EGO_LAW_NO_PASTE_CONCAT_STEP_RUN_END -->" },
  @{ Begin="<!-- EGO_LAW_PWSH_ARRAY_JOINPATH_AND_COUNT_GUARDS_BEGIN -->"; End="<!-- EGO_LAW_PWSH_ARRAY_JOINPATH_AND_COUNT_GUARDS_END -->" }
)

$backupDirIntern = Join-Path $InternGovDir "_patch_backups"
$backupDirLocal  = Join-Path $RepoRoot.Path ("_local\patch_backups\ssot_sync_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$tag = "ssot-sync"

Write-Host "SRC_SSOT  : $srcSSOT"
Write-Host "TGT_INTERN: $InternGovDir"
Write-Host "TGT_MIRR  : $InternMirror"
Write-Host "TGT_BRAIN : $BrainDir"

foreach($fn in $names){
  $src = Join-Path $srcSSOT $fn
  if(-not (Test-Path -LiteralPath $src)){ throw "Missing source file: $src" }
  $srcText = Get-Content -LiteralPath $src -Raw

  $blocks = @()
  foreach($m in $markers){
    $b = Get-MarkedBlock -Text $srcText -Begin $m.Begin -End $m.End
    if(-not $b){ throw "Missing marker block in source ${fn}: $($m.Begin) ... $($m.End)" }
    $blocks += $b
  }

  $targets = @(
    (Join-Path $InternGovDir $fn),
    (Join-Path $InternMirror $fn),
    (Join-Path $BrainDir $fn)
  )

  foreach($t in $targets){
    if(-not (Test-Path -LiteralPath $t)){ throw "Missing target file: $t" }

    $isIntern = $t.StartsWith($InternGovDir, [System.StringComparison]::OrdinalIgnoreCase)
    $bakDir = $(if($isIntern){ $backupDirIntern } else { $backupDirLocal })

    $old = Get-Content -LiteralPath $t -Raw
    $new = $old
    foreach($b in $blocks){
      $lines = $b -split "`n"
      $begin = $lines[0].Trim()
      $end   = $lines[-1].Trim()
      $new = Upsert-MarkedBlock -Text $new -Begin $begin -End $end -BlockFull $b
    }

    if($new -eq $old){
      Write-Host ("NOCHANGE: {0}" -f $t)
      continue
    }

    if($WhatIf){
      Write-Host ("WOULD_WRITE: {0}" -f $t)
      continue
    }

    $bak = Backup-File -Src $t -BackupDir $bakDir -Tag $tag
    Write-Host "BACKUP: $bak"
    Write-Utf8NoBomLf -Path $t -Text $new
    Write-Host ("WRITE: {0}" -f $t)
  }
}

Write-Host "PASS: ssot-sync"