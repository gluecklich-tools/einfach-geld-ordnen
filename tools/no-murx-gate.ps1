$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$repoRoot = (Resolve-Path -LiteralPath ".").Path
$enc = New-Object System.Text.UTF8Encoding($false)
function Read-Utf8NoBom {
  param([Parameter(Mandatory=$true)][string]$Path)
  [System.IO.File]::ReadAllText($Path, $enc)
}
# Literal patterns (NO regex). Use IndexOf -> cannot throw on "\" etc.
$forbid = @(
  'EGO_HUB_EXPORT',
  '\Desktop\',
  '/Desktop/',
  '\_INTERN',
  '/_INTERN',
  'SSOT',
  '_local\patch_backups',
  '_local/patch_backups'
)
$hits = @()
# scan only scripts + markdown (fast + relevant)
$scan = @()
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'tools')  -Recurse -File -Filter '*.ps1' -ErrorAction SilentlyContinue
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'seiten') -Recurse -File -Filter '*.md'  -ErrorAction SilentlyContinue
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'pillar') -Recurse -File -Filter '*.md'  -ErrorAction SilentlyContinue
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