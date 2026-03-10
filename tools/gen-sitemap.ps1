param(
  [Parameter(Mandatory = $false)]
  [string]$Repo = (Get-Location).Path,

  [Parameter(Mandatory = $false)]
  [string]$SiteBase = "https://gluecklich-tools.github.io/einfach-geld-ordnen"
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

function Get-TrackedPublicTargets {
  param([Parameter(Mandatory = $true)][string]$Root)

  $trackedRelPaths = @(& git -C $Root ls-files)
  if ($LASTEXITCODE -ne 0) {
    throw 'git ls-files failed.'
  }

  $targets = @(
    foreach ($rel in $trackedRelPaths | Sort-Object -Unique) {
      if ([string]::IsNullOrWhiteSpace($rel)) { continue }

      $unixRel = $rel.Replace('\','/')

      $isPublic =
        ($unixRel -eq 'index.md') -or
        ($unixRel -like 'seiten/*.md') -or
        ($unixRel -like 'seiten/**/*.md') -or
        ($unixRel -like 'pillar/*.md') -or
        ($unixRel -like 'pillar/**/*.md')

      if (-not $isPublic) { continue }

      $full = Join-Path $Root ($unixRel -replace '/', '\')
      if (Test-Path -LiteralPath $full -PathType Leaf) {
        Get-Item -LiteralPath $full
      }
    }
  )

  return @($targets | Sort-Object FullName -Unique)
}

function Get-FrontmatterBlock {
  param([Parameter(Mandatory = $true)][string]$Raw)

  $m = [regex]::Match($Raw, '(?s)^---\s*?\r?\n(.*?)\r?\n---')
  if ($m.Success) {
    return $m.Groups[1].Value
  }
  return $null
}

function Get-FrontmatterValue {
  param(
    [Parameter(Mandatory = $true)][string]$Raw,
    [Parameter(Mandatory = $true)][string]$Key
  )

  $fm = Get-FrontmatterBlock -Raw $Raw
  if ([string]::IsNullOrWhiteSpace($fm)) {
    return $null
  }

  $m = [regex]::Match($fm, ("(?im)^\s*{0}\s*:\s*(.+?)\s*$" -f [regex]::Escape($Key)))
  if ($m.Success) {
    return $m.Groups[1].Value.Trim().Trim('"').Trim("'")
  }
  return $null
}

function Test-SitemapFalse {
  param([Parameter(Mandatory = $true)][string]$Raw)

  $value = Get-FrontmatterValue -Raw $Raw -Key 'sitemap'
  if ([string]::IsNullOrWhiteSpace($value)) {
    return $false
  }

  return ($value.Trim().ToLowerInvariant() -eq 'false')
}

function Xml-Escape {
  param([Parameter(Mandatory = $true)][string]$Value)

  $escaped = $Value
  $escaped = $escaped.Replace('&', '&amp;')
  $escaped = $escaped.Replace('<', '&lt;')
  $escaped = $escaped.Replace('>', '&gt;')
  $escaped = $escaped.Replace('"', '&quot;')
  $escaped = $escaped.Replace("'", '&apos;')
  return $escaped
}

$files = Get-TrackedPublicTargets -Root $Repo

$urls = New-Object System.Collections.Generic.List[string]
$fails = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
  $rel = $file.FullName.Substring($Repo.Length + 1).Replace('\','/')
  $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8

  $fm = Get-FrontmatterBlock -Raw $raw
  if ([string]::IsNullOrWhiteSpace($fm)) {
    continue
  }

  if (Test-SitemapFalse -Raw $raw) {
    continue
  }

  $permalink = Get-FrontmatterValue -Raw $raw -Key 'permalink'
  if ([string]::IsNullOrWhiteSpace($permalink)) {
    continue
  }

  $isRoot = ($permalink -eq '/')
  $isHtml = ($permalink -match '\.html$')

  if (-not ($isRoot -or $isHtml)) {
    $fails.Add(('{0}: permalink is neither / nor .html :: {1}' -f @($rel, $permalink))) | Out-Null
    continue
  }

  if ($permalink -match '\s') {
    $fails.Add(('{0}: permalink contains whitespace :: {1}' -f @($rel, $permalink))) | Out-Null
    continue
  }

  $absolute = $SiteBase.TrimEnd('/') + $permalink
  $urls.Add($absolute) | Out-Null
}

if ($fails.Count -gt 0) {
  'FAIL: gen-sitemap'
  $fails | ForEach-Object { ' - ' + $_ }
  exit 2
}

$uniqueUrls = @($urls | Sort-Object -Unique)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('<?xml version="1.0" encoding="UTF-8"?>') | Out-Null
$lines.Add('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">') | Out-Null

foreach ($u in $uniqueUrls) {
  $lines.Add('  <url>') | Out-Null
  $lines.Add(('    <loc>{0}</loc>' -f (Xml-Escape -Value $u))) | Out-Null
  $lines.Add('  </url>') | Out-Null
}

$lines.Add('</urlset>') | Out-Null

[string]::Join("`r`n", $lines)
exit 0