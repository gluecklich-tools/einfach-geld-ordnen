param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Invoke-Gate([string]$p){
  if(!(Test-Path -LiteralPath $p)){ throw "Missing gate: $p" }
  & $p -RepoRoot $RepoRoot
  if($LASTEXITCODE -ne 0){ throw "GATE_FAIL: $p (exit=$LASTEXITCODE)" }
}

$tools = Join-Path $RepoRoot "tools"
Invoke-Gate (Join-Path $tools "gate-no-regex-patch-v1.ps1")
Invoke-Gate (Join-Path $tools "gate-ps-parser-all-tools.ps1")
Invoke-Gate (Join-Path $tools "gate-no-absolute-paths-in-tools.ps1")
Invoke-Gate (Join-Path $tools "gate-actions-trigger-policy.ps1")
Invoke-Gate (Join-Path $tools "gate-actions-smoke-policy.ps1")
Invoke-Gate (Join-Path $tools "gate-actions-autopilot-policy.ps1")
Invoke-Gate (Join-Path $tools "gate-no-inner-single-quotes-in-command.ps1")
Invoke-Gate (Join-Path $tools "gate-no-console-transcripts.ps1")
Invoke-Gate (Join-Path $tools "gate-no-format-brace-traps.ps1")
Invoke-Gate (Join-Path $tools "gate-param-must-be-first.ps1")

"PASS: ENTERPRISE_PREFLIGHT"
exit 0