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
  # naive utf8 (BOM tolerant)
  return [System.Text.Encoding]::UTF8.GetString($bytes)
}

function Normalize-Lf([string]$s){
  return ($s -replace "`r`n","`n" -replace "`r","`n")
}

$root = Get-RepoRoot -Maybe $RepoRoot

# Find download hubs (site pages) - conservative pattern
# Adjust if your hub paths differ.
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

  # Extract '## Weiter' block until next heading (## ) or EOF
  $m = [regex]::Match($raw, "(?ms)^##\s+Weiter\s*\n(.*?)(?=^\#\#\s+|\z)")
  if (-not $m.Success) {
    $fail.Add([pscustomobject]@{ File=$f.FullName; Issue="MISSING_WEITER_BLOCK"; Detail="No '## Weiter' section" })
    continue
  }

  $block = $m.Groups[1].Value

  # Count markdown links [text](url) excluding (#)
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

  # Validate link targets (repo-local): relative paths that end with .html or .md
  foreach ($lm in $links) {
    $u = $lm.Groups[1].Value.Trim()
    if ($u -eq "#") { continue }

    # Skip absolute http(s)
    if ($u -match "^(https?:)?//") { continue }
    # Skip mailto/tel
    if ($u -match "^(mailto:|tel:)") { continue }

    $u2 = $u -replace "^\{\{\s*site\.baseurl\s*\}\}", ""
    $u2 = $u2.Trim()

    # Remove anchors/query
    $u2 = ($u2 -split "#")[0]
    $u2 = ($u2 -split "\?")[0]
    $u2 = $u2.Trim()

    if (-not $u2) { continue }

    # Normalize leading slash
    if ($u2.StartsWith("/")) { $u2 = $u2.Substring(1) }

    $candidate = Join-Path $root ($u2 -replace "/","\")

    if (-not (Test-Path -LiteralPath $candidate)) {
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
  $lines.Add(("{0}`t{1}`t{2}" -f $x.File, $x.Issue, $x.Detail))
}
[System.IO.File]::WriteAllLines($out, $lines, (New-Object System.Text.UTF8Encoding($false)))

"OK: wrote report: $out"
if (@($fail).Count -gt 0) {
  throw ("FAIL: {0} issue(s) found. See: {1}" -f @($fail).Count, $out)
}