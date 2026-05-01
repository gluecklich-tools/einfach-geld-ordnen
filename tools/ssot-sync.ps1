param(
  [string]$RepoRoot = '',
  [string]$ProjectRoot = '',
  [string]$SourceSSOT = '',
  [string]$ReportPath = '',
  [switch]$FailOnNoSource
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

if (-not $RepoRoot) {
  $gitRoot = (& git rev-parse --show-toplevel 2>$null)
  if ($gitRoot) {
    $RepoRoot = (Resolve-Path -LiteralPath $gitRoot).Path
  } else {
    $RepoRoot = (Get-Location).Path
  }
} else {
  $RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
}

if (-not $ProjectRoot) {
  $ProjectRoot = Split-Path -Parent (Split-Path -Parent $RepoRoot)
} else {
  $ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
}

if (-not $SourceSSOT) {
  $chatpackRoot = Join-Path $RepoRoot '_local\chatpack'

  if (Test-Path -LiteralPath $chatpackRoot -PathType Container) {
    $SourceSSOT = Get-ChildItem -LiteralPath $chatpackRoot -Directory -ErrorAction SilentlyContinue |
      Sort-Object LastWriteTime -Descending |
      ForEach-Object { Join-Path $_.FullName 'SSOT' } |
      Where-Object { Test-Path -LiteralPath $_ -PathType Container } |
      Select-Object -First 1
  }
}

$targetIntern = Join-Path $ProjectRoot '_INTERN\governance'
$targetMirror = Join-Path $ProjectRoot '_INTERN\governance\brain_mirror'
$targetBrain = Join-Path $ProjectRoot 'Brain_EGO_Dateien'
$targetRepoIntern = Join-Path $RepoRoot '_INTERN\governance'
$targetRepoBrain = Join-Path $RepoRoot 'Brain_EGO_Dateien'

$targets = @(
  $targetIntern,
  $targetMirror,
  $targetBrain,
  $targetRepoIntern,
  $targetRepoBrain
) | Select-Object -Unique

foreach ($target in $targets) {
  Ensure-Dir -Path $target
}

if (-not $ReportPath) {
  $reportRoot = Join-Path $RepoRoot '_local\_reports'
  Ensure-Dir -Path $reportRoot
  $ReportPath = Join-Path $reportRoot ("REPORT_SSOT_SYNC_{0}.md" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}

$files = @()
$names = @()
$copied = 0
$status = 'PASS'
$message = 'SSOT_SYNC_COMPLETE'

if (-not $SourceSSOT -or -not (Test-Path -LiteralPath $SourceSSOT -PathType Container)) {
  $status = 'WARN'
  $message = 'SOURCE_SSOT_NOT_FOUND'
  if ($FailOnNoSource) { throw $message }
} else {
  $files = @(Get-ChildItem -LiteralPath $SourceSSOT -Recurse -File -ErrorAction SilentlyContinue)
  $names = @($files | ForEach-Object { $_.FullName.Substring($SourceSSOT.Length).TrimStart('\','/') })

  foreach ($file in $files) {
    $rel = $file.FullName.Substring($SourceSSOT.Length).TrimStart('\','/')

    foreach ($target in $targets) {
      $dest = Join-Path $target $rel
      Ensure-Dir -Path (Split-Path -Parent $dest)
      Copy-Item -LiteralPath $file.FullName -Destination $dest -Force
      $copied++
    }
  }
}

$lines = @()
$lines += '# REPORT_SSOT_SYNC'
$lines += ''
$lines += ('STATUS={0}' -f $status)
$lines += ('MESSAGE={0}' -f $message)
$lines += ('SRC_SSOT={0}' -f $SourceSSOT)
$lines += ('TGT_INTERN={0}' -f $targetIntern)
$lines += ('TGT_MIRR={0}' -f $targetMirror)
$lines += ('TGT_BRAIN={0}' -f $targetBrain)
$lines += ('TGT_REPO_INTERN={0}' -f $targetRepoIntern)
$lines += ('TGT_REPO_BRAIN={0}' -f $targetRepoBrain)
$lines += ('FILE_COUNT={0}' -f $files.Count)
$lines += ('NAME_COUNT={0}' -f $names.Count)
$lines += ('COPIED={0}' -f $copied)
$lines += ''
$lines += '## Names'
$lines += ''

if ($names.Count -eq 0) {
  $lines += '- none'
} else {
  foreach ($name in $names) {
    $lines += ('- {0}' -f $name)
  }
}

Write-Utf8NoBomLF -Path $ReportPath -Text ($lines -join "`n")

('STATUS={0}' -f $status)
('REPORT={0}' -f $ReportPath)
('MESSAGE={0}' -f $message)
('FILE_COUNT={0}' -f $files.Count)
('NAME_COUNT={0}' -f $names.Count)
('COPIED={0}' -f $copied)
