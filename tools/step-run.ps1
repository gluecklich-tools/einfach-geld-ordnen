param(
    [Parameter(ParameterSetName = 'ByStep')]
    [Alias('StepPath')]
    [string]$Step,

    [Parameter(ParameterSetName = 'ByPattern')]
    [string]$Pattern,

    [ValidateSet(
'Produkt-Loop',
'Claude-Prompting',
'Governance-Änderung',
'Brain-Intern-Struktur',
'Folgeprojekt-Klon',
'OpenAI-Regress-Governance',
'Tool-Entrypoint-Failure',
'Workbook-Artifact-Identity',
'Active-Scope-Lock',
'Visible-Surface-Rebuild',
'Workbook-Masterpass',
'Sheet-Finalizer',
'Tool-Repair',
'Hash-Mismatch-Relock',
'OpenXML-Recovery-PreRepair'
    )]
    [string]$RequiredReadsTaskType
)

. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -FailureSyncRequiredReadsTaskType $RequiredReadsTaskType

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue

try {
    if ($IsWindows) {
        chcp 65001 > $null
    }
}
catch {
}

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# BEGIN AUTO_FAILURE_INTAKE_BINDING
$FailureSyncTool = Join-Path $PSScriptRoot 'auto-sync-step-run-failure.ps1'
$FailureSyncRunnerPath = if ($PSCommandPath) { (Resolve-Path -LiteralPath $PSCommandPath).Path } else { $null }

function Invoke-FailureSyncBestEffort {
    param(
        [Parameter(Mandatory = $true)][string]$FailureText
    )

    if (-not (Test-Path -LiteralPath $FailureSyncTool)) {
        return
    }

    $SafeStepPath = $null
    if (Get-Variable -Name ResolvedStepPath -ErrorAction SilentlyContinue) {
        $SafeStepPath = $ResolvedStepPath
    }
    elseif (Get-Variable -Name StepPath -ErrorAction SilentlyContinue) {
        $SafeStepPath = $StepPath
    }

    try {
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $FailureSyncTool -FailureText $FailureText -RunnerPath $FailureSyncRunnerPath -StepPath $SafeStepPath -Pattern $Pattern -RequiredReadsTaskType $RequiredReadsTaskType
    }
    catch {
        $AutoFailureText = $_.Exception.Message
        if (-not [string]::IsNullOrWhiteSpace($AutoFailureText)) {
            Write-Host ('AUTO_FAILURE_SYNC_FAIL: {0}' -f $AutoFailureText)
        }
    }
}
# END AUTO_FAILURE_INTAKE_BINDING

function Fail([string]$Message) {
    throw $Message
}

function Join-Lines {
    param([AllowNull()]$Lines)

    if ($null -eq $Lines) {
        return ''
    }

    return (($Lines | ForEach-Object { [string]$_ }) -join [Environment]::NewLine).Trim()
}

function Resolve-ExistingPath {
    param(
        [AllowEmptyCollection()][Parameter(Mandatory = $true)][string[]]$Candidates,
        [Parameter(Mandatory = $true)][string]$Label
    )

    foreach ($Candidate in $Candidates) {
        if (-not [string]::IsNullOrWhiteSpace($Candidate) -and (Test-Path -LiteralPath $Candidate)) {
            return (Resolve-Path -LiteralPath $Candidate).Path
        }
    }

    Fail ('FAIL: {0} missing: {1}' -f $Label, ($Candidates -join ' || '))
}

function Invoke-CheckedPwsh {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$ArgumentList = @(),
        [Parameter(Mandatory = $true)][string]$Label
    )

    $Output = & pwsh -NoProfile -ExecutionPolicy Bypass -File $FilePath @ArgumentList 2>&1
    $ExitCode = $LASTEXITCODE
    $Text = Join-Lines -Lines $Output

    if ($ExitCode -ne 0) {
        if ([string]::IsNullOrWhiteSpace($Text)) {
            $Text = 'no output'
        }
        Fail ('FAIL: {0} failed (exit={1}): {2}' -f $Label, $ExitCode, $Text)
    }

    return [pscustomobject]@{
        Output   = @($Output)
        Text     = $Text
        ExitCode = $ExitCode
    }
}

function Get-RepoStatusLines {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $Lines = @(git -C $RepoRoot status --short)
    if ($LASTEXITCODE -ne 0) {
        Fail ('FAIL: git status --short failed in {0}' -f $RepoRoot)
    }

    return @($Lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

# BEGIN WORKTREE_HYGIENE_PRESTEP_GATE_V1
function Get-RepoRelativePathFromLiteralPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$LiteralPath
    )

    $repoFull = [System.IO.Path]::GetFullPath($RepoRoot).TrimEnd('\')
    $pathFull = [System.IO.Path]::GetFullPath($LiteralPath)

    if (-not $pathFull.StartsWith($repoFull + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    $relative = $pathFull.Substring($repoFull.Length).TrimStart('\')
    return ($relative.Replace('\', '/'))
}

function Convert-RepoStatusLinesToPaths {
    param([AllowNull()]$StatusLines)

    if ($null -eq $StatusLines) {
        return @()
    }

    $paths = New-Object 'System.Collections.Generic.List[string]'
    foreach ($line in @($StatusLines)) {
        $text = [string]$line
        if ([string]::IsNullOrWhiteSpace($text)) {
            continue
        }

        if ($text.Length -lt 4) {
            continue
        }

        $path = $text.Substring(3).Trim()
        if ($path -match ' -> ') {
            $path = ($path -split ' -> ')[-1].Trim()
        }

        if (-not [string]::IsNullOrWhiteSpace($path)) {
            $paths.Add($path.Replace('\', '/')) | Out-Null
        }
    }

    return @($paths.ToArray() | Sort-Object -Unique)
}

function Assert-PrestepWorktreeHygiene {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$ResolvedStepPath,
        [AllowNull()]$PreStatus
    )

    $dirtyPaths = @(Convert-RepoStatusLinesToPaths -StatusLines $PreStatus)
    if (@($dirtyPaths).Count -eq 0) {
        Write-Host 'HYGIENE_PRESTEP: CLEAN'
        return
    }

    $allowed = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $stepRelative = Get-RepoRelativePathFromLiteralPath -RepoRoot $RepoRoot -LiteralPath $ResolvedStepPath
    if (-not [string]::IsNullOrWhiteSpace($stepRelative)) {
        $null = $allowed.Add($stepRelative)
    }

    $unexpected = New-Object 'System.Collections.Generic.List[string]'
    foreach ($dirty in $dirtyPaths) {
        if (-not $allowed.Contains($dirty)) {
            $unexpected.Add($dirty) | Out-Null
        }
    }

    if ($unexpected.Count -gt 0) {
        Fail ('FAIL: WORKTREE_HYGIENE_PRESTEP_DIRTY_SCOPE: {0}' -f (($unexpected.ToArray()) -join ' || '))
    }

    Write-Host ('HYGIENE_PRESTEP_ALLOWED: {0}' -f ($dirtyPaths -join ' || '))
}
# END WORKTREE_HYGIENE_PRESTEP_GATE_V1

function Remove-OrphanPostRunSyncIfUntracked {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $Target = Join-Path $RepoRoot 'tools\ego-postrun-sync.ps1'
    if (-not (Test-Path -LiteralPath $Target)) {
        return $false
    }

    $Status = @(git -C $RepoRoot status --porcelain=v1 -- 'tools/ego-postrun-sync.ps1')
    if ($LASTEXITCODE -ne 0) {
        Fail 'FAIL: git status for tools/ego-postrun-sync.ps1 failed.'
    }

    if (@($Status).Count -eq 0) {
        return $false
    }

    if (@($Status).Count -eq 1 -and [string]$Status[0] -like '??*') {
        Remove-Item -LiteralPath $Target -Force
        Write-Host ('HYGIENE_REMOVED_ORPHAN: {0}' -f $Target)
        return $true
    }

    return $false
}

function Get-LatestScratchCandidates {
    param(
        [Parameter(Mandatory = $true)][string]$ScratchRoot,
        [int]$MaxCount = 12
    )

    if (-not (Test-Path -LiteralPath $ScratchRoot)) {
        return @()
    }

    return @(
        Get-ChildItem -LiteralPath $ScratchRoot -File -Filter '*.ps1' -ErrorAction SilentlyContinue |
            Sort-Object `
                @{ Expression = 'LastWriteTime'; Descending = $true }, `
                @{ Expression = 'Name'; Descending = $false } |
            Select-Object -First $MaxCount
    )
}

function Get-LatestMatchingScratchStep {
    param(
        [Parameter(Mandatory = $true)][string]$ScratchRoot,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    if (-not (Test-Path -LiteralPath $ScratchRoot)) {
        return $null
    }

    return @(
        Get-ChildItem -LiteralPath $ScratchRoot -File -Filter $Pattern -ErrorAction SilentlyContinue |
            Sort-Object `
                @{ Expression = 'LastWriteTime'; Descending = $true }, `
                @{ Expression = 'Name'; Descending = $false }
    ) | Select-Object -First 1
}

# BEGIN AUTO_FAILURE_INTAKE_TRY
try {
$ScriptRepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ScratchRoot    = Join-Path $ScriptRepoRoot '_local\_scratch'

if (-not (Test-Path -LiteralPath $ScratchRoot)) {
    Fail ('FAIL: scratch root missing: {0}' -f $ScratchRoot)
}

$StepIsEmpty    = [string]::IsNullOrWhiteSpace($Step)
$PatternIsEmpty = [string]::IsNullOrWhiteSpace($Pattern)

if ((-not $StepIsEmpty) -and (-not $PatternIsEmpty)) {
    Fail 'FAIL: use either -Step or -Pattern, not both.'
}

if ($StepIsEmpty -and $PatternIsEmpty) {
    $Candidates = @(Get-LatestScratchCandidates -ScratchRoot $ScratchRoot -MaxCount 12)
    $CandidateText = if ($Candidates.Count -eq 0) {
        'none'
    }
    else {
        ($Candidates | ForEach-Object { $_.Name }) -join ' || '
    }

    Fail ('FAIL: neither -Step nor -Pattern provided. Use -Pattern "name_*" to avoid empty $step issues. Latest scratch candidates: {0}' -f $CandidateText)
}

if (-not $PatternIsEmpty) {
    $Matched = Get-LatestMatchingScratchStep -ScratchRoot $ScratchRoot -Pattern $Pattern
    if ($null -eq $Matched) {
        $Candidates = @(Get-LatestScratchCandidates -ScratchRoot $ScratchRoot -MaxCount 12)
        $CandidateText = if ($Candidates.Count -eq 0) {
            'none'
        }
        else {
            ($Candidates | ForEach-Object { $_.Name }) -join ' || '
        }

        Fail ('FAIL: no scratch step found for pattern [{0}] in {1}. Latest scratch candidates: {2}' -f $Pattern, $ScratchRoot, $CandidateText)
    }

    $StepPath = $Matched.FullName
}
else {
    $StepPath = $Step
}

if ([string]::IsNullOrWhiteSpace($StepPath)) {
    $Candidates = @(Get-LatestScratchCandidates -ScratchRoot $ScratchRoot -MaxCount 12)
    $CandidateText = if ($Candidates.Count -eq 0) {
        'none'
    }
    else {
        ($Candidates | ForEach-Object { $_.Name }) -join ' || '
    }

    Fail ('FAIL: resolved step path is empty. Use -Pattern "name_*". Latest scratch candidates: {0}' -f $CandidateText)
}

if (-not (Test-Path -LiteralPath $StepPath)) {
    Fail ('FAIL: step not found: {0}' -f $StepPath)
}

$ResolvedStepPath = (Resolve-Path -LiteralPath $StepPath).Path
$ResolvedRepoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $ResolvedStepPath) '..\..')).Path

if ($ResolvedRepoRoot -ne $ScriptRepoRoot) {
    Fail ('FAIL: resolved step repo mismatch. runner={0} step={1}' -f $ScriptRepoRoot, $ResolvedRepoRoot)
}

$RepoRoot    = $ScriptRepoRoot
$ProjectRoot = (Resolve-Path (Join-Path $RepoRoot '..\..')).Path

$SsotRoot = Resolve-ExistingPath -Candidates @(
    (Join-Path $ProjectRoot '_INTERN\governance'),
    (Join-Path $RepoRoot '_INTERN\governance')
) -Label 'SSOT root'

$SsotTools = Resolve-ExistingPath -Candidates @(
    (Join-Path $ProjectRoot '_INTERN\tools'),
    (Join-Path $RepoRoot '_INTERN\tools')
) -Label 'SSOT tools'

$BrainRoot = Resolve-ExistingPath -Candidates @(
    (Join-Path $ProjectRoot 'Brain_EGO_Dateien'),
    (Join-Path $RepoRoot 'Brain_EGO_Dateien')
) -Label 'Brain root'

$BootstrapPath = Resolve-ExistingPath -Candidates @(
    (Join-Path $SsotRoot 'BOOTSTRAP_INTERNAL.md')
) -Label 'Bootstrap'

$SsotFullsync = Resolve-ExistingPath -Candidates @(
    (Join-Path $SsotTools 'ssot-fullsync-all.ps1')
) -Label 'ssot-fullsync-all'

$SsotRefresh = Resolve-ExistingPath -Candidates @(
    (Join-Path $SsotTools 'ssot-refresh-proxy.ps1')
) -Label 'ssot-refresh-proxy'

$FlowGate = Resolve-ExistingPath -Candidates @(
    (Join-Path $SsotTools 'flow-quality-gate.ps1')
) -Label 'flow-quality-gate'

$RequiredReadsPreflight = Resolve-ExistingPath -Candidates @(
    (Join-Path $ProjectRoot '_INTERN\tools\knowledge-required-reads-preflight.ps1'),
    (Join-Path $RepoRoot '_INTERN\tools\knowledge-required-reads-preflight.ps1')
) -Label 'required reads preflight'

$env:EGO_SSOT_ROOT = $SsotRoot

$RemovedOrphan = Remove-OrphanPostRunSyncIfUntracked -RepoRoot $RepoRoot

$InitialPreStatus = @(Get-RepoStatusLines -RepoRoot $RepoRoot)
# BEGIN WORKTREE_HYGIENE_PRESTATUS_ASSERT_V1
Assert-PrestepWorktreeHygiene -RepoRoot $RepoRoot -ResolvedStepPath $ResolvedStepPath -PreStatus $InitialPreStatus
# END WORKTREE_HYGIENE_PRESTATUS_ASSERT_V1

$PreFullsync = Invoke-CheckedPwsh -FilePath $SsotFullsync -Label 'pre-step ssot fullsync'
Write-Host $PreFullsync.Text

$PreStatus = @(Get-RepoStatusLines -RepoRoot $RepoRoot)
$PreDirtyPaths = @(Convert-RepoStatusLinesToPaths -StatusLines $PreStatus)
if (@($PreDirtyPaths).Count -eq 0) {
    $PreRefresh = Invoke-CheckedPwsh -FilePath $SsotRefresh -Label 'pre-step ssot refresh'
    Write-Host $PreRefresh.Text

    $PreFlow = Invoke-CheckedPwsh -FilePath $FlowGate -ArgumentList @('-RepoRoot', $RepoRoot, '-SSOTRoot', $SsotRoot, '-ReportOnly') -Label 'pre-step flow quality gate'
    Write-Host $PreFlow.Text
}
else {
    Write-Host ('HYGIENE_PRESTEP_SYNC_DIRTY_SCOPE: {0}' -f ($PreDirtyPaths -join ' || '))
    Fail ('FAIL: PRESTEP_FULLSYNC_CREATED_TRACKED_DIRTY_SCOPE: {0}. Commit or restore the synced files before the next step-run.' -f ($PreDirtyPaths -join ' || '))
}

if (-not [string]::IsNullOrWhiteSpace($RequiredReadsTaskType)) {
    $RequiredReads = Invoke-CheckedPwsh -FilePath $RequiredReadsPreflight -ArgumentList @('-TaskType', $RequiredReadsTaskType) -Label 'required reads preflight'
    Write-Host $RequiredReads.Text
}

$Raw = Get-Content -LiteralPath $ResolvedStepPath -Raw -Encoding UTF8

if ($Raw -notmatch '\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\(') {
    Fail 'FAIL: step missing $EGO_STEP_WRITE_ALLOWLIST = @(...).'
}

if ($Raw -match '(?m)^\s*\$null\s*=\s*\$lines\.Add\(\s*"[-#]') {
    Fail 'FAIL: step report line uses parser-fragile interpolated string; use format operator (-f) or prebuilt string.'
}

if ($Raw -match '(?m)^\s*\$pass\w+\s*=\s*\(\(.*\|\s*Where-Object\b.*\)\.Count\s*-eq\s*\d+\)') {
    Fail 'FAIL: step uses pipeline Count directly after Where-Object; wrap with @(... ) before .Count.'
}

if ($Raw -match '(?m)\[\s*System\.Collections\.Generic\.List\[string\]\s*\]\$List') {
    Fail 'FAIL: step helper uses Generic.List[string] parameter binding; use direct .Add(...) on local list.'
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $ResolvedStepPath
$StepExit = $LASTEXITCODE

if ($StepExit -ne 0) {
    Fail ('STOP: step-run failed (exit={0})' -f $StepExit)
}

$PostFullsync = Invoke-CheckedPwsh -FilePath $SsotFullsync -Label 'post-step ssot fullsync'
Write-Host $PostFullsync.Text

$PostStatus = @(Get-RepoStatusLines -RepoRoot $RepoRoot)
# BEGIN WORKTREE_HYGIENE_POSTSTATUS_REPORT_V1
$PostDirtyPaths = @(Convert-RepoStatusLinesToPaths -StatusLines $PostStatus)
if (@($PostDirtyPaths).Count -eq 0) {
    Write-Host 'HYGIENE_POSTSTEP: CLEAN'
}
else {
    Write-Host ('HYGIENE_POSTSTEP_DIRTY_SCOPE: {0}' -f ($PostDirtyPaths -join ' || '))
}
# END WORKTREE_HYGIENE_POSTSTATUS_REPORT_V1

if (@($PostStatus).Count -eq 0) {
    $PostRefresh = Invoke-CheckedPwsh -FilePath $SsotRefresh -Label 'post-step ssot refresh'
    Write-Host $PostRefresh.Text

    $PostFlow = Invoke-CheckedPwsh -FilePath $FlowGate -ArgumentList @('-RepoRoot', $RepoRoot, '-SSOTRoot', $SsotRoot, '-ReportOnly') -Label 'post-step flow quality gate'
    Write-Host $PostFlow.Text
}
else {
    Write-Host ('SKIP_POST_REFRESH_DIRTY_REPO: {0}' -f (($PostStatus | ForEach-Object { [string]$_ }) -join ' || '))
}

Write-Host ('STEP_RESOLVED_PATH: {0}' -f $ResolvedStepPath)
if (-not $PatternIsEmpty) {
    Write-Host ('STEP_PATTERN_USED: {0}' -f $Pattern)
}
Write-Host ('SYNC_CANONICAL_SSOT_ROOT: {0}' -f $SsotRoot)
Write-Host ('SYNC_CANONICAL_BRAIN_ROOT: {0}' -f $BrainRoot)
Write-Host ('SYNC_BOOTSTRAP: {0}' -f $BootstrapPath)
Write-Host ('HYGIENE_ORPHAN_REMOVED: {0}' -f $RemovedOrphan)
Write-Host 'PASS: step-run'
}
catch {
    $FailureMessage = $_.Exception.Message
    if ([string]::IsNullOrWhiteSpace($FailureMessage)) {
        $FailureMessage = 'FAIL: unknown step-run exception'
    }

    Invoke-FailureSyncBestEffort -FailureText $FailureMessage
    throw
}
# END AUTO_FAILURE_INTAKE_TRY

# EGO_MANAGED_BLOCK:APRIL03_STEPRUN:START
# RUN nur mit literalem exaktem Pfad; kein nacktes $step; kein nacktes $file.
# Bekannter Präventionsfehler: Missing argument for parameter Step.
# EGO_MANAGED_BLOCK:APRIL03_STEPRUN:END

# EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:START
# Vor jedem Excel-Befehl ist Web-Research aus Pflichtquellenklassen erforderlich.
# Pflichtquellen: MICROSOFT_DOCS | MICROSOFT_COMMUNITY_OR_FORUM | CHAMPIONSHIP_OR_FMWC.
# Erst danach Excel-Command/Apply ausgeben.
# EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:END

# EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_STEPRUN:START
# RequiredReadsTaskType unterstuetzt jetzt Visible-Surface-Rebuild, Workbook-Masterpass, Sheet-Finalizer, Tool-Repair, Hash-Mismatch-Relock und OpenXML-Recovery-PreRepair.
# WORKBOOK_MASTERPASS und SHEET_FINALIZER duerfen im aktiven Recovery-Strang nicht vermischt werden.
# EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_STEPRUN:END
