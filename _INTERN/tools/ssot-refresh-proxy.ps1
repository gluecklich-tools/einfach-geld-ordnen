param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ScriptRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path
$InternRoot  = Split-Path -Parent $ScriptRoot
$ProjectRoot = Split-Path -Parent $InternRoot
$RepoRoot    = Join-Path (Join-Path $ProjectRoot "GitHub_Clone_Dateien") "einfach-geld-ordnen"

function Fail([string]$Message) {
    throw ("FAIL: {0}" -f $Message)
}

function Ensure-RepoRoot {
    if (-not (Test-Path -LiteralPath $RepoRoot)) {
        Fail ("RepoRoot fehlt: {0}" -f $RepoRoot)
    }
    $gitDir = Join-Path $RepoRoot ".git"
    if (-not (Test-Path -LiteralPath $gitDir)) {
        Fail ("RepoRoot ist kein Git-Repo: {0}" -f $RepoRoot)
    }
}

function Run-StepIfExists([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $Path
    if ($LASTEXITCODE -ne 0) {
        Fail ("Substep fehlgeschlagen: {0}" -f $Path)
    }
    return $true
}

function Get-UntrackedMirrorPaths {
    Push-Location $RepoRoot
    try {
        $gitStatus = @(git status --short)
        if ($LASTEXITCODE -ne 0) {
            Fail "git status --short fehlgeschlagen."
        }

        $trackedFiles = @(git ls-files)
        if ($LASTEXITCODE -ne 0) {
            Fail "git ls-files fehlgeschlagen."
        }

        $trackedSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($f in $trackedFiles) {
            [void]$trackedSet.Add($f)
        }

        $targets = New-Object System.Collections.Generic.List[string]
        foreach ($line in $gitStatus) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            if ($line -match '^\?\?\s+(.*)$') {
                $path = $Matches[1].Trim()
                if (($path -like 'Brain_EGO_Dateien*') -or ($path -like '_INTERN/governance*')) {
                    if ($trackedSet.Contains($path)) {
                        Fail ("Tracked Datei in Mirror-Purge-Ziel gefunden: {0}" -f $path)
                    }
                    $targets.Add($path) | Out-Null
                }
            }
        }

        return @($targets | Sort-Object -Unique)
    }
    finally {
        Pop-Location
    }
}

function Invoke-AutoPurgeMirrorArtifacts {
    $targets = @(Get-UntrackedMirrorPaths)
    if ($targets.Count -eq 0) {
        return @{
            Removed = @()
            Status  = "none"
        }
    }

    Push-Location $RepoRoot
    try {
        foreach ($target in $targets) {
            $full = Join-Path $RepoRoot $target
            if (Test-Path -LiteralPath $full) {
                Remove-Item -LiteralPath $full -Recurse -Force
            }
        }
    }
    finally {
        Pop-Location
    }

    return @{
        Removed = $targets
        Status  = "purged"
    }
}

function Assert-RepoCleanAfterFullsync {
    Push-Location $RepoRoot
    try {
        $afterStatus = @(git status --short)
        if ($LASTEXITCODE -ne 0) {
            Fail "git status --short nach Fullsync fehlgeschlagen."
        }
        if ($afterStatus.Count -gt 0) {
            $joined = ($afterStatus -join "; ")
            Fail ("Repo nach Fullsync nicht clean: {0}" -f $joined)
        }
    }
    finally {
        Pop-Location
    }
}

Ensure-RepoRoot

$steps = @(
    (Join-Path $ScriptRoot "ssot-refresh-latest.ps1"),
    (Join-Path $ScriptRoot "ssot-refresh-mirror.ps1"),
    (Join-Path $ScriptRoot "ssot-fullsync-all.ps1")
)

$ran = New-Object System.Collections.Generic.List[string]
foreach ($step in $steps) {
    if (Run-StepIfExists -Path $step) {
        $ran.Add($step) | Out-Null
    }
}

$purgeResult = Invoke-AutoPurgeMirrorArtifacts
Assert-RepoCleanAfterFullsync

foreach ($item in $ran) {
    Write-Host ("RUN: {0}" -f $item)
}
Write-Host ("AUTOPURGE_STATUS: {0}" -f $purgeResult.Status)
foreach ($item in $purgeResult.Removed) {
    Write-Host ("AUTOPURGE_REMOVED: {0}" -f $item)
}
Write-Host "PASS: ssot refresh proxy with autopurge and repo clean verify"