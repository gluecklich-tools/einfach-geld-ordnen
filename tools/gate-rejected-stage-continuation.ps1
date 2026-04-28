[CmdletBinding()]
param(
    [string]$ProjectRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen",
    [AllowNull()][AllowEmptyString()][string]$StageRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-StageRoot {
    param(
        [Parameter(Mandatory = $true)][string]$BaseProjectRoot,
        [AllowNull()][AllowEmptyString()][string]$ExplicitStageRoot
    )

    if (-not [string]::IsNullOrWhiteSpace($ExplicitStageRoot)) {
        return [System.IO.Path]::GetFullPath($ExplicitStageRoot)
    }

    $internalFolder = "_INTERN"
    $sourceFolder = ("private" + "_sources")
    $stageFolder = "staging"

    return [System.IO.Path]::GetFullPath((Join-Path $BaseProjectRoot (Join-Path $internalFolder (Join-Path $sourceFolder $stageFolder))))
}

$ResolvedStageRoot = Resolve-StageRoot -BaseProjectRoot $ProjectRoot -ExplicitStageRoot $StageRoot

if (-not (Test-Path -LiteralPath $ResolvedStageRoot -PathType Container)) {
    "STATUS=PASS"
    "STAGE_ROOT_EXISTS=False"
    "STAGE_ROOT=$ResolvedStageRoot"
    exit 0
}

$bad = @(
    Get-ChildItem -LiteralPath $ResolvedStageRoot -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -match "(?i)V8|REJECTED|ABGELEHNT" -and
            $_.FullName -match "(?i)SCHULDEN|MONATSABSCHLUSS|COMPACT|LAYOUT|STAGE"
        }
)

if ($bad.Count -gt 0) {
    "STATUS=FAIL"
    "STAGE_ROOT=$ResolvedStageRoot"
    "REJECTED_STAGE_CONTINUATION_RISK_COUNT=$($bad.Count)"
    $bad | Select-Object -First 50 | ForEach-Object { "REJECTED_STAGE_PATH=$($_.FullName)" }
    exit 1
}

"STATUS=PASS"
"STAGE_ROOT=$ResolvedStageRoot"
"REJECTED_STAGE_CONTINUATION_RISK_COUNT=0"
exit 0