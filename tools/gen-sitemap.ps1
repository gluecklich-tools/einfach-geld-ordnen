param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

$RepoRoot = (Get-Location).Path

function Get-TrackedMarkdownTargets {
  param([Parameter(Mandatory = $true)][string]$Root)

  $gitArgs = @(
    '-C'
    $Root
    'ls-files'
    '--'
    'seiten/**/*.md'
    'pillar/**/*.md'
    '*.md'
  )

  $trackedRelPaths = @(& git @gitArgs)
  if ($LASTEXITCODE -ne 0) {
    throw 'git ls-files failed.'
  }

  $targets = @(
    foreach ($rel in $trackedRelPaths | Sort-Object -Unique) {
      if ([string]::IsNullOrWhiteSpace($rel)) { continue }

      $full = Join-Path $Root ($rel -replace '/', '\')
      if (Test-Path -LiteralPath $full -PathType Leaf) {
        Get-Item -LiteralPath $full
      }
    }
  )

  return @($targets | Sort-Object FullName -Unique)
}

function Get-FrontmatterValue {
  param(
    [Parameter(Mandatory = $true)][string]$Raw,
    [Parameter(Mandatory = $true)][string]$Key
  )

  $m = [regex]::Match($Raw, "(?im)^\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$")
  if ($m.Success) {
    return $m.Groups[1].Value.Trim().Trim('"').Trim("'")
  }
  return $null
}

$files = Get-TrackedMarkdownTargets -Root $RepoRoot

if ($files.Count -eq 0) {
  'PASS: gen-sitemap (no tracked markdown files in scope)'
  exit 0
}

$fails = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
  $rel = $file.FullName.Substring($RepoRoot.Length + 1).Replace('\','/')
  $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8

  if (-not ($raw -match '(?s)^---\s*?\r?\n.*?\r?\n---')) {
    continue
  }

  $permalink = Get-FrontmatterValue -Raw $raw -Key 'permalink'
  if ([string]::IsNullOrWhiteSpace($permalink)) {
    continue
  }

  if ($permalink -notmatch '\.html$') {
    $fails.Add(('{0}: permalink does not end with .html :: {1}' -f @($rel, $permalink)))
  }

  if ($permalink -match '\s') {
    $fails.Add(('{0}: permalink contains whitespace :: {1}' -f @($rel, $permalink)))
  }
}

if ($fails.Count -gt 0) {
  'FAIL: gen-sitemap'
  $fails | ForEach-Object { ' - ' + $_ }
  exit 2
}

'PASS: gen-sitemap'
exit 0