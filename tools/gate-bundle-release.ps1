param(
  [Parameter(Mandatory=$false)]
  [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-RepoRoot {
  if (-not [string]::IsNullOrWhiteSpace($RepoRoot)) { return (Resolve-Path -LiteralPath $RepoRoot).Path }
  $d = Resolve-Path -LiteralPath (Get-Location).Path
  while ($true) {
    if (Test-Path -LiteralPath (Join-Path $d.Path ".git")) { return $d.Path }
    $p = Split-Path -Parent $d.Path
    if ($p -eq $d.Path -or [string]::IsNullOrWhiteSpace($p)) { throw "RepoRoot nicht gefunden." }
    $d = Resolve-Path -LiteralPath $p
  }
}

$root = Get-RepoRoot

$expected = @(
  (Join-Path $root "downloads\bundles\EGO_Freebie_Bundle.zip"),
  (Join-Path $root "downloads\bundles\EGO_Pro_Bundle.zip"),
  (Join-Path $root "downloads\bundles\EGO_Vollversion_Bundle.zip")
)

$missing = @()
$zero    = @()

foreach ($p in $expected) {
  if (-not (Test-Path -LiteralPath $p)) { $missing += $p; continue }
  $len = (Get-Item -LiteralPath $p).Length
  if ($len -le 0) { $zero += $p }
}

if ($missing.Count -gt 0 -or $zero.Count -gt 0) {
  if ($missing.Count -gt 0) { Write-Host ("FAIL: missing bundle zip(s):
" + ($missing -join "
")) }
  if ($zero.Count -gt 0)    { Write-Host ("FAIL: zero-length bundle zip(s):
" + ($zero -join "
")) }
  throw "gate-bundle-release: FAIL"
}

Write-Host "PASS: gate-bundle-release (bundle zips present)"