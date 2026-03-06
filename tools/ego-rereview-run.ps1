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
  )

  $trackedRelPaths = @(& git @gitArgs)
  if ($LASTEXITCODE -ne 0) {
    throw 'git ls-files failed.'
  }

  $targets = @(
    foreach ($rel in $trackedRelPaths) {
      if ([string]::IsNullOrWhiteSpace($rel)) { continue }

      $full = Join-Path $Root ($rel -replace '/', '\')
      if (Test-Path -LiteralPath $full -PathType Leaf) {
        Get-Item -LiteralPath $full
      }
    }
  )

  return @($targets | Sort-Object FullName -Unique)
}

$files = Get-TrackedMarkdownTargets -Root $RepoRoot

if ($files.Count -eq 0) {
  'PASS: ego-rereview-run (no tracked markdown files in scope)'
  exit 0
}

$fails = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
  $rel = $file.FullName.Substring($RepoRoot.Length + 1).Replace('\','/')
  $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8

  $hasWeiter = $raw -match '(?im)^##\s+Weiter\s*$'
  $weiterLinks = [regex]::Matches($raw, '(?im)^\s*-\s*\[[^\]]+\]\([^)]+\)\s*$')

  if ($hasWeiter) {
    if ($weiterLinks.Count -lt 3) {
      $fails.Add(('{0}: ## Weiter block has fewer than 3 markdown links' -f $rel))
    }
  }

  if ($raw -match '(?i)\(#\)') {
    $fails.Add(('{0}: contains placeholder link (#)' -f $rel))
  }
}

if ($fails.Count -gt 0) {
  'FAIL: ego-rereview-run'
  $fails | ForEach-Object { ' - ' + $_ }
  exit 2
}

'PASS: ego-rereview-run'
exit 0