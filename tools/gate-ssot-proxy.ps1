param([string]$RepoRoot = (Get-Location).Path)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if (-not $PSCommandPath) { throw 'Gate must be run from a file (pwsh -NoProfile -File ...).' }
if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'Require PowerShell 7+ (pwsh).' }
$utf8 = [System.Text.UTF8Encoding]::new($false)
$tools = Join-Path $RepoRoot 'tools'
$proxy = Join-Path $tools 'ssot-refresh-proxy.ps1'
if (-not (Test-Path -LiteralPath $proxy)) { throw ('Missing SSOT proxy tool: ' + $proxy) }
$runners = @(
  (Join-Path $tools 'ego-run.ps1'),
  (Join-Path $tools 'klaus-run.ps1')
)
foreach ($r in $runners) {
  if (-not (Test-Path -LiteralPath $r)) { throw ('Missing runner: ' + $r) }
  $t = [IO.File]::ReadAllText($r,$utf8)
  if ($t -notmatch 'EGO_SSOT_REFRESH_PROXY_CALL_V1') {
    throw ('Runner missing SSOT proxy call marker: ' + $r)
  }
}
# Optional runtime check: if env var set, proxy must execute cleanly.
if (-not [string]::IsNullOrWhiteSpace($env:EGO_SSOT_ROOT)) {
  pwsh -NoProfile -File $proxy | Out-Null
}
[pscustomobject]@{
  Gate     = 'OK'
  RepoRoot = $RepoRoot
  Proxy    = $proxy
  Runners  = $runners
  EnvSet   = (-not [string]::IsNullOrWhiteSpace($env:EGO_SSOT_ROOT))
}