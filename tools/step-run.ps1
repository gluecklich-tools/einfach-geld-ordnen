param(
  [Parameter(Mandatory)][string]$StepPath
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

if([string]::IsNullOrWhiteSpace($StepPath)){ Fail "STOP: StepPath empty" }
$sp = $StepPath
try{ $sp = (Resolve-Path -LiteralPath $StepPath).Path } catch { Fail "STOP: StepPath not found: $StepPath" }

& $sp
$code = $LASTEXITCODE
if($code -ne 0){
  Fail "STOP: step failed (exit=$code) Step=$sp"
}

"PASS: step-run"
exit 0