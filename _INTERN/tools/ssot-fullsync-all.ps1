param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$GovDir      = Join-Path $ProjectRoot '_INTERN\governance'
$BrainDir    = Join-Path $ProjectRoot 'Brain_EGO_Dateien'
$BrainLatest = Join-Path $BrainDir 'latest'
$RepoRoot    = Join-Path $ProjectRoot 'GitHub_Clone_Dateien\einfach-geld-ordnen'
$RepoGov     = Join-Path $RepoRoot '_INTERN\governance'
$RepoBrain   = Join-Path $RepoRoot 'Brain_EGO_Dateien'

$SkipDirNames = @(
    '_patch_backups'
)

$Copied = New-Object System.Collections.Generic.List[string]
$NoChange = New-Object System.Collections.Generic.List[string]

function Ensure-Dir([string]$Path) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Same-File([string]$A, [string]$B) {
    if (-not (Test-Path -LiteralPath $A)) { return $false }
    if (-not (Test-Path -LiteralPath $B)) { return $false }

    $fa = Get-FileHash -LiteralPath $A -Algorithm SHA256
    $fb = Get-FileHash -LiteralPath $B -Algorithm SHA256
    return ($fa.Hash -eq $fb.Hash)
}

function Copy-IfChanged([string]$Source, [string]$Target) {
    Ensure-Dir -Path (Split-Path -Parent $Target)

    if ((Test-Path -LiteralPath $Target) -and (Same-File -A $Source -B $Target)) {
        $NoChange.Add($Target) | Out-Null
        return
    }

    Copy-Item -LiteralPath $Source -Destination $Target -Force
    $Copied.Add($Target) | Out-Null
}

function Sync-Tree([string]$SourceRoot, [string]$TargetRoot) {
    Ensure-Dir -Path $TargetRoot

    $items = Get-ChildItem -LiteralPath $SourceRoot -Force
    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            if ($SkipDirNames -contains $item.Name) {
                continue
            }

            Sync-Tree -SourceRoot $item.FullName -TargetRoot (Join-Path $TargetRoot $item.Name)
            continue
        }

        Copy-IfChanged -Source $item.FullName -Target (Join-Path $TargetRoot $item.Name)
    }
}

Ensure-Dir -Path $BrainLatest
Ensure-Dir -Path $RepoGov
Ensure-Dir -Path $RepoBrain

$rootGovFiles = Get-ChildItem -LiteralPath $GovDir -File -Force | Where-Object {
    $_.Extension -in @('.md', '.txt', '.json', '.tsv')
}

foreach ($file in $rootGovFiles) {
    Copy-IfChanged -Source $file.FullName -Target (Join-Path $BrainDir $file.Name)
    Copy-IfChanged -Source $file.FullName -Target (Join-Path $BrainLatest $file.Name)
}

Sync-Tree -SourceRoot $GovDir -TargetRoot $RepoGov
Sync-Tree -SourceRoot $BrainDir -TargetRoot $RepoBrain

Write-Host ("FULLSYNC_COPIED: {0}" -f $Copied.Count)
Write-Host ("FULLSYNC_NOCHANGE: {0}" -f $NoChange.Count)
Write-Host ("FULLSYNC_CANONICAL_GOV: {0}" -f $GovDir)
Write-Host ("FULLSYNC_CANONICAL_BRAIN: {0}" -f $BrainDir)
Write-Host ("FULLSYNC_REPO_GOV: {0}" -f $RepoGov)
Write-Host ("FULLSYNC_REPO_BRAIN: {0}" -f $RepoBrain)
Write-Host 'PASS: ssot fullsync all'

exit 0
