$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 > $null
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$repo = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $repo
$gate = Join-Path $repo "tools\gate_download_hubs_strict.ps1"
if (-not (Test-Path -LiteralPath $gate)) { throw "Missing required gate: $gate" }
& $gate
"PASS: ego-run completed (required gates OK)."