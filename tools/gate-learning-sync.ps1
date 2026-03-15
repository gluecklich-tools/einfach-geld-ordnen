[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$LearningKey
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
    throw "FAIL: $Message"
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
        [Parameter(Mandatory = $true)][string[]]$Patterns,
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

if ([string]::IsNullOrWhiteSpace($LearningKey)) {
    Fail "LearningKey fehlt."
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
$brainLinkLine = "SYNC: $LearningKey -> $ClaudeBrainPath"

$targets = @(
    @{ Name = "ClaudeInternPath"; Path = $ClaudeInternPath }
    @{ Name = "ClaudeBrainPath";  Path = $ClaudeBrainPath  }
    @{ Name = "LearningsPath";    Path = $LearningsPath    }
)

foreach ($target in $targets) {
    if (-not (Test-Path -LiteralPath $target.Path)) {
        Fail "$($target.Name) fehlt: $($target.Path)"
    }

    $content = Read-Utf8 -Path $target.Path
    if ($content.IndexOf($markerStart, [System.StringComparison]::Ordinal) -lt 0) {
        Fail "$($target.Name) enthält MarkerStart nicht: $LearningKey"
    }
    if ($content.IndexOf($markerEnd, [System.StringComparison]::Ordinal) -lt 0) {
        Fail "$($target.Name) enthält MarkerEnd nicht: $LearningKey"
    }
}

if (-not (Test-Path -LiteralPath $BrainIndexPath)) {
    Fail "BrainIndexPath fehlt: $BrainIndexPath"
}
$brainIndexContent = Read-Utf8 -Path $BrainIndexPath
if ($brainIndexContent.IndexOf($brainLinkLine, [System.StringComparison]::Ordinal) -lt 0) {
    Fail "BrainIndexPath enthält Sync-Link nicht: $LearningKey"
}

Write-Host "PASS: gate learning sync"
Write-Host ("KEY: {0}" -f $LearningKey)
Write-Host ("CLAUDE_INTERNAL: {0}" -f $ClaudeInternPath)
Write-Host ("CLAUDE_BRAIN: {0}" -f $ClaudeBrainPath)
Write-Host ("LEARNINGS: {0}" -f $LearningsPath)
Write-Host ("BRAIN_INDEX: {0}" -f $BrainIndexPath)