[CmdletBinding()]
param(
    [switch]$AutoDrainSynced
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$QueuePath = Join-Path $RepoRoot "_local\governance\pending-learning-sync.jsonl"
$GatePath  = Join-Path $PSScriptRoot "gate-learning-sync.ps1"

function Fail([string]$Message) {
    throw "FAIL: $Message"
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowEmptyString()][Parameter(Mandatory = $true)][string]$Content
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

if (-not (Test-Path -LiteralPath $GatePath)) {
    Fail "GateTool fehlt: $GatePath"
}

if (-not (Test-Path -LiteralPath $QueuePath)) {
    Write-Host "PASS: no pending learning sync queue"
    exit 0
}

$content = Read-Utf8 -Path $QueuePath
if ([string]::IsNullOrWhiteSpace($content)) {
    Write-Host "PASS: empty pending learning sync queue"
    exit 0
}

$lines = $content -replace "`r`n", "`n" -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$pending = New-Object System.Collections.Generic.List[object]
foreach ($line in $lines) {
    try {
        $pending.Add(($line | ConvertFrom-Json)) | Out-Null
    }
    catch {
        Fail "Ungültiger JSONL-Eintrag in pending-learning-sync.jsonl"
    }
}

$stillPending = New-Object System.Collections.Generic.List[object]
$unsyncedKeys = New-Object System.Collections.Generic.List[string]
$drainedKeys  = New-Object System.Collections.Generic.List[string]

foreach ($entry in $pending) {
    $isSynced = $false
    try {
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $GatePath -LearningKey $entry.LearningKey *> $null
        if ($LASTEXITCODE -eq 0) {
            $isSynced = $true
        }
    }
    catch {
        $isSynced = $false
    }

    if ($isSynced) {
        if ($AutoDrainSynced) {
            $drainedKeys.Add($entry.LearningKey) | Out-Null
        }
        else {
            $stillPending.Add($entry) | Out-Null
        }
    }
    else {
        $stillPending.Add($entry) | Out-Null
        $unsyncedKeys.Add($entry.LearningKey) | Out-Null
    }
}

if ($AutoDrainSynced) {
    $newContent = ""
    if ($stillPending.Count -gt 0) {
        $newContent = (($stillPending | ForEach-Object { $_ | ConvertTo-Json -Compress }) -join "`r`n") + "`r`n"
    }
    Write-Utf8NoBom -Path $QueuePath -Content $newContent
}

if ($drainedKeys.Count -gt 0) {
    Write-Host ("DRAINED: {0}" -f ($drainedKeys -join ", "))
}

if ($unsyncedKeys.Count -gt 0) {
    Fail ("unsynced learning keys pending: {0}" -f ($unsyncedKeys -join ", "))
}

Write-Host ("PASS: pending learning sync clear ({0})" -f $stillPending.Count)