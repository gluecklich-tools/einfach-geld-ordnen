param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$wf = Join-Path $RepoRoot ".github/workflows/enterprise-laws.yml"
if(!(Test-Path -LiteralPath $wf)){ Fail "FAIL: ACTIONS_AUTOPILOT_POLICY missing enterprise-laws.yml" }

$txt = [IO.File]::ReadAllText($wf,$enc)

# Trigger-Pinning (main + recovery/** + dispatch)
if($txt -notlike "*workflow_dispatch*"){ Fail "FAIL: ACTIONS_AUTOPILOT_POLICY missing workflow_dispatch" }
if($txt -notlike "*push:*"){ Fail "FAIL: ACTIONS_AUTOPILOT_POLICY missing push trigger" }
if($txt -notlike "*- main*"){ Fail "FAIL: ACTIONS_AUTOPILOT_POLICY missing branch main" }
if($txt -notlike "*- recovery/***"){ Fail "FAIL: ACTIONS_AUTOPILOT_POLICY missing branch recovery/**" }

# Must run autopilot + smoke manifest
if($txt -notlike "*tools/enterprise-autopilot-step.ps1*"){ Fail "FAIL: ACTIONS_AUTOPILOT_POLICY must call tools/enterprise-autopilot-step.ps1" }
if($txt -notlike "*tools/smoke-checks.json*"){ Fail "FAIL: ACTIONS_AUTOPILOT_POLICY must reference tools/smoke-checks.json" }

"PASS: ACTIONS_AUTOPILOT_POLICY"
exit 0