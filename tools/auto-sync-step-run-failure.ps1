param(
    [Parameter(Mandatory = $true)]
    [string]$FailureText,

    [string]$RunnerPath,
    [string]$StepPath,
    [string]$Pattern,
    [string]$RequiredReadsTaskType
)

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

function Fail([string]$Message) {
    throw ('FAIL: {0}' -f $Message)
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $Dir = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($Dir) -and -not (Test-Path -LiteralPath $Dir)) {
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    }

    $Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Read-Utf8([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        Fail ('Pflichtdatei fehlt: {0}' -f $Path)
    }

    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Get-TextState([string]$Path) {
    $Raw = Read-Utf8 -Path $Path
    $Nl = if ($Raw.Contains("`r`n")) { "`r`n" } else { "`n" }
    $Norm = $Raw -replace "`r`n", "`n"

    return @{
        Raw  = $Raw
        Nl   = $Nl
        Norm = $Norm
    }
}

function Write-Normalized([string]$Path, [string]$NormalizedText, [string]$Newline) {
    $OutText = $NormalizedText -replace "`n", $Newline
    Write-Utf8NoBom -Path $Path -Content $OutText
}

function Ensure-Section {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$MarkerStart,
        [Parameter(Mandatory = $true)][string]$MarkerEnd,
        [Parameter(Mandatory = $true)][string]$BlockContent
    )

    $State = Get-TextState -Path $Path
    $PatternRx = '(?s)' + [regex]::Escape($MarkerStart) + '.*?' + [regex]::Escape($MarkerEnd)
    $Replacement = $BlockContent.TrimEnd() + "`n"

    if ([regex]::IsMatch($State.Norm, $PatternRx)) {
        $NewNorm = [regex]::Replace(
            $State.Norm,
            $PatternRx,
            [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $Replacement }
        )
    }
    else {
        $Sep = ''
        if ($State.Norm.Length -gt 0 -and -not $State.Norm.EndsWith("`n")) {
            $Sep = "`n"
        }
        $NewNorm = $State.Norm + $Sep + $Replacement
    }

    if ($NewNorm -ne $State.Norm) {
        Write-Normalized -Path $Path -NormalizedText $NewNorm -Newline $State.Nl
        return $true
    }

    return $false
}

function Get-HashOrNull([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Get-UniqueExistingPaths([string[]]$Candidates) {
    $Result = New-Object System.Collections.Generic.List[string]

    foreach ($Candidate in $Candidates) {
        if (-not [string]::IsNullOrWhiteSpace($Candidate) -and (Test-Path -LiteralPath $Candidate)) {
            $Resolved = (Resolve-Path -LiteralPath $Candidate).Path
            if (-not $Result.Contains($Resolved)) {
                $Result.Add($Resolved) | Out-Null
            }
        }
    }

    return @($Result.ToArray())
}

function Get-FailureSnippet([string]$Text) {
    $OneLine = (($Text -replace "`r`n", ' | ') -replace "`n", ' | ').Trim()
    if ($OneLine.Length -gt 800) {
        return $OneLine.Substring(0, 800)
    }
    return $OneLine
}

$EffectiveRunnerPath = $RunnerPath
if ([string]::IsNullOrWhiteSpace($EffectiveRunnerPath)) {
    $EffectiveRunnerPath = $MyInvocation.MyCommand.Path
}

$ResolvedRunnerPath = (Resolve-Path -LiteralPath $EffectiveRunnerPath).Path
$RepoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $ResolvedRunnerPath) '..')).Path
$ProjectRoot = (Resolve-Path (Join-Path $RepoRoot '..\..')).Path
$RunTs = Get-Date -Format 'yyyyMMdd_HHmmss'

$GovRoots = Get-UniqueExistingPaths -Candidates @(
    (Join-Path $ProjectRoot '_INTERN\governance'),
    (Join-Path $RepoRoot '_INTERN\governance')
)

$BrainRoots = Get-UniqueExistingPaths -Candidates @(
    (Join-Path $ProjectRoot 'Brain_EGO_Dateien'),
    (Join-Path $RepoRoot 'Brain_EGO_Dateien')
)

if (@($GovRoots).Count -eq 0) {
    Fail 'Kein Governance-Root gefunden.'
}
if (@($BrainRoots).Count -eq 0) {
    Fail 'Kein Brain-Root gefunden.'
}

$ChatpackDir = Join-Path $RepoRoot ("_local\chatpack\{0}\SSOT" -f $RunTs)
$JsonPath = Join-Path $RepoRoot ("_local\_scratch\auto_sync_step_run_failure_{0}.json" -f $RunTs)
New-Item -ItemType Directory -Force -Path $ChatpackDir | Out-Null

$ReportPath = Join-Path $ChatpackDir 'AUTO_SYNC_STEP_RUN_FAILURE.md'

$FailureSnippet = Get-FailureSnippet -Text $FailureText
$StepPathText = if ([string]::IsNullOrWhiteSpace($StepPath)) { 'none' } else { $StepPath }
$PatternText = if ([string]::IsNullOrWhiteSpace($Pattern)) { 'none' } else { $Pattern }
$TaskTypeText = if ([string]::IsNullOrWhiteSpace($RequiredReadsTaskType)) { 'none' } else { $RequiredReadsTaskType }

$BootstrapSection = @"
<!-- BEGIN:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
## HARDLAW 2026-03-14 - AUTO FAILURE INTAKE IN STEP-RUN

- step-run bindet automatische Failure-Intake in den Workflow ein.
- Neue Step-Run-Fehler muessen unverzueglich uebergreifend in _INTERN, Brain, Bootstrap/SSOT, Learnings, QA, Governance und relevante Steuerdateien nachgezogen werden.
- Der Auto-Failure-Intake ist Workflow-Bestandteil und nicht nur Chat-Memory.
<!-- END:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
"@ -replace "`r`n", "`n"

$GovernanceSection = @"
<!-- BEGIN:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
## 2026-03-14 AUTO FAILURE INTAKE - STEP-RUN WORKFLOW

### Mechanismus
- step-run ruft bei Exceptions und Failures best effort tools\auto-sync-step-run-failure.ps1 auf
- Failure-Text, RunnerPath, StepPath, Pattern und RequiredReadsTaskType werden mitgegeben
- Keine Regex-Unescape-Transformation auf kompletten Scripttexten fuer diese Bindung

### Letzter automatisch aufgenommener Failure
- failure_excerpt: $FailureSnippet
- step_path: $StepPathText
- pattern: $PatternText
- required_reads_task_type: $TaskTypeText
<!-- END:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
"@ -replace "`r`n", "`n"

$LearningsSection = @"
<!-- BEGIN:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
## LEARNINGS 2026-03-14 - AUTO FAILURE INTAKE IN STEP-RUN

- Step-Run-Failures werden ab jetzt workflowgebunden automatisch aufgenommen.
- Failures bleiben echte Failures; Auto-Intake ersetzt kein echtes Fixing.
- Der Auto-Intake muss robust gegen leeren StepPath und Pattern-Faelle sein.
- Letzter Failure-Excerpt: $FailureSnippet
<!-- END:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
"@ -replace "`r`n", "`n"

$QaSection = @"
<!-- BEGIN:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
## QA ADDENDUM 2026-03-14 - AUTO FAILURE INTAKE IN STEP-RUN

### Neue Pflichtgates
27. STEP_RUN_AUTO_FAILURE_INTAKE_BOUND_GATE
28. AUTO_FAILURE_INTAKE_WRITES_REPORT_AND_SYNC_GATE

### Mindestpruefung
- Failure in step-run erkannt: ja/nein
- auto-sync-step-run-failure.ps1 best effort aufgerufen: ja/nein
- _INTERN und Brain sofort aktualisiert: ja/nein
- Report/JSON fuer Auto-Failure geschrieben: ja/nein
<!-- END:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
"@ -replace "`r`n", "`n"

$FlowmapSection = @"
<!-- BEGIN:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
## FLOW UPDATE 2026-03-14 - STEP-RUN AUTO FAILURE INTAKE

- SCAN: step-run Failure real belegen
- AUTO-INTAKE: Failure best effort sofort in Dateien nachziehen
- THROW: Failure bleibt Failure und wird danach normal weitergeworfen
- Danach normaler fachlicher Fix-Step
<!-- END:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
"@ -replace "`r`n", "`n"

$TodoSection = @"
<!-- BEGIN:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
[P0] 2026-03-14 Auto-Failure-Intake in step-run gebunden halten und bei neuen Failures sofort uebergreifend synchronisieren
<!-- END:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
"@ -replace "`r`n", "`n"

$SystemMapSection = @"
<!-- BEGIN:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
## SYSTEM MAP UPDATE 2026-03-14 - STEP-RUN AUTO FAILURE INTAKE

- workflow runner: tools\step-run.ps1
- failure intake helper: tools\auto-sync-step-run-failure.ps1
- current failure excerpt: $FailureSnippet
<!-- END:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->
"@ -replace "`r`n", "`n"

$Changed = New-Object System.Collections.Generic.List[string]
$MarkerStart = '<!-- BEGIN:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->'
$MarkerEnd = '<!-- END:AUTO_FAILURE_INTAKE_WORKFLOW_2026_03_14 -->'

$GovFiles = @(
    @{ Roots = $GovRoots; FileName = 'BOOTSTRAP_INTERNAL.md'; Section = $BootstrapSection }
    @{ Roots = $GovRoots; FileName = 'GOVERNANCE_INTERNAL.md'; Section = $GovernanceSection }
    @{ Roots = $GovRoots; FileName = 'LEARNINGS_INTERNAL.md'; Section = $LearningsSection }
    @{ Roots = $GovRoots; FileName = 'QA_GATE_INTERNAL.md'; Section = $QaSection }
    @{ Roots = $GovRoots; FileName = 'FLOWMAP_INTERNAL.md'; Section = $FlowmapSection }
    @{ Roots = $GovRoots; FileName = 'TODO.md'; Section = $TodoSection }
    @{ Roots = $GovRoots; FileName = 'SSOT_SYSTEM_MAP_INTERNAL.md'; Section = $SystemMapSection }
)

$BrainFiles = @(
    @{ Roots = $BrainRoots; FileName = 'BOOTSTRAP_INTERNAL.md'; Section = $BootstrapSection }
    @{ Roots = $BrainRoots; FileName = 'GOVERNANCE_INTERNAL.md'; Section = $GovernanceSection }
    @{ Roots = $BrainRoots; FileName = 'LEARNINGS_INTERNAL.md'; Section = $LearningsSection }
    @{ Roots = $BrainRoots; FileName = 'QA_GATE_INTERNAL.md'; Section = $QaSection }
    @{ Roots = $BrainRoots; FileName = 'FLOWMAP_INTERNAL.md'; Section = $FlowmapSection }
    @{ Roots = $BrainRoots; FileName = 'TODO.md'; Section = $TodoSection }
    @{ Roots = $BrainRoots; FileName = 'SSOT_SYSTEM_MAP_INTERNAL.md'; Section = $SystemMapSection }
)

foreach ($Item in @($GovFiles + $BrainFiles)) {
    foreach ($Root in $Item.Roots) {
        $TargetPath = Join-Path $Root $Item.FileName
        if (Ensure-Section -Path $TargetPath -MarkerStart $MarkerStart -MarkerEnd $MarkerEnd -BlockContent $Item.Section) {
            $Changed.Add($TargetPath) | Out-Null
        }
    }
}

$SyncStamp = @(
    'BRAIN_SYNC_SCOPE=auto_failure_step_run_intake'
    ('RUN_TS={0}' -f $RunTs)
    'STATUS=updated'
    ('FAILURE_EXCERPT={0}' -f $FailureSnippet)
) -join [Environment]::NewLine

foreach ($Root in $GovRoots) {
    $Target = Join-Path $Root 'BRAIN_SYNC_LAST.txt'
    Write-Utf8NoBom -Path $Target -Content ($SyncStamp + [Environment]::NewLine)
    $Changed.Add($Target) | Out-Null
}
foreach ($Root in $BrainRoots) {
    $Target = Join-Path $Root 'BRAIN_SYNC_LAST.txt'
    Write-Utf8NoBom -Path $Target -Content ($SyncStamp + [Environment]::NewLine)
    $Changed.Add($Target) | Out-Null
}

$HashReport = @()
$CompareNames = @(
    'BOOTSTRAP_INTERNAL.md'
    'GOVERNANCE_INTERNAL.md'
    'LEARNINGS_INTERNAL.md'
    'QA_GATE_INTERNAL.md'
    'FLOWMAP_INTERNAL.md'
    'TODO.md'
    'SSOT_SYSTEM_MAP_INTERNAL.md'
    'BRAIN_SYNC_LAST.txt'
)

foreach ($Name in $CompareNames) {
    $Paths = @()

    foreach ($Root in $GovRoots) {
        $Paths += (Join-Path $Root $Name)
    }
    foreach ($Root in $BrainRoots) {
        $Paths += (Join-Path $Root $Name)
    }

    $Hashes = @(
        $Paths | ForEach-Object { Get-HashOrNull -Path $_ }
    )

    $UniqueHashes = @(
        $Hashes | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
    )

    $HashReport += [pscustomobject]@{
        name        = $Name
        path_count   = $Paths.Count
        hash_count   = $UniqueHashes.Count
        hashes_equal = ($UniqueHashes.Count -eq 1)
    }
}

$AllHashesEqual = -not ($HashReport | Where-Object { -not $_.hashes_equal })

$Object = [ordered]@{
    timestamp                = $RunTs
    failure_excerpt          = $FailureSnippet
    runner_path              = $ResolvedRunnerPath
    step_path                = $StepPathText
    pattern                  = $PatternText
    required_reads_task_type = $TaskTypeText
    report_path              = $ReportPath
    changed_files            = @($Changed | Sort-Object -Unique)
    hash_report              = @($HashReport)
    all_hashes_equal         = $AllHashesEqual
}

$Json = $Object | ConvertTo-Json -Depth 8
Write-Utf8NoBom -Path $JsonPath -Content $Json

$Lines = @(
    '# AUTO_SYNC_STEP_RUN_FAILURE'
    ''
    ('- timestamp: {0}' -f $RunTs)
    ('- failure_excerpt: {0}' -f $FailureSnippet)
    ('- runner_path: {0}' -f $ResolvedRunnerPath)
    ('- step_path: {0}' -f $StepPathText)
    ('- pattern: {0}' -f $PatternText)
    ('- required_reads_task_type: {0}' -f $TaskTypeText)
    ('- json: {0}' -f $JsonPath)
    ('- all_hashes_equal: {0}' -f $AllHashesEqual)
    ''
    '## HASH_REPORT'
)

foreach ($Item in $HashReport) {
    $Lines += ('- {0}: hashes_equal={1}' -f $Item.name, $Item.hashes_equal)
}

Write-Utf8NoBom -Path $ReportPath -Content (($Lines -join [Environment]::NewLine) + [Environment]::NewLine)

Write-Host ('AUTO_SYNC_REPORT: {0}' -f $ReportPath)
Write-Host ('AUTO_SYNC_JSON: {0}' -f $JsonPath)
Write-Host ('AUTO_SYNC_CHANGED_FILE_COUNT: {0}' -f (@($Changed | Sort-Object -Unique).Count))
Write-Host ('AUTO_SYNC_ALL_HASHES_EQUAL: {0}' -f $AllHashesEqual)
Write-Host 'PASS: auto-sync-step-run-failure'