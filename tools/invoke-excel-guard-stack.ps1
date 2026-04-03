param(
    [Parameter(Mandatory = $true)]
    [string]$ResearchReportPath,

    [Parameter(Mandatory = $true)]
    [string]$ContractPath,

    [Parameter(Mandatory = $true)]
    [string]$LayoutSpecPath,

    [Parameter(Mandatory = $true)]
    [string]$WorkbookPath,

    [Parameter(Mandatory = $true)]
    [string]$WorkbookSha256,

    [string]$BackupRoot = '',

    [switch]$SkipBackup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail {
    param([Parameter(Mandatory = $true)][string]$Message)
    throw ('FAIL: {0}' -f $Message)
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ResearchGatePath = Join-Path $RepoRoot 'tools\gate-excel-web-research-precheck.ps1'
$SurfaceGatePath  = Join-Path $RepoRoot 'tools\gate-excel-surface-contract.ps1'
$BackupToolPath   = Join-Path $RepoRoot 'tools\new-workbook-preapply-backup.ps1'

foreach ($path in @($ResearchGatePath, $SurfaceGatePath, $BackupToolPath, $ResearchReportPath, $ContractPath, $LayoutSpecPath, $WorkbookPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        Fail ('missing required path: {0}' -f $path)
    }
}

& $ResearchGatePath -ResearchReportPath $ResearchReportPath -ScopeToken 'WHOLE_VISIBLE_HAUSHALTSBUCH_SURFACE' -WorkbookPath $WorkbookPath

$backupReport = ''
if (-not $SkipBackup) {
    & $BackupToolPath -WorkbookPath $WorkbookPath -ExpectedSha256 $WorkbookSha256 -BackupRoot $BackupRoot

    $effectiveBackupRoot = $BackupRoot
    if ([string]::IsNullOrWhiteSpace($effectiveBackupRoot)) {
        $effectiveBackupRoot = Join-Path $RepoRoot '_local\workbook_backups'
    }

    $backupReport = Get-ChildItem -LiteralPath $effectiveBackupRoot -File -Filter 'REPORT_PREAPPLY_BACKUP_*.md' |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1 -ExpandProperty FullName

    if ([string]::IsNullOrWhiteSpace($backupReport)) {
        Fail 'backup report missing after backup run'
    }
}

& $SurfaceGatePath -ContractPath $ContractPath -LayoutSpecPath $LayoutSpecPath -WorkbookPath $WorkbookPath -WorkbookSha256 $WorkbookSha256

Write-Host ("RESEARCH_REPORT={0}" -f $ResearchReportPath)
Write-Host ("CONTRACT={0}" -f $ContractPath)
Write-Host ("LAYOUT_SPEC={0}" -f $LayoutSpecPath)
if (-not $SkipBackup) {
    Write-Host ("BACKUP_REPORT={0}" -f $backupReport)
}
Write-Host 'PASS: excel guard stack'
