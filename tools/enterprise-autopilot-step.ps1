param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$tools = Join-Path $RepoRoot "tools"
$preflight = Join-Path $tools "enterprise-preflight.ps1"
$smokeTool = Join-Path $tools "smoke-http.ps1"
$smokeCfg  = Join-Path $tools "smoke-checks.json"

if(!(Test-Path -LiteralPath $preflight)){ Fail "Missing: tools/enterprise-preflight.ps1" }
if(!(Test-Path -LiteralPath $smokeTool)){ Fail "Missing: tools/smoke-http.ps1" }
if(!(Test-Path -LiteralPath $smokeCfg)){  Fail "Missing: tools/smoke-checks.json" }

# 1) Preflight (all gates)
& $preflight -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed (exit=$LASTEXITCODE)" }

# 2) Live smoke (200/300/400 matrix)
$cfg = Get-Content -LiteralPath $smokeCfg -Encoding UTF8 | Out-String | ConvertFrom-Json
$site = [string]$cfg.SiteUrl
$checks = @($cfg.Checks)

& $smokeTool -SiteUrl $site -Checks $checks
if($LASTEXITCODE -ne 0){ Fail "STOP: smoke-http failed (exit=$LASTEXITCODE)" }

"PASS: ENTERPRISE_AUTOPILOT_STEP"
exit 0