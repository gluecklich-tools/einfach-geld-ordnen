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

function Write-Utf8NoBomLfFromExistingText {
    param([Parameter(Mandatory = $true)][string]$Path)

    $text = [System.IO.File]::ReadAllText($Path)
    $normalized = $text -replace "`r`n", "`n"
    $normalized = $normalized -replace "`r", "`n"
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $normalized, $enc)
}

$changed = New-Object System.Collections.Generic.List[string]
$ok      = New-Object System.Collections.Generic.List[string]

foreach ($relative in $Targets) {
    $fullPath = Join-Path $RepoRoot ($relative -replace '/', '\')
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "TARGET_MISSING: $relative"
    }

    $before = Get-LineEndingKind -Path $fullPath
    if ($before -eq "LF" -or $before -eq "NO_NEWLINES") {
        $ok.Add($relative) | Out-Null
        continue
    }

    Write-Utf8NoBomLfFromExistingText -Path $fullPath

    $after = Get-LineEndingKind -Path $fullPath
    if ($after -ne "LF" -and $after -ne "NO_NEWLINES") {
        throw "LF_NORMALIZE_FAILED: $relative -> $after"
    }

    $changed.Add($relative) | Out-Null
}

Write-Host ("CHANGED_COUNT={0}" -f $changed.Count)
foreach ($x in $changed) { Write-Host ("CHANGED={0}" -f $x) }
foreach ($x in $ok)      { Write-Host ("OK={0}" -f $x) }
Write-Host "PASS: normalize governance core lf"