param(
  [string]$RootPath = (Get-Location).Path,
  [string]$ReportPath = '',
  [string]$JsonPath = '',
  [int]$LocalWarnMB = 1024,
  [int]$ScratchWarnMB = 512,
  [int]$ProjectWarnMB = 2048,
  [switch]$FailOnOverLimit
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

function Get-DirSizeBytes {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return 0L }

  $sum = 0L
  Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
    $sum += [int64]$_.Length
  }
  return $sum
}

function To-MB {
  param([int64]$Bytes)
  return [math]::Round(($Bytes / 1MB), 2)
}

$RootPath = (Resolve-Path -LiteralPath $RootPath).Path

if (-not $ReportPath) {
  $reportRoot = Join-Path $RootPath '_local\_reports'
  Ensure-Dir -Path $reportRoot
  $ReportPath = Join-Path $reportRoot ("REPORT_PROJECT_HOUSEKEEPING_SIZE_GATE_{0}.md" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}

if (-not $JsonPath) {
  $scratchRoot = Join-Path $RootPath '_local\_scratch'
  Ensure-Dir -Path $scratchRoot
  $JsonPath = Join-Path $scratchRoot ("PROJECT_HOUSEKEEPING_SIZE_GATE_{0}.json" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}

Ensure-Dir -Path (Split-Path -Parent $ReportPath)
Ensure-Dir -Path (Split-Path -Parent $JsonPath)

$localPath = Join-Path $RootPath '_local'
$scratchPath = Join-Path $localPath '_scratch'
$syncBackupsPath = Join-Path $localPath 'sync_backups'
$vendorBundlePath = Join-Path $RootPath 'vendor\bundle'
$gitPath = Join-Path $RootPath '.git'

$sizeItems = @(
  [ordered]@{ name='root'; path=$RootPath; bytes=(Get-DirSizeBytes -Path $RootPath) },
  [ordered]@{ name='_local'; path=$localPath; bytes=(Get-DirSizeBytes -Path $localPath) },
  [ordered]@{ name='_local/_scratch'; path=$scratchPath; bytes=(Get-DirSizeBytes -Path $scratchPath) },
  [ordered]@{ name='_local/sync_backups'; path=$syncBackupsPath; bytes=(Get-DirSizeBytes -Path $syncBackupsPath) },
  [ordered]@{ name='vendor/bundle'; path=$vendorBundlePath; bytes=(Get-DirSizeBytes -Path $vendorBundlePath) },
  [ordered]@{ name='.git'; path=$gitPath; bytes=(Get-DirSizeBytes -Path $gitPath) }
)

$topScratchDirs = @()
if (Test-Path -LiteralPath $scratchPath -PathType Container) {
  $topScratchDirs = Get-ChildItem -LiteralPath $scratchPath -Force -Directory -ErrorAction SilentlyContinue |
    ForEach-Object {
      [ordered]@{
        name = $_.Name
        path = $_.FullName
        bytes = Get-DirSizeBytes -Path $_.FullName
        mb = To-MB -Bytes (Get-DirSizeBytes -Path $_.FullName)
      }
    } |
    Sort-Object bytes -Descending |
    Select-Object -First 40
}

$suspectPatterns = @(
  '*extract*',
  '*unpack*',
  '*working*',
  '*snapshot*',
  '*FORMULA_VERIFY*',
  '*DIAGNOSE*',
  '*before_extract*',
  '*after_extract*'
)

$suspectDirs = @()
if (Test-Path -LiteralPath $scratchPath -PathType Container) {
  foreach ($pattern in $suspectPatterns) {
    $suspectDirs += Get-ChildItem -LiteralPath $scratchPath -Recurse -Force -Directory -Filter $pattern -ErrorAction SilentlyContinue |
      Select-Object -First 200 |
      ForEach-Object {
        [ordered]@{
          pattern = $pattern
          path = $_.FullName
        }
      }
  }
}

$rootMB = To-MB -Bytes ([int64]($sizeItems | Where-Object { $_.name -eq 'root' }).bytes)
$localMB = To-MB -Bytes ([int64]($sizeItems | Where-Object { $_.name -eq '_local' }).bytes)
$scratchMB = To-MB -Bytes ([int64]($sizeItems | Where-Object { $_.name -eq '_local/_scratch' }).bytes)

$status = 'PASS'
$warnings = New-Object System.Collections.Generic.List[string]

if ($rootMB -gt $ProjectWarnMB) {
  $warnings.Add(("ROOT_OVER_WARN_MB actual={0} warn={1}" -f $rootMB,$ProjectWarnMB))
}

if ($localMB -gt $LocalWarnMB) {
  $warnings.Add(("_LOCAL_OVER_WARN_MB actual={0} warn={1}" -f $localMB,$LocalWarnMB))
}

if ($scratchMB -gt $ScratchWarnMB) {
  $warnings.Add(("_SCRATCH_OVER_WARN_MB actual={0} warn={1}" -f $scratchMB,$ScratchWarnMB))
}

if ($warnings.Count -gt 0) { $status = 'WARN' }

$result = [ordered]@{
  status = $status
  root_path = $RootPath
  thresholds_mb = [ordered]@{
    project = $ProjectWarnMB
    local = $LocalWarnMB
    scratch = $ScratchWarnMB
  }
  sizes = @($sizeItems | ForEach-Object {
    [ordered]@{
      name = $_.name
      path = $_.path
      bytes = $_.bytes
      mb = To-MB -Bytes ([int64]$_.bytes)
    }
  })
  top_scratch_dirs = @($topScratchDirs)
  suspect_dirs = @($suspectDirs | Select-Object -First 500)
  warnings = @($warnings)
}

[IO.File]::WriteAllText($JsonPath, ($result | ConvertTo-Json -Depth 20), [Text.UTF8Encoding]::new($false))

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# REPORT_PROJECT_HOUSEKEEPING_SIZE_GATE')
$lines.Add('')
$lines.Add(("STATUS={0}" -f $status))
$lines.Add(("ROOT_PATH={0}" -f $RootPath))
$lines.Add(("JSON={0}" -f $JsonPath))
$lines.Add('')
$lines.Add('## Sizes')
$lines.Add('')
foreach ($item in $result.sizes) {
  $lines.Add(('- {0}: {1} MB | {2}' -f $item.name,$item.mb,$item.path))
}
$lines.Add('')
$lines.Add('## Warnings')
$lines.Add('')
if ($warnings.Count -eq 0) {
  $lines.Add('- none')
} else {
  foreach ($w in $warnings) { $lines.Add(('- {0}' -f $w)) }
}
$lines.Add('')
$lines.Add('## Top Scratch Dirs')
$lines.Add('')
if (@($topScratchDirs).Count -eq 0) {
  $lines.Add('- none')
} else {
  foreach ($dir in @($topScratchDirs)) {
    $lines.Add(('- {0} MB | {1}' -f $dir.mb,$dir.path))
  }
}
$lines.Add('')
$lines.Add('## Suspect Temp Dirs')
$lines.Add('')
if (@($suspectDirs).Count -eq 0) {
  $lines.Add('- none')
} else {
  foreach ($dir in @($suspectDirs | Select-Object -First 100)) {
    $lines.Add(('- {0} | {1}' -f $dir.pattern,$dir.path))
  }
}

[IO.File]::WriteAllText($ReportPath, (($lines.ToArray()) -join "`n") + "`n", [Text.UTF8Encoding]::new($false))

("STATUS={0}" -f $status)
("REPORT={0}" -f $ReportPath)
("JSON={0}" -f $JsonPath)
("ROOT_MB={0}" -f $rootMB)
("_LOCAL_MB={0}" -f $localMB)
("_SCRATCH_MB={0}" -f $scratchMB)

if ($FailOnOverLimit -and $warnings.Count -gt 0) {
  throw ("HOUSEKEEPING_SIZE_GATE_OVER_LIMIT: {0}" -f (($warnings.ToArray()) -join '; '))
}
