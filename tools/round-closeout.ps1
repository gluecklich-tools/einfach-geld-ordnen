#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ConfirmPreference="None"
$ProgressPreference="SilentlyContinue"

function Write_Utf8NoBomLF([string]$Path,[string]$Text){
  $Text = $Text.Replace("`r`n","`n").Replace("`r","`n")
  [System.IO.File]::WriteAllText($Path,$Text,[System.Text.UTF8Encoding]::new($false))
}
function Read_Utf8Raw([string]$Path){ Get-Content -LiteralPath $Path -Raw -Encoding UTF8 }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$InternalTools = Join-Path $ProjectRoot "_INTERN\tools"
$BrainRoot = Join-Path $ProjectRoot "Brain_EGO_Dateien"
$BrainLatest = Join-Path $BrainRoot "latest"

New-Item -ItemType Directory -Force -Path $BrainLatest | Out-Null

$ssot = Join-Path $InternalTools "ssot-refresh-proxy.ps1"
if(!(Test-Path -LiteralPath $ssot -PathType Leaf)){ throw "Missing ssot-refresh-proxy: $ssot" }

Write-Host "== ROUND CLOSEOUT ==" -ForegroundColor Cyan
& pwsh -NoProfile -ExecutionPolicy Bypass -File $ssot

# Upsert docs (append delta into INTERN docs)
$upsert = Join-Path $RepoRoot "tools\brain-docs-upsert.ps1"
if(Test-Path -LiteralPath $upsert -PathType Leaf){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $upsert
}

# Marker: root + latest
$nowUtc = [DateTimeOffset]::UtcNow.ToString("o")
$markerRoot   = Join-Path $BrainRoot "BRAIN_SYNC_LAST.txt"
$markerLatest = Join-Path $BrainLatest "BRAIN_SYNC_LAST.txt"
Write_Utf8NoBomLF $markerRoot   ($nowUtc + "`n")
Write_Utf8NoBomLF $markerLatest ($nowUtc + "`n")

# Mirror latest -> root (deterministic “Explorer is fresh”)
$names = @(
  "ROADMAP_INTERNAL.md","SSOT_MANIFEST_INTERNAL.json","SSOT_SYSTEM_MAP_INTERNAL.md",
  "EVERGREEN_PIPELINE_INTERNAL.md","EVERGREEN_CANDIDATES_INTERNAL.tsv","TODO.md"
)

foreach($n in $names){
  $src = Join-Path $BrainLatest $n
  $dst = Join-Path $BrainRoot $n
  if(Test-Path -LiteralPath $src -PathType Leaf){
    Copy-Item -LiteralPath $src -Destination $dst -Force
  }
}

"PASS: round-closeout"