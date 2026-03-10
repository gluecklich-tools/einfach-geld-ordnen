param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ToolPath  = $MyInvocation.MyCommand.Path
$ToolsRoot = Split-Path -Parent $ToolPath
$RepoRoot  = Split-Path -Parent $ToolsRoot
Set-Location -LiteralPath $RepoRoot

$Targets = @(
    "tools/ego-flow-gates.ps1",
    "tools/gate-closeout-after-commit.ps1",
    "tools/gate-governance-root-files-sync.ps1",
    "tools/sync-governance-root-files.ps1"
)

function Get-LineEndingKind {
    param([Parameter(Mandatory = $true)][string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $hasCrLf = $false
    $hasLf = $false
    $hasBareCr = $false

    for ($i = 0; $i -lt $bytes.Length; $i++) {
        if ($bytes[$i] -eq 13) {
            if (($i + 1) -lt $bytes.Length -and $bytes[$i + 1] -eq 10) {
                $hasCrLf = $true
                $i++
            } else {
                $hasBareCr = $true
            }
        } elseif ($bytes[$i] -eq 10) {
            $hasLf = $true
        }
    }

    if ($hasBareCr) { return "CR" }
    if ($hasCrLf -and $hasLf) { return "MIXED" }
    if ($hasCrLf) { return "CRLF" }
    if ($hasLf) { return "LF" }
    return "NO_NEWLINES"
}

foreach ($relative in $Targets) {
    $fullPath = Join-Path $RepoRoot ($relative -replace '/', '\')
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "TARGET_MISSING: $relative"
    }

    $kind = Get-LineEndingKind -Path $fullPath
    if ($kind -ne "LF" -and $kind -ne "NO_NEWLINES") {
        throw "GOVERNANCE_CORE_NOT_LF: $relative -> $kind"
    }

    Write-Host ("OK={0}" -f $relative)
}

Write-Host "PASS: governance core lf gate"