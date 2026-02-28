param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001|Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function EnsureDir([string]$p){ if(!(Test-Path -LiteralPath $p)){ New-Item -ItemType Directory -Path $p | Out-Null } }
function WriteUtf8NoBom([string]$p,[string]$s){ [IO.File]::WriteAllText($p,$s,$enc) }
function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }
function Fail([string]$m){ throw $m }

# REQUIRED envs (NO absolute paths in repo)
# EGO_SSOT_ROOT: e.g. C:\Users\carst\Projekte\Einfach-Geld-Ordnen
# EGO_BRAIN_DIR: e.g. C:\Users\carst\Projekte\Einfach-Geld-Ordnen\Brain_EGO_Dateien
$ssot = [string]$env:EGO_SSOT_ROOT
$brain = [string]$env:EGO_BRAIN_DIR

if([string]::IsNullOrWhiteSpace($ssot) -or [string]::IsNullOrWhiteSpace($brain)){
  Fail "STOP: BRAIN_SYNC_REQUIRED. Set env vars: EGO_SSOT_ROOT and EGO_BRAIN_DIR (local only)."
}

if(!(Test-Path -LiteralPath $ssot)){ Fail "STOP: EGO_SSOT_ROOT missing: $ssot" }
EnsureDir $brain

# Source SSOT docs (expected layout)
$gov = Join-Path $ssot "_INTERN\governance"
if(!(Test-Path -LiteralPath $gov)){ Fail "STOP: SSOT governance missing: $gov" }

$srcFiles = @(
  Join-Path $gov "SSOT_MANIFEST_INTERNAL.json",
  Join-Path $gov "SSOT_SYSTEM_MAP_INTERNAL.md",
  Join-Path $gov "TODO.md",
  Join-Path $gov "BOOTSTRAP_INTERNAL.md",
  Join-Path $gov "GOVERNANCE_INTERNAL.md",
  Join-Path $gov "LEARNINGS_INTERNAL.md",
  Join-Path $gov "QA_GATE_INTERNAL.md",
  Join-Path $gov "ROADMAP_INTERNAL.md",
  Join-Path $gov "EVERGREEN_PIPELINE_INTERNAL.md"
)

$copied = 0
foreach($s in $srcFiles){
  if(Test-Path -LiteralPath $s){
    Copy-Item -LiteralPath $s -Destination (Join-Path $brain (Split-Path -Leaf $s)) -Force
    $copied++
  }
}

if($copied -lt 3){
  Fail "STOP: BRAIN_SYNC_INCOMPLETE. Copied only $copied files. Check SSOT governance folder contents."
}

# Write marker (brain side)
$marker = Join-Path $brain "BRAIN_SYNC_LAST.txt"
WriteUtf8NoBom $marker ("OK " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " | copied=" + $copied)

"OK: BRAIN_SYNC_REQUIRED (copied=$copied)"
return