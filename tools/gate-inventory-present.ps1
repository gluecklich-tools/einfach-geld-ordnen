#requires -Version 7.0
param(
  [string]$GovDir = $env:EGO_SSOT_GOV_DIR
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}

function Fail([string]$m){ throw $m }

# CI runners do not have access to the user's local SSOT governance directory.
if($env:GITHUB_ACTIONS -eq 'true' -or $env:CI -eq 'true'){
  "PASS: gate-inventory-present (CI skip: local SSOT GOV not available)"
  exit 0
}

if(!$GovDir){ Fail "STOP: EGO_SSOT_GOV_DIR not set" }
if(!(Test-Path -LiteralPath $GovDir)){ Fail "STOP: SSOT GovDir not found: $GovDir" }

# Inventory files are expected in SSOT governance inventory folder (outside repo).
$invDir = Join-Path $GovDir "inventory"
$need = @(
  "REPO_PERMALINK_MAP.ndjson",
  "REPO_PERMALINK_INDEX.md",
  "KB_EVENTS.ndjson",
  "FINDINGS.ndjson"
)

$missing = @()
foreach($f in $need){
  $p = Join-Path $invDir $f
  if(!(Test-Path -LiteralPath $p)){ $missing += $f; continue }
  $len = (Get-Item -LiteralPath $p).Length
  if($len -lt 10){ $missing += ($f + " (too small)") }
}

if(@($missing).Count -gt 0){
  Fail ("STOP: inventory missing/invalid in SSOT: " + ($missing -join ', '))
}

"OK: gate-inventory-present (" + @($need).Count + " files)"
exit 0