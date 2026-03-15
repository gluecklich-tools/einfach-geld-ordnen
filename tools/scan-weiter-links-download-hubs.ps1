param(
  [Parameter(Mandatory=$false)] [string] $RepoRoot = ""
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-RepoRoot {
  param([string] $Maybe)
  if ($Maybe -and (Test-Path -LiteralPath $Maybe)) { return (Resolve-Path $Maybe).Path }
  try {
    $top = (& git rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -eq 0 -and $top) { return (Resolve-Path $top.Trim()).Path }
  } catch {}
  return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Read-Utf8 {
  param([Parameter(Mandatory)][string]$Path)
  return [IO.File]::ReadAllText($Path, [Text.UTF8Encoding]::new($false))
}

function Normalize-Lf {
  param([string]$Text)
  if ($null -eq $Text) { return "" }
  return ($Text -replace "`r`n","`n" -replace "`r","`n")
}

function Get-PermalinkMap {
  param([string]$Root)
  $map = @{}
  $f = Join-Path $Root "assets\audit\permalinks.tsv"
  if (-not (Test-Path -LiteralPath $f)) { return $map }
  $rows = Import-Csv -LiteralPath $f -Delimiter "`t"
  foreach($r in $rows){
    if ($r.url -and $r.source_path) {
      $u = ([string]$r.url).Trim()
      $s = ([string]$r.source_path).Trim().Replace('/','\')
      if (-not $map.ContainsKey($u)) { $map[$u] = $s }
    }
  }
  return $map
}

function Resolve-RepoTarget {
  param(
    [Parameter(Mandatory)][string]$RepoRoot,
    [Parameter(Mandatory)][string]$UrlNoBase,
    [hashtable]$PermalinkMap
  )

  $u = ([string]$UrlNoBase).Trim()
  if (-not $u) { return $false }
  if ($u.StartsWith("http://") -or $u.StartsWith("https://") -or $u.StartsWith("mailto:") -or $u.StartsWith("#")) { return $true }

  $u = $u.Split('#')[0].Split('?')[0]
  if (-not $u) { return $true }

  $rel = $u.Replace('/','\')
  $cand = Join-Path $RepoRoot $rel
  if (Test-Path -LiteralPath $cand) { return $true }

  if ($u.EndsWith(".html")) {
    $base = $u.Substring(0, $u.Length - 5)
    foreach ($ext in @(".md",".markdown")) {
      $alt = Join-Path $RepoRoot (($base + $ext).Replace('/','\'))
      if (Test-Path -LiteralPath $alt) { return $true }
    }
    foreach ($ext in @(".md",".markdown")) {
      $alt2 = Join-Path $RepoRoot ((($base + "\index" + $ext)).Replace('/','\'))
      if (Test-Path -LiteralPath $alt2) { return $true }
    }
  }

  if ($PermalinkMap) {
    $k1 = $u
    $k2 = if ($u.StartsWith("/")) { $u } else { "/" + $u }
    foreach($k in @($k1,$k2)) {
      if ($PermalinkMap.ContainsKey($k)) {
        $src = [string]$PermalinkMap[$k]
        if ($src) {
          $srcRel = $src.Replace('/','\')
          $srcAbs = Join-Path $RepoRoot $srcRel
          if (Test-Path -LiteralPath $srcAbs) { return $true }
        }
      }
    }
  }

  return $false
}

$root = Get-RepoRoot -Maybe $RepoRoot

$perma = Get-PermalinkMap -Root $root

$hubFiles = New-Object System.Collections.Generic.List[object]
$trackedHubFiles = @(
  git -C $root ls-files -- 'seiten/download-hub-*.md' 'seiten/download-hub-*.markdown' 'seiten/download-hub-*.html'
)

foreach($rel in $trackedHubFiles){
  if([string]::IsNullOrWhiteSpace($rel)){ continue }
  $full = Join-Path $root $rel
  if(-not (Test-Path -LiteralPath $full)){ continue }
  $hubFiles.Add((Get-Item -LiteralPath $full)) | Out-Null
}

$hubFiles = @($hubFiles | Sort-Object FullName -Unique)

if ($hubFiles.Count -eq 0) {
  throw "No tracked download-hub-* files found under /seiten."
}

$fail = New-Object System.Collections.Generic.List[object]

foreach($f in $hubFiles){
  $raw = Normalize-Lf (Read-Utf8 -Path $f.FullName)

  $m = [regex]::Match($raw, "(?ms)^##\s+Weiter\s*\n(.*?)(?=^\#\#\s+|\z)")
  if (-not $m.Success) {
    $fail.Add([pscustomobject]@{ File=$f.FullName; Issue="MISSING_WEITER_BLOCK"; Detail="No '## Weiter' section" })
    continue
  }

  $block = $m.Groups[1].Value
  $links = [regex]::Matches($block, '(?m)^\s*-\s*\[(?<text>[^\]]+)\]\((?<url>[^)]+)\)')
  $count = $links.Count
  if ($count -ne 3) {
    $fail.Add([pscustomobject]@{
      File=$f.FullName
      Issue="WEITER_LINK_COUNT"
      Detail=("Expected 3 links, got {0}" -f $count)
    })
  }

  foreach($lm in $links){
    $u = [string]$lm.Groups['url'].Value
    $u2 = $u.Trim()
    if (-not $u2) { continue }

    $ok = Resolve-RepoTarget -RepoRoot $root -UrlNoBase $u2 -PermalinkMap $perma
    if (-not $ok) {
      $fail.Add([pscustomobject]@{
        File=$f.FullName
        Issue="BROKEN_LINK"
        Detail=$u2
      })
    }
  }
}

$reportDir = Join-Path (Join-Path $root "_local") (Join-Path "reports" "scan_weiter_links_download_hubs")
if (-not (Test-Path -LiteralPath $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$out = Join-Path $reportDir ("weiter_links_download_hubs_{0}.tsv" -f $ts)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("file`tissue`tdetail") | Out-Null
foreach($r in $fail){
  $file = [string]$r.File
  $issue = [string]$r.Issue
  $detail = ([string]$r.Detail) -replace "`t"," " -replace "`r"," " -replace "`n"," "
  $lines.Add(("{0}`t{1}`t{2}" -f $file,$issue,$detail)) | Out-Null
}

[IO.File]::WriteAllLines($out, $lines, [Text.UTF8Encoding]::new($false))

if ($fail.Count -gt 0) {
  Write-Host ("FAIL: {0} findings" -f $fail.Count)
  Write-Host ("REPORT: {0}" -f $out)
  exit 1
}

Write-Host ("OK: wrote report: {0}" -f $out)
exit 0
