param(
  [Parameter(Mandatory=$false)] [string] $RepoRoot = ""
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Get-RepoRoot {
  param([string] $Maybe)
  if ($Maybe -and (Test-Path -LiteralPath $Maybe)) { return (Resolve-Path $Maybe).Path }
  return (Resolve-Path ".").Path
}

function Read-Utf8 {
  param([Parameter(Mandatory)][string]$Path)
  $bytes = [System.IO.File]::ReadAllBytes($Path)
  return [System.Text.Encoding]::UTF8.GetString($bytes)
}

function Normalize-Lf([string]$s){
  return ($s -replace "`r`n","`n" -replace "`r","`n")
}

function Try-Find-PermalinkMap {
  param([string]$StartDir)
  # Look upwards for _INTERN\governance\inventory\REPO_PERMALINK_MAP.ndjson
  $cur = (Resolve-Path $StartDir).Path
  for ($i=0; $i -lt 8; $i++) {
    $cand = Join-Path $cur "_INTERN\governance\inventory\REPO_PERMALINK_MAP.ndjson"
    if (Test-Path -LiteralPath $cand) { return $cand }
    $parent = Split-Path -Parent $cur
    if (-not $parent -or $parent -eq $cur) { break }
    $cur = $parent
  }
  return ""
}

function Load-PermalinkMap {
  param([string]$Path)
  # expects ndjson lines with fields containing permalink + source/path
  $map = @{}
  if (-not $Path) { return $map }
  foreach ($line in Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue) {
    $t = $line.Trim()
    if (-not $t) { continue }
    try {
      $o = $t | ConvertFrom-Json
      $p = $null
      $s = $null
      if ($o.permalink) { $p = [string]$o.permalink }
      elseif ($o.Permalink) { $p = [string]$o.Permalink }
      if ($o.source) { $s = [string]$o.source }
      elseif ($o.Source) { $s = [string]$o.Source }
      elseif ($o.path) { $s = [string]$o.path }
      elseif ($o.Path) { $s = [string]$o.Path }
      if ($p -and $s) {
        if (-not $map.ContainsKey($p)) { $map[$p] = $s }
      }
    } catch { }
  }
  return $map
}

function Resolve-RepoTarget {
  param(
    [Parameter(Mandatory)][string]$RepoRoot,
    [Parameter(Mandatory)][string]$UrlNoBase,  # like "seiten/downloads.html"
    [hashtable]$PermalinkMap
  )

  $u = $UrlNoBase.Trim()
  if (-not $u) { return $false }

  if ($u.StartsWith("/")) { $u = $u.Substring(1) }

  # normalize separators
  $rel = $u.Replace('/','\')
  $cand = Join-Path $RepoRoot $rel
  if (Test-Path -LiteralPath $cand) { return $true }

  # If .html permalink, try source extensions
  if ($u.ToLowerInvariant().EndsWith(".html")) {
    $base = $u.Substring(0, $u.Length - 5) # remove .html
    foreach ($ext in @(".md",".markdown")) {
      $alt = Join-Path $RepoRoot (($base + $ext).Replace('/','\'))
      if (Test-Path -LiteralPath $alt) { return $true }
    }
    # also try directory index.md for /foo.html -> /foo/index.md
    foreach ($ext in @(".md",".markdown")) {
      $alt2 = Join-Path $RepoRoot ((($base + "\index" + $ext)).Replace('/','\'))
      if (Test-Path -LiteralPath $alt2) { return $true }
    }
  }

  # Permalink map lookup (supports leading slash in keys)
  if ($PermalinkMap -and $PermalinkMap.Count -gt 0) {
    $k1 = "/" + $u
    $k2 = $u
    $src = $null
    if ($PermalinkMap.ContainsKey($k1)) { $src = $PermalinkMap[$k1] }
    elseif ($PermalinkMap.ContainsKey($k2)) { $src = $PermalinkMap[$k2] }
    if ($src) {
      $srcRel = $src.Replace('/','\')
      $srcAbs = Join-Path $RepoRoot $srcRel
      if (Test-Path -LiteralPath $srcAbs) { return $true }
    }
  }

  return $false
}

$root = Get-RepoRoot -Maybe $RepoRoot

# preload permalink map if available
$mapPath = Try-Find-PermalinkMap -StartDir $root
$perma = Load-PermalinkMap -Path $mapPath

$hubFiles = @()
$hubFiles += Get-ChildItem -LiteralPath (Join-Path $root "seiten") -Filter "download-hub-*.md" -File -ErrorAction SilentlyContinue
$hubFiles += Get-ChildItem -LiteralPath (Join-Path $root "seiten") -Filter "download-hub-*.markdown" -File -ErrorAction SilentlyContinue
$hubFiles += Get-ChildItem -LiteralPath (Join-Path $root "seiten") -Filter "download-hub-*.html" -File -ErrorAction SilentlyContinue

if (@($hubFiles).Count -eq 0) {
  throw "No download-hub-* files found under /seiten. Adjust patterns in tools/scan-weiter-links-download-hubs.ps1."
}

$fail = New-Object System.Collections.Generic.List[object]

foreach ($f in $hubFiles) {
  $raw = Normalize-Lf (Read-Utf8 -Path $f.FullName)

  $m = [regex]::Match($raw, "(?ms)^##\s+Weiter\s*\n(.*?)(?=^\#\#\s+|\z)")
  if (-not $m.Success) {
    $fail.Add([pscustomobject]@{ File=$f.FullName; Issue="MISSING_WEITER_BLOCK"; Detail="No '## Weiter' section" })
    continue
  }

  $block = $m.Groups[1].Value

  $links = [regex]::Matches($block, "\[[^\]]+\]\(([^)]+)\)")
  $count = 0
  foreach ($lm in $links) {
    $u = $lm.Groups[1].Value.Trim()
    if ($u -eq "#") { continue }
    $count++
  }

  if ($count -ne 3) {
    $fail.Add([pscustomobject]@{
      File=$f.FullName
      Issue="WEITER_LINK_COUNT"
      Detail=("Expected 3 links, got {0}" -f $count)
    })
  }

  foreach ($lm in $links) {
    $u = $lm.Groups[1].Value.Trim()
    if ($u -eq "#") { continue }
    if ($u -match "^(https?:)?//") { continue }
    if ($u -match "^(mailto:|tel:)") { continue }

    $u2 = $u -replace "^\{\{\s*site\.baseurl\s*\}\}", ""
    $u2 = $u2.Trim()
    $u2 = ($u2 -split "#")[0]
    $u2 = ($u2 -split "\?")[0]
    $u2 = $u2.Trim()
    if (-not $u2) { continue }

    $ok = Resolve-RepoTarget -RepoRoot $root -UrlNoBase $u2 -PermalinkMap $perma
    if (-not $ok) {
      $fail.Add([pscustomobject]@{
        File=$f.FullName
        Issue="BROKEN_LINK_TARGET"
        Detail=("Target not found: {0}" -f $u)
      })
    }
  }
}

$reportDir = Join-Path (Join-Path $root "_local") (Join-Path "reports" "scan_weiter_links_download_hubs")
if (-not (Test-Path -LiteralPath $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$out = Join-Path $reportDir ("weiter_links_download_hubs_{0}.tsv" -f $ts)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("File`tIssue`tDetail")
foreach ($x in $fail) {
  $lines.Add([string]::Format("{0}`t{1}`t{2}", $x.File, $x.Issue, $x.Detail))
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = (($lines | ForEach-Object { $_ }) -join "`n") + "`n"
[System.IO.File]::WriteAllText($out, $content, $utf8NoBom)

"OK: wrote report: $out"
[int]$issueCount = @($fail).Count
if ($issueCount -gt 0) {
  "FAIL: " + $issueCount + " issue(s) found. See: " + $out
  exit 2
}
exit 0