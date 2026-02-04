param(
  [string]$SsotRoot = $env:EGO_SSOT_ROOT
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if ($IsWindows) { try { chcp 65001 | Out-Null } catch {} }
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

if ([string]::IsNullOrWhiteSpace($SsotRoot)) {
  throw 'env:EGO_SSOT_ROOT not set. Example: $env:EGO_SSOT_ROOT=<set env var EGO_SSOT_ROOT>'
}

pwsh -NoProfile -File (Join-Path $PSScriptRoot 'ssot-refresh-proxy.ps1')
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'ego-run.ps1')
'OK: klaus-go OK (SSOT proxy + ego-run green).'