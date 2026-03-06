param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

$RepoRoot = (Get-Location).Path

function Get-TrackedSeitenMarkdown {
  param([Parameter(Mandatory = $true)][string]$Root)

  $gitArgs = @(
    '-C'
    $Root
    'ls-files'
    '--'
    'seiten/**/*.md'
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

$files = Get-TrackedSeitenMarkdown -Root $RepoRoot

if ($files.Count -eq 0) {
  'PASS: gate_download_hubs_strict (no tracked seiten markdown files in scope)'
  exit 0
}

$targetFiles = @(
  $files | Where-Object {
    $_.Name -match '(?i)download' -or
    $_.Name -match '(?i)hub'
  }
)

if ($targetFiles.Count -eq 0) {
  'PASS: gate_download_hubs_strict (no tracked download-hub targets found)'
  exit 0
}

$fails = New-Object System.Collections.Generic.List[string]

foreach ($file in $targetFiles) {
  $rel = $file.FullName.Substring($RepoRoot.Length + 1).Replace('\','/')
  $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8

  $hasBundle = $raw -match '(?i)bundle'
  $hasZip    = $raw -match '(?i)\.zip'
  $hasXlsx   = $raw -match '(?i)\.xlsx'
  $hasOds    = $raw -match '(?i)\.ods'
  $hasWeiter = $raw -match '(?im)^##\s+Weiter\s*$'

  if (-not $hasWeiter) {
    $fails.Add(('{0}: missing ## Weiter block' -f $rel))
  }

  if ($hasBundle -and (-not $hasZip)) {
    $fails.Add(('{0}: bundle mention without .zip link' -f $rel))
  }

  if ($hasBundle -and (-not ($hasXlsx -or $hasOds))) {
    $fails.Add(('{0}: bundle mention without xlsx/ods reference' -f $rel))
  }
}

if ($fails.Count -gt 0) {
  'FAIL: gate_download_hubs_strict'
  $fails | ForEach-Object { ' - ' + $_ }
  exit 2
}

'PASS: gate_download_hubs_strict'
exit 0