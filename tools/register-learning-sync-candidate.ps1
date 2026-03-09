[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$LearningKey,
    [Parameter(Mandatory = $true)][string]$Title,
    [string]$Reason = "",
    [string]$Source = "chat",
    [switch]$SkipIfAlreadySynced
)

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

if ([string]::IsNullOrWhiteSpace($LearningKey)) {
    Fail "LearningKey fehlt."
}
if ([string]::IsNullOrWhiteSpace($Title)) {
    Fail "Title fehlt."
}

if ($SkipIfAlreadySynced) {
    if (-not (Test-Path -LiteralPath $GatePath)) {
        Fail "GateTool fehlt: $GatePath"
    }
    try {
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $GatePath -LearningKey $LearningKey *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host ("SKIP: already synced {0}" -f $LearningKey)
            exit 0
        }
    }
    catch {
    }
}

$existing = ""
if (Test-Path -LiteralPath $QueuePath) {
    $existing = Read-Utf8 -Path $QueuePath
}

$lines = @()
if (-not [string]::IsNullOrWhiteSpace($existing)) {
    $lines = $existing -replace "`r`n", "`n" -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

$pending = @()
foreach ($line in $lines) {
    try {
        $pending += ($line | ConvertFrom-Json)
    }
    catch {
    }
}

$already = $pending | Where-Object { $_.LearningKey -eq $LearningKey } | Select-Object -First 1
if ($already) {
    Write-Host ("NOCHANGE: already pending {0}" -f $LearningKey)
    exit 0
}

$entry = [ordered]@{
    Ts         = (Get-Date -Format "yyyyMMdd_HHmmss")
    LearningKey = $LearningKey
    Title      = $Title
    Reason     = $Reason
    Source     = $Source
}

$json = ($entry | ConvertTo-Json -Compress)
$prefix = ""
if ($existing.Length -gt 0 -and -not $existing.EndsWith("`r`n")) {
    $prefix = "`r`n"
}
Write-Utf8NoBom -Path $QueuePath -Content ($existing + $prefix + $json + "`r`n")

Write-Host ("QUEUE: {0}" -f $QueuePath)
Write-Host ("PASS: register learning sync candidate {0}" -f $LearningKey)