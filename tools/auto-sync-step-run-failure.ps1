param(
    [Parameter(Mandatory = $true)]
    [string]$FailureText,

    [string]$RunnerPath,
    [string]$StepPath,
    [string]$Pattern,
    [string]$RequiredReadsTaskType
)
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1')
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

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $Dir = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($Dir) -and -not (Test-Path -LiteralPath $Dir)) {
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    }

    $Encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $Encoding)
}

function Get-SafeResolvedPathOrText {
    param([AllowNull()][string]$Candidate)

    if ([string]::IsNullOrWhiteSpace($Candidate)) {
        return 'none'
    }

    $Text = [string]$Candidate
    if (Test-Path -LiteralPath $Text) {
        try {
            return (Resolve-Path -LiteralPath $Text).Path
        }
        catch {
            return $Text
        }
    }

    return $Text
}

function Read-Utf8OrFail([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw ('FAIL: Pflichtdatei fehlt: {0}' -f $Path)
    }

    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Get-TextState([string]$Path) {
    $Raw = Read-Utf8OrFail -Path $Path
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
    $PatternText = '(?s)' + [regex]::Escape($MarkerStart) + '.*?' + [regex]::Escape($MarkerEnd)
    $Replacement = $BlockContent.TrimEnd() + "`n"

    if ([regex]::IsMatch($State.Norm, $PatternText)) {
        $NewNorm = [regex]::Replace(
            $State.Norm,
            $PatternText,
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

function Resolve-CanonicalRoot {
    param(
        [AllowEmptyCollection()][Parameter(Mandatory = $true)][string[]]$Candidates,
        [Parameter(Mandatory = $true)][string]$Label
    )

    foreach ($Candidate in $Candidates) {
        if (-not [string]::IsNullOrWhiteSpace($Candidate) -and (Test-Path -LiteralPath $Candidate)) {
            return (Resolve-Path -LiteralPath $Candidate).Path
        }
    }

    throw ('FAIL: {0} fehlt: {1}' -f $Label, ($Candidates -join ' || '))
}

try {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    $ProjectRoot = (Resolve-Path (Join-Path $RepoRoot '..\..')).Path
    $RunTs = Get-Date -Format 'yyyyMMdd_HHmmss'

    $GovRoot = Resolve-CanonicalRoot -Candidates @(
        (Join-Path $ProjectRoot '_INTERN\governance'),
        (Join-Path $RepoRoot '_INTERN\governance')
    ) -Label '_INTERN\governance'

    $BrainRoot = Resolve-CanonicalRoot -Candidates @(
        (Join-Path $ProjectRoot 'Brain_EGO_Dateien'),
        (Join-Path $RepoRoot 'Brain_EGO_Dateien')
    ) -Label 'Brain_EGO_Dateien'

    $ChatpackDir = Join-Path $RepoRoot ("_local\chatpack\{0}\SSOT" -f $RunTs)
    $ReportPath  = Join-Path $ChatpackDir 'AUTO_SYNC_STEP_RUN_FAILURE.md'
    $JsonPath    = Join-Path $RepoRoot ("_local\_scratch\auto_sync_step_run_failure_{0}.json" -f $RunTs)

    New-Item -ItemType Directory -Force -Path $ChatpackDir | Out-Null

    $Targets = [ordered]@{
        BootstrapGov    = Join-Path $GovRoot   'BOOTSTRAP_INTERNAL.md'
        GovernanceGov   = Join-Path $GovRoot   'GOVERNANCE_INTERNAL.md'
        LearningsGov    = Join-Path $GovRoot   'LEARNINGS_INTERNAL.md'
        QaGov           = Join-Path $GovRoot   'QA_GATE_INTERNAL.md'
        FlowmapGov      = Join-Path $GovRoot   'FLOWMAP_INTERNAL.md'
        TodoGov         = Join-Path $GovRoot   'TODO.md'
        SystemMapGov    = Join-Path $GovRoot   'SSOT_SYSTEM_MAP_INTERNAL.md'
        BrainSyncGov    = Join-Path $GovRoot   'BRAIN_SYNC_LAST.txt'
        ClaudeGov       = Join-Path $GovRoot   'CLAUDE_LEARNINGS_INTERNAL.md'

        BootstrapBrain  = Join-Path $BrainRoot 'BOOTSTRAP_INTERNAL.md'
        GovernanceBrain = Join-Path $BrainRoot 'GOVERNANCE_INTERNAL.md'
        LearningsBrain  = Join-Path $BrainRoot 'LEARNINGS_INTERNAL.md'
        QaBrain         = Join-Path $BrainRoot 'QA_GATE_INTERNAL.md'
        FlowmapBrain    = Join-Path $BrainRoot 'FLOWMAP_INTERNAL.md'
        TodoBrain       = Join-Path $BrainRoot 'TODO.md'
        SystemMapBrain  = Join-Path $BrainRoot 'SSOT_SYSTEM_MAP_INTERNAL.md'
        BrainSyncBrain  = Join-Path $BrainRoot 'BRAIN_SYNC_LAST.txt'
        ClaudeBrain     = Join-Path $BrainRoot 'CLAUDE_LEARNINGS_INTERNAL.md'
    }

    $FailureTextSafe = if ([string]::IsNullOrWhiteSpace($FailureText)) { 'FAIL: empty failure text' } else { $FailureText.Trim() }
    $RunnerPathSafe  = Get-SafeResolvedPathOrText -Candidate $RunnerPath
    $StepPathSafe    = Get-SafeResolvedPathOrText -Candidate $StepPath
    $PatternSafe     = if ([string]::IsNullOrWhiteSpace($Pattern)) { 'none' } else { $Pattern.Trim() }
    $TaskTypeSafe    = if ([string]::IsNullOrWhiteSpace($RequiredReadsTaskType)) { 'none' } else { $RequiredReadsTaskType.Trim() }

    $SectionBootstrap = @"
<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
## HARDLAW 2026-03-14 - AUTO FAILURE PATH NORMALIZATION

- Auto-Failure-Intake darf niemals .Path auf beliebigen Objekten, Matches, Hashtables oder Strings voraussetzen.
- Optionale Pfadangaben muessen zuerst zu sicheren Stringwerten normalisiert werden.
- Failure-Sync bleibt best effort und darf den urspruenglichen Runner-Fehler nicht durch einen zweiten Tool-Fehler verdecken.
- Spezifischer Fehlerfall 2026-03-14: AUTO_FAILURE_SYNC_FAIL mit "The property 'Path' cannot be found on this object."
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
"@

    $SectionGovernance = @"
<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
## 2026-03-14 AUTO FAILURE PATH NORMALIZATION

### Neue Fehlerklasse
- AUTO_FAILURE_SYNC_PATH_PROPERTY_ASSUMPTION

### Harte Regeln
- kein .Path auf beliebigen Scan-Ergebnissen
- kein .Path auf Hashtables
- kein .Path auf bereits-stringifizierten Werten
- erst Test-Path, dann optional Resolve-Path, danach nur String weiterreichen
- Failure-Sync-Tool muss bei internem Fehler exit 0 liefern und den Primarfehler nicht ueberschreiben
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
"@

    $SectionLearnings = @"
<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
## LEARNINGS 2026-03-14 - AUTO FAILURE PATH NORMALIZATION

- Der konkrete Workflow-Bindungsfehler war kein Fachfehler, sondern eine Path-Eigenschaftsannahme im Auto-Failure-Sync.
- Ursache: .Path wurde auf Objekte angewendet, die keine Path-Eigenschaft garantieren.
- Gegenmassnahme: alle optionalen Pfade vor Nutzung zu sicheren Stringwerten normalisieren.
- Failure-Intake ist Hilfslogik und muss selbst fehlertolerant bleiben.
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
"@

    $SectionQa = @"
<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
## QA ADDENDUM 2026-03-14 - AUTO FAILURE PATH NORMALIZATION

### Neue Gates
- AUTO_FAILURE_SYNC_PATH_NORMALIZATION_GATE
- AUTO_FAILURE_SYNC_DOES_NOT_OVERRIDE_PRIMARY_FAILURE_GATE

### Mindestpruefung
- RunnerPath sicher stringifiziert: ja/nein
- StepPath sicher stringifiziert: ja/nein
- Pattern sicher stringifiziert: ja/nein
- Tool bleibt best effort und exit 0 bei internem Fehler: ja/nein
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
"@

    $SectionFlowmap = @"
<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
## FLOW UPDATE 2026-03-14 - AUTO FAILURE PATH NORMALIZATION

- primaren Fehler erfassen
- Runner/Step/Pattern zuerst normalisieren
- Failure-Sync in _INTERN + Brain + SSOT schreiben
- bei internem Sync-Fehler nur reporten, nicht den Primarfehler verdecken
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
"@

    $SectionTodo = @"
<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
[P0] 2026-03-14 Auto-Failure-Intake: Path-Normalisierung hart erzwingen; keine .Path-Annahmen auf beliebigen Objekten; Failure-Sync bleibt best effort und ueberdeckt keinen Primarfehler
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
"@

    $SectionSystemMap = @"
<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
## SYSTEM MAP UPDATE 2026-03-14 - AUTO FAILURE PATH NORMALIZATION

- workflow helper: auto-sync-step-run-failure.ps1
- owner rule: normalize optional paths to plain strings before usage
- failure sync is best effort and secondary to the original runner failure
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
"@

    $SectionClaude = @"
<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
## MODEL USAGE 2026-03-14 - AUTO FAILURE PATH NORMALIZATION

- Diese Fehlerklasse ist deterministisch und lokal zu beheben.
- Modelltext darf keinen Objekt-Typ erraten; Path-Normalisierung bleibt echte Tool-/Code-Logik.
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
"@

    $Changed = New-Object System.Collections.Generic.List[string]

    $Pairs = @(
        @{ Gov=$Targets.BootstrapGov;   Brain=$Targets.BootstrapBrain; Section=$SectionBootstrap },
        @{ Gov=$Targets.GovernanceGov;  Brain=$Targets.GovernanceBrain; Section=$SectionGovernance },
        @{ Gov=$Targets.LearningsGov;   Brain=$Targets.LearningsBrain; Section=$SectionLearnings },
        @{ Gov=$Targets.QaGov;          Brain=$Targets.QaBrain; Section=$SectionQa },
        @{ Gov=$Targets.FlowmapGov;     Brain=$Targets.FlowmapBrain; Section=$SectionFlowmap },
        @{ Gov=$Targets.TodoGov;        Brain=$Targets.TodoBrain; Section=$SectionTodo },
        @{ Gov=$Targets.SystemMapGov;   Brain=$Targets.SystemMapBrain; Section=$SectionSystemMap },
        @{ Gov=$Targets.ClaudeGov;      Brain=$Targets.ClaudeBrain; Section=$SectionClaude }
    )

    foreach ($Pair in $Pairs) {
        $ChangedGov = Ensure-Section -Path $Pair.Gov -MarkerStart '<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->' -MarkerEnd '<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->' -BlockContent $Pair.Section
        $ChangedBrain = Ensure-Section -Path $Pair.Brain -MarkerStart '<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->' -MarkerEnd '<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->' -BlockContent $Pair.Section

        if ($ChangedGov)   { $Changed.Add($Pair.Gov) | Out-Null }
        if ($ChangedBrain) { $Changed.Add($Pair.Brain) | Out-Null }
    }

    $SyncStamp = @(
        'BRAIN_SYNC_SCOPE=auto_failure_path_normalization_20260314'
        ('RUN_TS={0}' -f $RunTs)
        'STATUS=updated'
    ) -join [Environment]::NewLine

    Write-Utf8NoBom -Path $Targets.BrainSyncGov   -Content ($SyncStamp + [Environment]::NewLine)
    Write-Utf8NoBom -Path $Targets.BrainSyncBrain -Content ($SyncStamp + [Environment]::NewLine)
    $Changed.Add($Targets.BrainSyncGov)   | Out-Null
    $Changed.Add($Targets.BrainSyncBrain) | Out-Null

    $HashPairs = @(
        [pscustomobject]@{ Name='BOOTSTRAP_INTERNAL.md'; gov=$Targets.BootstrapGov;   brain=$Targets.BootstrapBrain },
        [pscustomobject]@{ Name='GOVERNANCE_INTERNAL.md'; gov=$Targets.GovernanceGov; brain=$Targets.GovernanceBrain },
        [pscustomobject]@{ Name='LEARNINGS_INTERNAL.md'; gov=$Targets.LearningsGov;   brain=$Targets.LearningsBrain },
        [pscustomobject]@{ Name='QA_GATE_INTERNAL.md'; gov=$Targets.QaGov;            brain=$Targets.QaBrain },
        [pscustomobject]@{ Name='FLOWMAP_INTERNAL.md'; gov=$Targets.FlowmapGov;       brain=$Targets.FlowmapBrain },
        [pscustomobject]@{ Name='TODO.md'; gov=$Targets.TodoGov;                      brain=$Targets.TodoBrain },
        [pscustomobject]@{ Name='SSOT_SYSTEM_MAP_INTERNAL.md'; gov=$Targets.SystemMapGov; brain=$Targets.SystemMapBrain },
        [pscustomobject]@{ Name='CLAUDE_LEARNINGS_INTERNAL.md'; gov=$Targets.ClaudeGov; brain=$Targets.ClaudeBrain },
        [pscustomobject]@{ Name='BRAIN_SYNC_LAST.txt'; gov=$Targets.BrainSyncGov;     brain=$Targets.BrainSyncBrain }
    )

    $HashReport = @()
    foreach ($Pair in $HashPairs) {
        $GovHash = Get-HashOrNull -Path $Pair.gov
        $BrainHash = Get-HashOrNull -Path $Pair.brain
        $HashReport += [pscustomobject]@{
            name       = $Pair.Name
            gov_hash   = $GovHash
            brain_hash = $BrainHash
            hash_equal = ($GovHash -eq $BrainHash)
        }
    }

    $Needles = @(
        'AUTO_FAILURE_SYNC_PATH_PROPERTY_ASSUMPTION',
        'keine .Path-Annahmen auf beliebigen Objekten',
        'Failure-Sync bleibt best effort',
        'AUTO_FAILURE_SYNC_PATH_NORMALIZATION_GATE'
    )

    $Combined = @(
        Read-Utf8OrFail -Path $Targets.BootstrapGov
        Read-Utf8OrFail -Path $Targets.GovernanceGov
        Read-Utf8OrFail -Path $Targets.LearningsGov
        Read-Utf8OrFail -Path $Targets.QaGov
        Read-Utf8OrFail -Path $Targets.FlowmapGov
        Read-Utf8OrFail -Path $Targets.TodoGov
        Read-Utf8OrFail -Path $Targets.SystemMapGov
    ) -join "`n"

    $MissingAfter = @()
    foreach ($Needle in $Needles) {
        if ($Combined -notmatch [regex]::Escape($Needle)) {
            $MissingAfter += $Needle
        }
    }

    $AllHashesEqual = -not ($HashReport | Where-Object { -not $_.hash_equal })

    $Object = [ordered]@{
        timestamp                = $RunTs
        failure_text             = $FailureTextSafe
        runner_path              = $RunnerPathSafe
        step_path                = $StepPathSafe
        pattern                  = $PatternSafe
        required_reads_task_type = $TaskTypeSafe
        changed_files            = @($Changed | Sort-Object -Unique)
        hash_report              = @($HashReport)
        all_hashes_equal         = $AllHashesEqual
        missing_after            = @($MissingAfter)
        result                   = if ($AllHashesEqual -and $MissingAfter.Count -eq 0) { 'PASS' } else { 'FAIL' }
    }

    $Json = $Object | ConvertTo-Json -Depth 8
    Write-Utf8NoBom -Path $JsonPath -Content $Json

    $Lines = @(
        '# AUTO_SYNC_STEP_RUN_FAILURE',
        '',
        ('- timestamp: {0}' -f $RunTs),
        ('- failure_text: {0}' -f $FailureTextSafe),
        ('- runner_path: {0}' -f $RunnerPathSafe),
        ('- step_path: {0}' -f $StepPathSafe),
        ('- pattern: {0}' -f $PatternSafe),
        ('- required_reads_task_type: {0}' -f $TaskTypeSafe),
        ('- changed_file_count: {0}' -f (@($Changed | Sort-Object -Unique).Count)),
        ('- all_hashes_equal: {0}' -f $AllHashesEqual),
        ('- missing_after_count: {0}' -f $MissingAfter.Count),
        '',
        '## CHANGED_FILES'
    )

    foreach ($Item in @($Changed | Sort-Object -Unique)) {
        $Lines += ('- {0}' -f $Item)
    }

    $Lines += @(
        '',
        '## HASH_REPORT'
    )

    foreach ($Item in $HashReport) {
        $Lines += ('- {0}: hash_equal={1}' -f $Item.name, $Item.hash_equal)
    }

    $Lines += @(
        '',
        '## MISSING_AFTER'
    )

    if ($MissingAfter.Count -eq 0) {
        $Lines += '- none'
    }
    else {
        foreach ($Item in $MissingAfter) {
            $Lines += ('- {0}' -f $Item)
        }
    }

    Write-Utf8NoBom -Path $ReportPath -Content (($Lines -join [Environment]::NewLine) + [Environment]::NewLine)

    Write-Host ('REPORT: {0}' -f $ReportPath)
    Write-Host ('JSON: {0}' -f $JsonPath)
    Write-Host ('SUMMARY_CHANGED_FILE_COUNT: {0}' -f (@($Changed | Sort-Object -Unique).Count))
    Write-Host ('SUMMARY_ALL_HASHES_EQUAL: {0}' -f $AllHashesEqual)
    Write-Host ('SUMMARY_MISSING_AFTER_COUNT: {0}' -f $MissingAfter.Count)
    Write-Host 'PASS: auto sync step-run failure applied'
    exit 0
}
catch {
    $Msg = $_.Exception.Message
    if ([string]::IsNullOrWhiteSpace($Msg)) {
        $Msg = 'unknown auto-sync internal error'
    }
    Write-Host ('AUTO_FAILURE_SYNC_INTERNAL_ERROR: {0}' -f $Msg)
    exit 0
}

# EGO_MANAGED_BLOCK:20260430_SYNC_STATUS_TAXONOMY:START
# 2026-04-30 Sync status taxonomy requirement:
# Future failure/sync reports must distinguish SYNC_NOT_APPLIED, SYNC_CONTENT_APPLIED_RUNNER_FAILED,
# SYNC_APPLIED_AND_VERIFIED and SYNC_ROLLED_BACK. A plain STATUS=FAIL after content/hash-equivalent writes is ambiguous.
# EGO_MANAGED_BLOCK:20260430_SYNC_STATUS_TAXONOMY:END
