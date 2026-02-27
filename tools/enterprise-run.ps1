param(
  [Parameter(Mandatory)][string]$StepPath
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$toolsRoot = $PSScriptRoot
$repoRoot  = Split-Path -Parent $toolsRoot

$preflight = Join-Path $toolsRoot "enterprise-preflight.ps1"
$stepRun   = Join-Path $toolsRoot "step-run.ps1"

if(!(Test-Path -LiteralPath $preflight)){ Fail "STOP: missing preflight: $preflight" }
if(!(Test-Path -LiteralPath $stepRun)){   Fail "STOP: missing step-run:  $stepRun" }

if([string]::IsNullOrWhiteSpace($StepPath)){ Fail "STOP: StepPath empty" }
$sp = $StepPath
try{ $sp = (Resolve-Path -LiteralPath $StepPath).Path } catch { Fail "STOP: StepPath not found: $StepPath" }

# Preflight FIRST
& $preflight -RepoRoot $repoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed (exit=$LASTEXITCODE)" }

# Step-run
& $stepRun -StepPath $sp
$code = $LASTEXITCODE
if($code -ne 0){ Fail "STOP: step-run failed (exit=$code) Step=$sp" }

"PASS: enterprise-run"
exit 0