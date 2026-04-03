param(
    [Parameter(Mandatory = $true)]
    [string]$WorkbookPath,

    [string]$ExpectedSha256 = '',

    [string]$BackupRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail {
    param([Parameter(Mandatory = $true)][string]$Message)
    throw ('FAIL: {0}' -f $Message)
}

function Test-FileUnlocked {
    param([Parameter(Mandatory = $true)][string]$Path)
    try {
        $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        $fs.Close()
        return $true
    }
    catch {
        return $false
    }
}

function Write-Utf8NoBomLf {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Text
    )

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $normalized = $Text -replace "`r?`n", "`n"
    if (-not $normalized.EndsWith("`n")) { $normalized += "`n" }
    [System.IO.File]::WriteAllText($Path, $normalized, [System.Text.UTF8Encoding]::new($false))
}

if (-not (Test-Path -LiteralPath $WorkbookPath -PathType Leaf)) {
    Fail ('workbook missing: {0}' -f $WorkbookPath)
}

if (-not (Test-FileUnlocked -Path $WorkbookPath)) {
    Fail ('workbook locked/open: close workbook before pre-apply backup: {0}' -f $WorkbookPath)
}

$sourceSha = (Get-FileHash -LiteralPath $WorkbookPath -Algorithm SHA256).Hash.ToUpperInvariant()
if ($ExpectedSha256 -and ($sourceSha -ne $ExpectedSha256.ToUpperInvariant())) {
    Fail ('unexpected workbook sha256 before backup. expected [{0}] got [{1}]' -f $ExpectedSha256.ToUpperInvariant(), $sourceSha)
}

if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    $BackupRoot = Join-Path $repoRoot '_local\workbook_backups'
}

if (-not (Test-Path -LiteralPath $BackupRoot -PathType Container)) {
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
}

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$ext = [System.IO.Path]::GetExtension($WorkbookPath)
$base = [System.IO.Path]::GetFileNameWithoutExtension($WorkbookPath)
$backupPath = Join-Path $BackupRoot ('{0}_PREAPPLY_BACKUP_{1}{2}' -f $base, $ts, $ext)
$reportPath = Join-Path $BackupRoot ('REPORT_PREAPPLY_BACKUP_{0}.md' -f $ts)
$jsonPath   = Join-Path $BackupRoot ('PREAPPLY_BACKUP_{0}.json' -f $ts)

Copy-Item -LiteralPath $WorkbookPath -Destination $backupPath -Force

$backupSha = (Get-FileHash -LiteralPath $backupPath -Algorithm SHA256).Hash.ToUpperInvariant()
if ($backupSha -ne $sourceSha) {
    Fail ('backup sha mismatch. source [{0}] backup [{1}]' -f $sourceSha, $backupSha)
}

$report = @"
# REPORT_PREAPPLY_BACKUP_$ts

SOURCE_PATH=$WorkbookPath
BACKUP_PATH=$backupPath
SOURCE_SHA256=$sourceSha
BACKUP_SHA256=$backupSha
RULE=PREAPPLY_BACKUP_REQUIRED_BEFORE_ANY_WORKBOOK_MUTATION
RESULT=PASS
"@

$json = [ordered]@{
    rule = 'PREAPPLY_BACKUP_REQUIRED_BEFORE_ANY_WORKBOOK_MUTATION'
    result = 'PASS'
    source_path = $WorkbookPath
    backup_path = $backupPath
    source_sha256 = $sourceSha
    backup_sha256 = $backupSha
}

Write-Utf8NoBomLf -Path $reportPath -Text $report
Write-Utf8NoBomLf -Path $jsonPath -Text ($json | ConvertTo-Json -Depth 5)

Write-Host ("SOURCE_PATH={0}" -f $WorkbookPath)
Write-Host ("BACKUP_PATH={0}" -f $backupPath)
Write-Host ("SOURCE_SHA256={0}" -f $sourceSha)
Write-Host ("BACKUP_SHA256={0}" -f $backupSha)
Write-Host ("REPORT={0}" -f $reportPath)
Write-Host ("JSON={0}" -f $jsonPath)
Write-Host 'PASS: workbook pre-apply backup created'
