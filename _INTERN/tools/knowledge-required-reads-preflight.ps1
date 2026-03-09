param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(
        "Produkt-Loop",
        "Claude-Prompting",
        "Governance-Änderung",
        "Brain-Intern-Struktur",
        "Folgeprojekt-Klon",
        "OpenAI-Regress-Governance"
    )]
    [string]$TaskType,

    [string]$RepoRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen",

    [string]$BrainRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\Brain_EGO_Dateien",

    [string]$ClaudeRoot = "C:\Users\carst\Projekte\Claude"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$Message) { throw $Message }

function Split-List([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return @() }
    return ($Value -split ';').ForEach({ $_.Trim() }) | Where-Object { $_ -ne "" }
}

function Resolve-TokenToPath {
    param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$BrainRoot,
        [Parameter(Mandatory = $true)][string]$ClaudeRoot
    )

    switch -Regex ($Token) {
        '^_INTERN\\' { return (Join-Path $RepoRoot $Token) }
        '^Brain_EGO_Dateien\\' {
            $suffix = $Token.Substring("Brain_EGO_Dateien\".Length)
            return (Join-Path $BrainRoot $suffix)
        }
        '^C:\\' { return $Token }
        default { return $Token }
    }
}

$matrixPath = Join-Path $RepoRoot "_INTERN\governance\TASK_REQUIRED_READS_MATRIX.tsv"
if (-not (Test-Path -LiteralPath $matrixPath)) {
    Fail "FAIL: TASK_REQUIRED_READS_MATRIX.tsv missing: $matrixPath"
}

$lines = Get-Content -LiteralPath $matrixPath -Encoding UTF8
if ($lines.Count -lt 2) {
    Fail "FAIL: TASK_REQUIRED_READS_MATRIX.tsv empty: $matrixPath"
}

$rows = foreach ($line in ($lines | Select-Object -Skip 1)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split "`t", 4
    if ($parts.Count -lt 4) {
        Fail "FAIL: malformed matrix row: $line"
    }
    [pscustomobject]@{
        TaskType        = $parts[0].Trim()
        RequiredPrimary = $parts[1].Trim()
        RequiredMirror  = $parts[2].Trim()
        Optional        = $parts[3].Trim()
    }
}

$row = $rows | Where-Object { $_.TaskType -eq $TaskType } | Select-Object -First 1
if (-not $row) {
    Fail "FAIL: task type not found in matrix: $TaskType"
}

$required = @()
$required += Split-List $row.RequiredPrimary
$required += Split-List $row.RequiredMirror
$required = $required | Where-Object { $_ -ne "" }

if ($required.Count -eq 0) {
    Fail "FAIL: no required reads resolved for task type: $TaskType"
}

$resolved = foreach ($item in $required) {
    $path = Resolve-TokenToPath -Token $item -RepoRoot $RepoRoot -BrainRoot $BrainRoot -ClaudeRoot $ClaudeRoot
    [pscustomobject]@{
        Token   = $item
        Path    = $path
        Exists  = Test-Path -LiteralPath $path
        Kind    = if (Test-Path -LiteralPath $path -PathType Container) { "Dir" } elseif (Test-Path -LiteralPath $path -PathType Leaf) { "File" } else { "Missing" }
    }
}

$missing = $resolved | Where-Object { -not $_.Exists }
if ($missing) {
    $list = ($missing | ForEach-Object { $_.Path }) -join "`r`n"
    Fail "FAIL: required reads missing for task [$TaskType]:`r`n$list"
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$reportDir = Join-Path (Join-Path $RepoRoot "_local\chatpack") $ts
$reportDir = Join-Path $reportDir "SSOT"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$reportPath = Join-Path $reportDir ("REQUIRED_READS_PREFLIGHT_{0}.md" -f (($TaskType -replace '[^A-Za-z0-9]+','_').Trim('_').ToUpperInvariant()))
$body = @"
# Required Reads Preflight

## TaskType
$TaskType

## Matrix
$matrixPath

## Required Reads
$(
    ($resolved | ForEach-Object {
        "- [$($_.Kind)] $($_.Path)"
    }) -join "`r`n"
)

## Result
PASS
"@

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($reportPath, $body, $enc)

Write-Host "REPORT: $reportPath"
Write-Host "READS: $($resolved.Count)"
Write-Host "PASS: required reads preflight"