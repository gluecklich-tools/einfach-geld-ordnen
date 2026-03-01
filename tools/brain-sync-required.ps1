param(
  [string]$RepoRoot = (Get-Location).Path,
  [switch]$NoTouch
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001|Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function EnsureDir([string]$p){ if(!(Test-Path -LiteralPath $p)){ New-Item -ItemType Directory -Path $p | Out-Null } }
function WriteUtf8NoBom([string]$p,[string]$s){ [IO.File]::WriteAllText($p,$s,$enc) }
function Fail([string]$m){ throw $m }

$gov   = [string]$env:EGO_SSOT_GOV_DIR
$brain = [string]$env:EGO_BRAIN_DIR

if([string]::IsNullOrWhiteSpace($gov) -or [string]::IsNullOrWhiteSpace($brain)){
  Fail "STOP: BRAIN_SYNC_REQUIRED. Set env vars: EGO_SSOT_GOV_DIR and EGO_BRAIN_DIR."
}
if(!(Test-Path -LiteralPath $gov)){ Fail ("STOP: missing EGO_SSOT_GOV_DIR: " + $gov) }

EnsureDir $brain

$srcFiles = @(
  "SSOT_MANIFEST_INTERNAL.json",
  "SSOT_SYSTEM_MAP_INTERNAL.md",
  "TODO.md",
  "BOOTSTRAP_INTERNAL.md",
  "GOVERNANCE_INTERNAL.md",
  "LEARNINGS_INTERNAL.md",
  "QA_GATE_INTERNAL.md",
  "ROADMAP_INTERNAL.md",
  "EVERGREEN_PIPELINE_INTERNAL.md",
  "EVERGREEN_CANDIDATES_INTERNAL.tsv"
)

$now = Get-Date
$copied = 0
$names = @()

foreach($name in $srcFiles){
  $src = Join-Path $gov $name
  if(Test-Path -LiteralPath $src){
    $dst = Join-Path $brain $name
    Copy-Item -LiteralPath $src -Destination $dst -Force
    $copied++
    $names += $name

    if(-not $NoTouch){
      (Get-Item -LiteralPath $dst).LastWriteTime = $now
    }
  }
}

if($copied -lt 3){
  Fail ("STOP: BRAIN_SYNC_INCOMPLETE. Copied only " + $copied + " files. Check EGO_SSOT_GOV_DIR contents.")
}

$marker = Join-Path $brain "BRAIN_SYNC_LAST.txt"
$body = @()
$body += ("OK " + ($now.ToString("yyyy-MM-dd HH:mm:ss")))
$body += ("copied=" + $copied)
$body += ("files=" + ($names -join ", "))
WriteUtf8NoBom $marker ($body -join "`n")
(Get-Item -LiteralPath $marker).LastWriteTime = $now

"OK: BRAIN_SYNC_REQUIRED (copied=$copied)"
return