param(
  [string]$SsotRoot = $env:EGO_SSOT_ROOT
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if (-not $PSCommandPath) { throw 'Proxy must be run from a file (pwsh -NoProfile -File ...).' }
if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'Require PowerShell 7+ (pwsh).' }
if ([string]::IsNullOrWhiteSpace($SsotRoot)) {
  throw 'Missing SsotRoot. Provide -SsotRoot or set env:EGO_SSOT_ROOT.'
}
if (-not (Test-Path -LiteralPath $SsotRoot)) {
  throw ('SsotRoot not found: ' + $SsotRoot)
}
$utf8 = [System.Text.UTF8Encoding]::new($false)
# Find ssot-refresh.ps1 near SsotRoot (same folder, parent, or sibling tools)
$candidates = @()
$candidates += (Join-Path $SsotRoot 'ssot-refresh.ps1')
$candidates += (Join-Path (Split-Path -Parent $SsotRoot) 'ssot-refresh.ps1')
$candidates += (Join-Path (Split-Path -Parent $SsotRoot) 'tools\ssot-refresh.ps1')
$refresh = $null
foreach ($c in $candidates) { if (Test-Path -LiteralPath $c) { $refresh = $c; break } }
if (-not $refresh) {
  # last resort: search one level up
  $base = Split-Path -Parent $SsotRoot
  $hit = Get-ChildItem -LiteralPath $base -Recurse -File -Filter 'ssot-refresh.ps1' -ErrorAction SilentlyContinue |
    Sort-Object FullName |
    Select-Object -First 1
  if ($hit) { $refresh = $hit.FullName }
}
if (-not $refresh) { throw ('ssot-refresh.ps1 not found near SsotRoot: ' + $SsotRoot) }
Write-Host ('SSOT Refresh Script: ' + $refresh)
Write-Host ('SSOT Root:          ' + $SsotRoot)
pwsh -NoProfile -File $refresh -SsotRoot $SsotRoot