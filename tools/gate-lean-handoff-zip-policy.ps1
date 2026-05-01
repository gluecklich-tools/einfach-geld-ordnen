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
  [ordered]@{ rule='.git'; regex='(^|/)\.git(/|$)' },
  [ordered]@{ rule='vendor/bundle'; regex='(^|/)vendor/bundle(/|$)' },
  [ordered]@{ rule='_local/_scratch'; regex='(^|/)_local/_scratch(/|$)' },
  [ordered]@{ rule='_local/sync_backups'; regex='(^|/)_local/sync_backups(/|$)' },
  [ordered]@{ rule='OpenXML xl folder'; regex='(^|/)xl/(worksheets|styles|theme|sharedStrings|workbook\.xml|drawings)(/|$)' },
  [ordered]@{ rule='extract folder'; regex='(^|/)[^/]*extract[^/]*(/|$)' },
  [ordered]@{ rule='unpack folder'; regex='(^|/)[^/]*unpack[^/]*(/|$)' },
  [ordered]@{ rule='working folder'; regex='(^|/)[^/]*working[^/]*(/|$)' },
  [ordered]@{ rule='snapshot folder'; regex='(^|/)[^/]*snapshot[^/]*(/|$)' },
  [ordered]@{ rule='rejected stage'; regex='(^|/)[^/]*rejected[^/]*(/|$)' }
)

$entries = New-Object System.Collections.Generic.List[string]

if ($ZipPath) {
  if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) {
    throw "ZIP_NOT_FOUND: $ZipPath"
  }

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip = $null
  try {
    $zip = [IO.Compression.ZipFile]::OpenRead($ZipPath)
    foreach ($entry in $zip.Entries) {
      $entries.Add($entry.FullName.Replace('\','/'))
    }
  }
  finally {
    if ($zip) { $zip.Dispose() }
  }
} else {
  $RootPath = (Resolve-Path -LiteralPath $RootPath).Path
  Get-ChildItem -LiteralPath $RootPath -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
    $rel = $_.FullName.Substring($RootPath.Length).TrimStart('\','/')
    $entries.Add($rel.Replace('\','/'))
  }
}

$violations = New-Object System.Collections.Generic.List[object]

foreach ($entry in $entries) {
  foreach ($rule in $denyRules) {
    if ($entry -match $rule.regex) {
      $violations.Add([ordered]@{
        rule = $rule.rule
        path = $entry
      })
      break
    }
  }

  if ($violations.Count -ge 1000) { break }
}

$status = if ($violations.Count -eq 0) { 'PASS' } else { 'FAIL' }

$result = [ordered]@{
  status = $status
  root_path = $RootPath
  zip_path = $ZipPath
  scanned_entry_count = $entries.Count
  violation_count = $violations.Count
  violations = @($violations)
  rules = @($denyRules)
}

[IO.File]::WriteAllText($JsonPath, ($result | ConvertTo-Json -Depth 20), [Text.UTF8Encoding]::new($false))

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# REPORT_LEAN_HANDOFF_ZIP_POLICY')
$lines.Add('')
$lines.Add(("STATUS={0}" -f $status))
$lines.Add(("ROOT_PATH={0}" -f $RootPath))
$lines.Add(("ZIP_PATH={0}" -f $ZipPath))
$lines.Add(("SCANNED_ENTRY_COUNT={0}" -f $entries.Count))
$lines.Add(("VIOLATION_COUNT={0}" -f $violations.Count))
$lines.Add(("JSON={0}" -f $JsonPath))
$lines.Add('')
$lines.Add('## Violations')
$lines.Add('')
if ($violations.Count -eq 0) {
  $lines.Add('- none')
} else {
  foreach ($v in @($violations | Select-Object -First 200)) {
    $lines.Add(('- {0}: {1}' -f $v.rule,$v.path))
  }
}
$lines.Add('')
$lines.Add('## Policy')
$lines.Add('')
$lines.Add('- Handoff ZIPs must exclude .git, vendor/bundle, _local/_scratch, _local/sync_backups, OpenXML extract folders, unpack/working/snapshot folders and rejected stages.')
$lines.Add('- This gate scans only. It does not delete.')

[IO.File]::WriteAllText($ReportPath, (($lines.ToArray()) -join "`n") + "`n", [Text.UTF8Encoding]::new($false))

("STATUS={0}" -f $status)
("REPORT={0}" -f $ReportPath)
("JSON={0}" -f $JsonPath)
("VIOLATION_COUNT={0}" -f $violations.Count)

if ($FailOnViolation -and $violations.Count -gt 0) {
  throw ("LEAN_HANDOFF_POLICY_VIOLATION_COUNT={0}" -f $violations.Count)
}
