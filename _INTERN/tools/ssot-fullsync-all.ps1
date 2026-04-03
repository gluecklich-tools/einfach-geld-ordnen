param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ScriptRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path
$InternRoot  = Split-Path -Parent $ScriptRoot
$ProjectRoot = Split-Path -Parent $InternRoot
$GovDir      = Join-Path $InternRoot "governance"
$BrainDir    = Join-Path $ProjectRoot "Brain_EGO_Dateien"
$BrainLatest = Join-Path $BrainDir "latest"
$GovMirrorLatest = Join-Path $GovDir "brain_mirror\latest"
$RepoRoot    = Join-Path (Join-Path $ProjectRoot "GitHub_Clone_Dateien") "einfach-geld-ordnen"
$RepoGov     = Join-Path $RepoRoot "_INTERN\governance"
$RepoBrain   = Join-Path $RepoRoot "Brain_EGO_Dateien"
$RepoBrainLatest = Join-Path $RepoBrain "latest"
$RepoGovMirrorLatest = Join-Path $RepoGov "brain_mirror\latest"

$SkipDirNames = @(
    "_patch_backups"
)

$Copied   = New-Object System.Collections.Generic.List[string]
$NoChange = New-Object System.Collections.Generic.List[string]
$Removed  = New-Object System.Collections.Generic.List[string]

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

function Remove-IfExists([string]$LiteralPath) {
    if (Test-Path -LiteralPath $LiteralPath) {
        Remove-Item -LiteralPath $LiteralPath -Force
        $Removed.Add($LiteralPath) | Out-Null
    }
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

Ensure-Dir -Path $BrainDir
Ensure-Dir -Path $BrainLatest
Ensure-Dir -Path $GovMirrorLatest
Ensure-Dir -Path $RepoGov
Ensure-Dir -Path $RepoBrain
Ensure-Dir -Path $RepoBrainLatest
Ensure-Dir -Path $RepoGovMirrorLatest

$DeprecatedLatestAliases = @(
    (Join-Path $BrainLatest "ACTIVE_SCOPE_LOCK_LATEST.md")
    (Join-Path $BrainLatest "ACTIVE_SCOPE_RESUME_LATEST.md")
    (Join-Path $BrainLatest "START_ACCEPTANCE_LATEST.md")
    (Join-Path $GovMirrorLatest "ACTIVE_SCOPE_LOCK_LATEST.md")
    (Join-Path $GovMirrorLatest "ACTIVE_SCOPE_RESUME_LATEST.md")
    (Join-Path $GovMirrorLatest "START_ACCEPTANCE_LATEST.md")
    (Join-Path $RepoBrainLatest "ACTIVE_SCOPE_LOCK_LATEST.md")
    (Join-Path $RepoBrainLatest "ACTIVE_SCOPE_RESUME_LATEST.md")
    (Join-Path $RepoBrainLatest "START_ACCEPTANCE_LATEST.md")
    (Join-Path $RepoGovMirrorLatest "ACTIVE_SCOPE_LOCK_LATEST.md")
    (Join-Path $RepoGovMirrorLatest "ACTIVE_SCOPE_RESUME_LATEST.md")
    (Join-Path $RepoGovMirrorLatest "START_ACCEPTANCE_LATEST.md")
) | Sort-Object -Unique

foreach ($legacy in $DeprecatedLatestAliases) {
    Remove-IfExists -LiteralPath $legacy
}

$rootGovFiles = Get-ChildItem -LiteralPath $GovDir -File -Force | Where-Object {
    $_.Extension -in @(".md", ".txt", ".json", ".tsv")
}

foreach ($file in $rootGovFiles) {
    Copy-IfChanged -Source $file.FullName -Target (Join-Path $BrainDir $file.Name)
    Copy-IfChanged -Source $file.FullName -Target (Join-Path $BrainLatest $file.Name)
    Copy-IfChanged -Source $file.FullName -Target (Join-Path $GovMirrorLatest $file.Name)
}

Sync-Tree -SourceRoot $GovDir -TargetRoot $RepoGov
Sync-Tree -SourceRoot $BrainDir -TargetRoot $RepoBrain

foreach ($legacy in $DeprecatedLatestAliases) {
    Remove-IfExists -LiteralPath $legacy
}

Write-Host ("FULLSYNC_COPIED: {0}" -f $Copied.Count)
Write-Host ("FULLSYNC_NOCHANGE: {0}" -f $NoChange.Count)
Write-Host ("FULLSYNC_DEPRECATED_ALIAS_REMOVED: {0}" -f $Removed.Count)
foreach ($item in $Removed) {
    Write-Host ("FULLSYNC_DEPRECATED_ALIAS_REMOVED_PATH: {0}" -f $item)
}
Write-Host ("FULLSYNC_CANONICAL_GOV: {0}" -f $GovDir)
Write-Host ("FULLSYNC_CANONICAL_BRAIN: {0}" -f $BrainDir)
Write-Host ("FULLSYNC_REPO_GOV: {0}" -f $RepoGov)
Write-Host ("FULLSYNC_REPO_BRAIN: {0}" -f $RepoBrain)
Write-Host "PASS: ssot fullsync all"

exit 0

# EGO_MANAGED_BLOCK:APRIL03_FULLSYNC:START
# SSOT-Fullsync muss Tool-Roots als Pflichtbestandteil behandeln.
# Kein Drift zwischen canonical governance/brain/tools und Repo-Mirrors.
# EGO_MANAGED_BLOCK:APRIL03_FULLSYNC:END

# EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:START
# Research-First Hardlaw fuer Excel-Befehle ist Teil des SSOT und muss mitgesynct werden.
# EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:END
