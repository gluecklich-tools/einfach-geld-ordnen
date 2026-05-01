param(
  [string]$RootPath = '',
  [string]$ZipPath = '',
  [string]$ReportPath = '',
  [string]$JsonPath = '',
  [switch]$FailOnViolation
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

function Ensure-Dir {
  param([string]$Path)

  if ($Path -and -not (Test-Path -LiteralPath $Path -PathType Container)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Write-Utf8NoBomLF {
  param(
    [string]$Path,
    [string]$Text
  )

  $parent = Split-Path -Parent $Path
  if ($parent) { Ensure-Dir -Path $parent }

  $t = $Text.Replace("`r`n","`n").Replace("`r","`n")
  if (-not $t.EndsWith("`n")) { $t += "`n" }

  [IO.File]::WriteAllText($Path, $t, [Text.UTF8Encoding]::new($false))
}

if (-not $RootPath -and -not $ZipPath) {
  $RootPath = (Get-Location).Path
}

$baseForReports = if ($RootPath) { $RootPath } else { (Get-Location).Path }

if (-not $ReportPath) {
  $reportRoot = Join-Path $baseForReports '_local\_reports'
  Ensure-Dir -Path $reportRoot
  $ReportPath = Join-Path $reportRoot ("REPORT_LEAN_HANDOFF_ZIP_POLICY_{0}.md" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}

if (-not $JsonPath) {
  $scratchRoot = Join-Path $baseForReports '_local\_scratch'
  Ensure-Dir -Path $scratchRoot
  $JsonPath = Join-Path $scratchRoot ("LEAN_HANDOFF_ZIP_POLICY_{0}.json" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}

Ensure-Dir -Path (Split-Path -Parent $ReportPath)
Ensure-Dir -Path (Split-Path -Parent $JsonPath)

$denyRules = @(
  [pscustomobject]@{ Rule = '.git'; Regex = '(^|/)\.git(/|$)' },
  [pscustomobject]@{ Rule = 'vendor/bundle'; Regex = '(^|/)vendor/bundle(/|$)' },
  [pscustomobject]@{ Rule = '_local/_scratch'; Regex = '(^|/)_local/_scratch(/|$)' },
  [pscustomobject]@{ Rule = '_local/sync_backups'; Regex = '(^|/)_local/sync_backups(/|$)' },
  [pscustomobject]@{ Rule = 'OpenXML xl folder'; Regex = '(^|/)xl/(worksheets|styles|theme|sharedStrings|drawings)(/|$)' },
  [pscustomobject]@{ Rule = 'workbook.xml in OpenXML extract'; Regex = '(^|/)xl/workbook\.xml$' },
  [pscustomobject]@{ Rule = 'extract folder'; Regex = '(^|/)[^/]*extract[^/]*(/|$)' },
  [pscustomobject]@{ Rule = 'unpack folder'; Regex = '(^|/)[^/]*unpack[^/]*(/|$)' },
  [pscustomobject]@{ Rule = 'working folder'; Regex = '(^|/)[^/]*working[^/]*(/|$)' },
  [pscustomobject]@{ Rule = 'snapshot folder'; Regex = '(^|/)[^/]*snapshot[^/]*(/|$)' },
  [pscustomobject]@{ Rule = 'rejected stage'; Regex = '(^|/)[^/]*rejected[^/]*(/|$)' }
)

$entries = @()

if ($ZipPath) {
  if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) {
    throw "ZIP_NOT_FOUND: $ZipPath"
  }

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip = $null

  try {
    $zip = [IO.Compression.ZipFile]::OpenRead($ZipPath)
    $entries = @($zip.Entries | ForEach-Object { $_.FullName.Replace('\','/') })
  }
  finally {
    if ($zip) { $zip.Dispose() }
  }
} else {
  $RootPath = (Resolve-Path -LiteralPath $RootPath).Path
  $entries = @(Get-ChildItem -LiteralPath $RootPath -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
    $_.FullName.Substring($RootPath.Length).TrimStart('\','/').Replace('\','/')
  })
}

$violations = @()

foreach ($entry in $entries) {
  foreach ($rule in $denyRules) {
    if ($entry -match $rule.Regex) {
      $violations += [pscustomobject]@{
        Rule = [string]$rule.Rule
        Path = [string]$entry
      }
      break
    }
  }

  if ($violations.Count -ge 1000) { break }
}

$status = if ($violations.Count -eq 0) { 'PASS' } else { 'FAIL' }

$result = [pscustomobject]@{
  Status = $status
  RootPath = $RootPath
  ZipPath = $ZipPath
  ScannedEntryCount = [int]$entries.Count
  ViolationCount = [int]$violations.Count
  Violations = @($violations)
  Rules = @($denyRules)
}

Write-Utf8NoBomLF -Path $JsonPath -Text ($result | ConvertTo-Json -Depth 20)

$lines = @()
$lines += '# REPORT_LEAN_HANDOFF_ZIP_POLICY'
$lines += ''
$lines += ('STATUS={0}' -f $status)
$lines += ('ROOT_PATH={0}' -f $RootPath)
$lines += ('ZIP_PATH={0}' -f $ZipPath)
$lines += ('SCANNED_ENTRY_COUNT={0}' -f $entries.Count)
$lines += ('VIOLATION_COUNT={0}' -f $violations.Count)
$lines += ('JSON={0}' -f $JsonPath)
$lines += ''
$lines += '## Violations'
$lines += ''

if ($violations.Count -eq 0) {
  $lines += '- none'
} else {
  foreach ($v in @($violations | Select-Object -First 200)) {
    $lines += ('- {0}: {1}' -f $v.Rule,$v.Path)
  }
}

$lines += ''
$lines += '## Policy'
$lines += ''
$lines += '- Handoff ZIPs must exclude .git, vendor/bundle, _local/_scratch, _local/sync_backups, OpenXML extract folders, unpack/working/snapshot folders and rejected stages.'
$lines += '- This gate scans only. It does not delete.'

Write-Utf8NoBomLF -Path $ReportPath -Text ($lines -join "`n")

('STATUS={0}' -f $status)
('REPORT={0}' -f $ReportPath)
('JSON={0}' -f $JsonPath)
('VIOLATION_COUNT={0}' -f $violations.Count)

if ($FailOnViolation -and $violations.Count -gt 0) {
  throw ('LEAN_HANDOFF_POLICY_VIOLATION_COUNT={0}' -f $violations.Count)
}
