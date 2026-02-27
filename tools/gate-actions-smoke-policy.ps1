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

$txt = [IO.File]::ReadAllText($wf,$enc)

if($txt -notlike "*workflow_dispatch*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing workflow_dispatch" }
if($txt -notlike "*push:*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing push trigger" }
if($txt -notlike "*recovery/***"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing recovery/** branch trigger" }
if($txt -notlike "*jobs:*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing jobs" }
if($txt -notlike "*smoke:*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY missing smoke job" }
if($txt -notlike "*tools/smoke-http.ps1*"){ Fail "FAIL: ACTIONS_SMOKE_POLICY smoke does not run tools/smoke-http.ps1" }

"PASS: ACTIONS_SMOKE_POLICY"
exit 0