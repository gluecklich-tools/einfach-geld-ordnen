[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$LearningKey,
    [Parameter(Mandatory = $true)][string]$Title,
    [Parameter(Mandatory = $true)][string]$BodyMarkdown,
    [string]$Category = "general",
    [string]$AppliesTo = "",
    [switch]$NoReport
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot   = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $RepoRoot)
$BrainRoot   = Join-Path $ProjectRoot "Brain_EGO_Dateien"
$InternRoot  = Join-Path $ProjectRoot "_INTERN"
$GovRoot     = Join-Path $InternRoot "governance"

function Fail([string]$Message) {
    throw $Message
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Read-Utf8 {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return ""
    }
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Resolve-FirstFileOrFallback {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [AllowEmptyCollection()][Parameter(Mandatory = $true)][string[]]$Patterns,
        [Parameter(Mandatory = $true)][string]$FallbackPath
    )

    $hits = @()
    foreach ($pattern in $Patterns) {
        $hits += Get-ChildItem -LiteralPath $Root -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue
    }

    $picked = $hits |
        Sort-Object FullName -Unique |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($picked) {
        return $picked.FullName
    }

    return $FallbackPath
}

function Ensure-BlockPresent {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$MarkerStart,
        [Parameter(Mandatory = $true)][string]$MarkerEnd,
        [Parameter(Mandatory = $true)][string]$BlockContent
    )

    $old = Read-Utf8 -Path $Path
    $escapedStart = [regex]::Escape($MarkerStart)
    $escapedEnd   = [regex]::Escape($MarkerEnd)
    $pattern      = "(?s)$escapedStart.*?$escapedEnd"

    if ($old -match $pattern) {
        $new = [regex]::Replace(
            $old,
            $pattern,
            [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $BlockContent }
        )
    }
    else {
        $sep = ""
        if ($old.Length -gt 0 -and -not $old.EndsWith("`r`n")) {
            $sep = "`r`n"
        }
        $new = $old + $sep + $BlockContent + "`r`n"
    }

    if ($new -ne $old) {
        Write-Utf8NoBom -Path $Path -Content $new
        return $true
    }

    return $false
}

function Ensure-LinePresent {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Line
    )

    $old = Read-Utf8 -Path $Path
    $normalized = $old -replace "`r`n", "`n"
    $lines = @()
    if ($normalized.Length -gt 0) {
        $lines = $normalized -split "`n"
    }

    if ($lines -contains $Line) {
        return $false
    }

    $prefix = ""
    if ($old.Length -gt 0 -and -not $old.EndsWith("`r`n")) {
        $prefix = "`r`n"
    }

    Write-Utf8NoBom -Path $Path -Content ($old + $prefix + $Line + "`r`n")
    return $true
}

if ([string]::IsNullOrWhiteSpace($LearningKey)) {
    Fail "LearningKey fehlt."
}
if ([string]::IsNullOrWhiteSpace($Title)) {
    Fail "Title fehlt."
}
if ([string]::IsNullOrWhiteSpace($BodyMarkdown)) {
    Fail "BodyMarkdown fehlt."
}
if (-not (Test-Path -LiteralPath $BrainRoot)) {
    Fail "BrainRoot nicht gefunden: $BrainRoot"
}
if (-not (Test-Path -LiteralPath $InternRoot)) {
    Fail "InternRoot nicht gefunden: $InternRoot"
}
if (-not (Test-Path -LiteralPath $GovRoot)) {
    Fail "GovRoot nicht gefunden: $GovRoot"
}

$claudePatterns = @(
    "*CLAUDE*LEARNING*.md",
    "*Claude*Learning*.md",
    "*claude*learning*.md",
    "*CLAUDE*.md"
)

$internLearningsPatterns = @(
    "LEARNINGS_INTERNAL.md",
    "*LEARNINGS*.md",
    "*GOVERNANCE*.md"
)

$brainIndexPatterns = @(
    "*BRAIN*SYNC*.txt",
    "*INDEX*.md",
    "*INVENTORY*.md",
    "*README*.md"
)

$ClaudeInternPath = Resolve-FirstFileOrFallback -Root $InternRoot -Patterns $claudePatterns -FallbackPath (Join-Path $GovRoot "CLAUDE_LEARNINGS_INTERNAL.md")
$ClaudeBrainPath  = Resolve-FirstFileOrFallback -Root $BrainRoot  -Patterns $claudePatterns -FallbackPath (Join-Path $BrainRoot "CLAUDE_LEARNINGS_BRAIN.md")
$LearningsPath    = Resolve-FirstFileOrFallback -Root $GovRoot    -Patterns $internLearningsPatterns -FallbackPath (Join-Path $GovRoot "LEARNINGS_INTERNAL.md")
$BrainIndexPath   = Resolve-FirstFileOrFallback -Root $BrainRoot  -Patterns $brainIndexPatterns -FallbackPath (Join-Path $BrainRoot "BRAIN_SYNC_LAST.txt")

$markerStart = "<!-- EGO_LEARNING_SYNC_START:$LearningKey -->"
$markerEnd   = "<!-- EGO_LEARNING_SYNC_END:$LearningKey -->"
$ts = Get-Date -Format "yyyyMMdd_HHmmss"

$appliesSection = ""
if (-not [string]::IsNullOrWhiteSpace($AppliesTo)) {
    $appliesSection = @"

### AppliesTo
$AppliesTo
"@
}

$block = @"
$markerStart
## $Title

Stand: $ts  
Key: $LearningKey  
Category: $Category
$appliesSection

### Learning
$BodyMarkdown
$markerEnd
"@

$changed = New-Object System.Collections.Generic.List[string]

if (Ensure-BlockPresent -Path $ClaudeInternPath -MarkerStart $markerStart -MarkerEnd $markerEnd -BlockContent $block) {
    $changed.Add($ClaudeInternPath) | Out-Null
}
if (Ensure-BlockPresent -Path $ClaudeBrainPath -MarkerStart $markerStart -MarkerEnd $markerEnd -BlockContent $block) {
    $changed.Add($ClaudeBrainPath) | Out-Null
}
if (Ensure-BlockPresent -Path $LearningsPath -MarkerStart $markerStart -MarkerEnd $markerEnd -BlockContent $block) {
    $changed.Add($LearningsPath) | Out-Null
}

$brainLinkLine = "SYNC: $LearningKey -> $ClaudeBrainPath"
if (Ensure-LinePresent -Path $BrainIndexPath -Line $brainLinkLine) {
    $changed.Add($BrainIndexPath) | Out-Null
}

if (-not $NoReport) {
    $reportTs   = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportDir  = Join-Path $RepoRoot ("_local\chatpack\{0}\SSOT" -f $reportTs)
    $reportPath = Join-Path $reportDir ("SYNC_LEARNING_{0}.md" -f ($LearningKey -replace '[^A-Za-z0-9_\-]', '_'))

    $changedLines = if ($changed.Count -gt 0) {
        ($changed | Sort-Object -Unique | ForEach-Object { "- $_" }) -join "`r`n"
    }
    else {
        "- keine inhaltliche Änderung erforderlich"
    }

    $report = @"
# SYNC_LEARNING_$LearningKey

## STATUS
PASS

## TARGETS
- ClaudeInternPath: $ClaudeInternPath
- ClaudeBrainPath: $ClaudeBrainPath
- LearningsPath: $LearningsPath
- BrainIndexPath: $BrainIndexPath

## CHANGED
$changedLines

## TITLE
- $Title

## CATEGORY
- $Category

PASS: sync learning $LearningKey
"@

    Write-Utf8NoBom -Path $reportPath -Content $report
    Write-Host ("REPORT: {0}" -f $reportPath)
}

Write-Host ("CHANGED: {0}" -f (($changed | Sort-Object -Unique).Count))
Write-Host ("PASS: sync learning {0}" -f $LearningKey)
