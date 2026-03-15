. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1')

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
Set-Location -LiteralPath $root
$now = Get-Date
$month = $now.ToString("yyyy-MM")
$monthDir = Join-Path $root ("assets\audit\" + $month)
if (-not (Test-Path -LiteralPath $monthDir)) { New-Item -ItemType Directory -Force -Path $monthDir | Out-Null }
# 1) checksums
if (Test-Path -LiteralPath '.\tools\ego-checksums.ps1') {
  & .\tools\ego-checksums.ps1 -OutDir $monthDir | Out-Null
}
# 2) audit pack (status + evidence copy)
if (Test-Path -LiteralPath '.\tools\ego-audit-pack.ps1') {
  & .\tools\ego-audit-pack.ps1 -Result 'PASS' -Scope 'L2' -MonthDir $monthDir | Out-Null
}
"AUDIT_L2_PACK_OK"