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
if(!(Test-Path -LiteralPath $wf)){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing enterprise-laws.yml" }

$ap = Join-Path $RepoRoot "tools/enterprise-autopilot-step.ps1"
if(!(Test-Path -LiteralPath $ap)){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing tools/enterprise-autopilot-step.ps1" }

$cfg = Join-Path $RepoRoot "tools/smoke-checks.json"
if(!(Test-Path -LiteralPath $cfg)){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing tools/smoke-checks.json" }

$txt = [IO.File]::ReadAllText($wf,$enc)

# Trigger-Pinning bleibt Pflicht
if($txt -notlike "*workflow_dispatch*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing workflow_dispatch" }
if($txt -notlike "*push:*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing push trigger" }
if($txt -notlike "*- main*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing branch main" }
if($txt -notlike "*- recovery/***"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing branch recovery/**" }

# Neue Architektur: smoke läuft im Autopilot (nicht als separater job)
if($txt -notlike "*jobs:*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing jobs" }
if($txt -notlike "*autopilot:*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing autopilot job" }
if($txt -notlike "*tools/enterprise-autopilot-step.ps1*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY must call tools/enterprise-autopilot-step.ps1" }

# Harte Referenz: smoke-checks.json muss im Workflow vorkommen (Marker gegen Drift)
if($txt -notlike "*smoke-checks.json*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing marker smoke-checks.json" }

"PASS: ACTIONS_SMOKE_POLICY (autopilot contains smoke via smoke-checks.json)"
exit 0