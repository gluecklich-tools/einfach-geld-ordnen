param(
    [Parameter(Mandatory = $true)]
    [string]$NamePrefix
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepoRoot = (Get-Location).Path
$ScratchDir = Join-Path $RepoRoot "_local\_scratch"

$EGO_STEP_WRITE_ALLOWLIST = @(
    "_local\chatpack\"
)

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

if (-not (Test-Path -LiteralPath $ScratchDir)) {
    New-Item -ItemType Directory -Path $ScratchDir -Force | Out-Null
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$stepPath = Join-Path $ScratchDir ("{0}_{1}.ps1" -f $NamePrefix, $ts)

$template = @'
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# STEP_STANDARD_HEADER_HARDWRITE
$StepPath   = $MyInvocation.MyCommand.Path
$ScratchDir = Split-Path -Parent $StepPath
$RepoRoot   = (Resolve-Path (Join-Path $ScratchDir "..\..")).Path
Set-Location -LiteralPath $RepoRoot

$EGO_STEP_WRITE_ALLOWLIST = @(
    "_local\chatpack\"
)
$EGO_STEP_PRESTEP_DIRTY_ALLOWLIST = @(
)
$EGO_STEP_BACKUP_REQUIRED = "YES"

throw "TODO: fill step body"
'@

Write-Utf8NoBom -Path $stepPath -Content $template

$verify = Get-Content -LiteralPath $stepPath -Raw
if ($verify.IndexOf('$EGO_STEP_WRITE_ALLOWLIST = @(', [System.StringComparison]::Ordinal) -lt 0) {
    throw "VERIFY_FAIL_ALLOWLIST_MISSING"
}

code -g ("{0}:1" -f $stepPath)

"STEP: $stepPath"