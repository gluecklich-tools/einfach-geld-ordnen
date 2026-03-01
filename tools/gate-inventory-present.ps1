#requires -Version 7.0
param(
  [string]$GovDir = $env:EGO_SSOT_GOV_DIR
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}

function Fail([string]$m){ throw $m }

if(!$GovDir){ Fail "STOP: EGO_SSOT_GOV_DIR not set" }
if(!(Test-Path -LiteralPath $GovDir)){ Fail "STOP: SSOT GovDir not found: $GovDir" }

# We accept either of these common locations (flexible)
$candidates = @(
  (Join-Path $GovDir 'inventory\REPO_PERMALINK_MAP.ndjson'),
  (Join-Path $GovDir 'inventory\REPO_PERMALINK_INDEX.md'),
  (Join-Path $GovDir 'inventory\repo_permalink_map.ndjson'),
  (Join-Path $GovDir 'inventory\repo_permalink_index.md')
)

$found = @($candidates | Where-Object { Test-Path -LiteralPath $_ })
if(@($found).Count -eq 0){
  Fail ("STOP: inventory missing. Expected one of: " + ($candidates -join ' | '))
}

"OK: gate-inventory-present (" + (@($found).Count) + " files)"
exit 0