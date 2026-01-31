$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$repoRoot = (Resolve-Path -LiteralPath ".").Path
$enc = New-Object System.Text.UTF8Encoding($false)
function Read-Utf8NoBom {
  param([Parameter(Mandatory=$true)][string]$Path)
  [System.IO.File]::ReadAllText($Path, $enc)
}
function S {
  param([int[]]$a)
  -join ($a | ForEach-Object { [char]$_ })
}
$bs    = [char]92
$fs    = [char]47
$colon = [char]58
$us    = [char]95
$wDesk   = S @(68,101,115,107,116,111,112)      # Desktop
$wUsers  = S @(85,115,101,114,115)              # Users
$wIntern = S @(73,78,84,69,82,78)               # INTERN
$wHub    = S @(69,71,79,95,72,85,66,95,69,88,80,79,82,84)  # EGO_HUB_EXPORT
$patDeskBs   = ([string]$bs) + $wDesk + ([string]$bs)
$patDeskFs   = ([string]$fs) + $wDesk + ([string]$fs)
$patInternBs = ([string]$bs) + ([string]$us) + $wIntern + ([string]$bs)
$patInternFs = ([string]$fs) + ([string]$us) + $wIntern + ([string]$fs)
$patIntern2  = ([string]$us) + $wIntern + ([string]$bs)
$patUsers    = 'C' + ([string]$colon) + ([string]$bs) + $wUsers + ([string]$bs)
# Gate scope: real side-effects/leakage only (apply scripts + law runner + content pages)
$forbid = @(
  $wHub,
  $patDeskBs,
  $patDeskFs,
  $patInternBs,
  $patInternFs,
  $patIntern2,
  $patUsers
)
$hits = @()
$scan = @()
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'tools') -File -Filter 'apply-*.ps1' -ErrorAction SilentlyContinue
$lr = Join-Path $repoRoot (('tools' + [string]$bs + 'ego-law-run.ps1'))
if (Test-Path -LiteralPath $lr) { $scan += Get-Item -LiteralPath $lr }
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'seiten') -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue
$scan += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'pillar') -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue
foreach ($f in $scan) {
  $p = $f.FullName
  $raw = Read-Utf8NoBom -Path $p
  foreach ($pat in $forbid) {
    if ($raw.IndexOf($pat, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
      $hits += [pscustomobject]@{
        file    = $p.Replace($repoRoot + ([string]$bs), '')
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