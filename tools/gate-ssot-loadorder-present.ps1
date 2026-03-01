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

$req = @(
  'BOOTSTRAP_INTERNAL.md',
  'GOVERNANCE_INTERNAL.md',
  'QA_GATE_INTERNAL.md',
  'LEARNINGS_INTERNAL.md',
  'ROADMAP_INTERNAL.md'
)

$missing = @()
foreach($f in $req){
  $p = Join-Path $GovDir $f
  if(!(Test-Path -LiteralPath $p)){ $missing += $f; continue }
  $len = (Get-Item -LiteralPath $p).Length
  if($len -lt 50){ $missing += ($f + " (too small)") }
}

if(@($missing).Count -gt 0){
  Fail ("STOP: SSOT load-order missing/invalid: " + ($missing -join ', '))
}

"OK: gate-ssot-loadorder-present"
exit 0