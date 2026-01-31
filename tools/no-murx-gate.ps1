$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$repoRoot = (Resolve-Path -LiteralPath ".").Path
$enc = New-Object System.Text.UTF8Encoding($false)
function Read-Utf8NoBom {
  param([Parameter(Mandatory=$true)][string]$Path)
  [System.IO.File]::ReadAllText($Path, $enc)
}
# IMPORTANT:
# This gate is about REAL side-effects / leakage, not about internal wording in other gate scripts.
# Therefore: scan only apply scripts + law runner + content pages.
# Literal patterns (NO regex). IndexOf cannot throw on "\".
$forbid = @(
  'EGO_HUB_EXPORT',
  '\Desktop\',
  '/Desktop/',
  '\_INTERN\',
  '/_INTERN/',
  'C:\Users\'
)
$hits = @()
$scan = @()
# Apply scripts only
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'tools') -File -Filter 'apply-*.ps1' -ErrorAction SilentlyContinue
# The law runner itself must be clean
$lr = Join-Path $repoRoot 'tools\ego-law-run.ps1'
if (Test-Path -LiteralPath $lr) { $scan += Get-Item -LiteralPath $lr }
# Content pages
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'seiten') -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'pillar') -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue
foreach ($f in $scan) {
  $p = $f.FullName
  $raw = Read-Utf8NoBom -Path $p
  foreach ($pat in $forbid) {
    if ($raw.IndexOf($pat, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
      $hits += [pscustomobject]@{
        file    = $p.Replace($repoRoot + '\','')
        pattern = $pat
      }
    }
  }
}
if ($hits.Count -gt 0) {
  "FAIL: no-murx gate hit(s):"
  $hits | Sort-Object file, pattern | Format-Table -AutoSize
  throw "NO_MURX_FAIL"
}
"PASS: no-murx gate OK."