param(
    [ValidateSet('DryRun','Apply')]
    [string]$Mode = 'DryRun',
    [int]$AgeDays = 14,
    [switch]$IncludeEmptyDirs
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Ts = Get-Date -Format 'yyyyMMdd_HHmmss'

$ScratchRoot  = Join-Path $RepoRoot '_local\_scratch'
$ChatpackRoot = Join-Path $RepoRoot '_local\chatpack'
$ReportDir    = Join-Path $RepoRoot ('_local\chatpack\{0}\SSOT' -f $Ts)
$ReportPath   = Join-Path $ReportDir 'HYGIENE_SAFE_REPORT.md'

$AllowedRoots = @(
    [System.IO.Path]::GetFullPath($ScratchRoot),
    [System.IO.Path]::GetFullPath($ChatpackRoot)
)

function Test-AllowedScope {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    $full = [System.IO.Path]::GetFullPath($LiteralPath)
    foreach ($root in $AllowedRoots) {
        if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $full = [System.IO.Path]::GetFullPath($LiteralPath)
    if (-not $full.StartsWith([System.IO.Path]::GetFullPath((Split-Path -Parent $ReportDir)), [System.StringComparison]::OrdinalIgnoreCase)) {
        throw ('WRITE_NOT_ALLOWED: {0}' -f $LiteralPath)
    }

    $parent = Split-Path -Parent $LiteralPath
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($LiteralPath, $Content, $utf8NoBom)
}

$cutoff = (Get-Date).AddDays(-1 * $AgeDays)
$candidates = @()

if (Test-Path -LiteralPath $ScratchRoot) {
    $scratchFiles = Get-ChildItem -LiteralPath $ScratchRoot -File -Filter '*.ps1' |
        Where-Object { $_.LastWriteTime -lt $cutoff }

    foreach ($file in $scratchFiles) {
        if (-not (Test-AllowedScope -LiteralPath $file.FullName)) {
            continue
        }

        $candidates += [pscustomobject]@{
            Kind = 'FILE'
            Root = '_local\_scratch'
            Path = $file.FullName
            AgeDays = [int](((Get-Date) - $file.LastWriteTime).TotalDays)
        }
    }
}

if (Test-Path -LiteralPath $ChatpackRoot) {
    $chatpackDirs = Get-ChildItem -LiteralPath $ChatpackRoot -Directory |
        Where-Object { $_.LastWriteTime -lt $cutoff }

    foreach ($dir in $chatpackDirs) {
        if (-not (Test-AllowedScope -LiteralPath $dir.FullName)) {
            continue
        }

        $candidates += [pscustomobject]@{
            Kind = 'DIR'
            Root = '_local\chatpack'
            Path = $dir.FullName
            AgeDays = [int](((Get-Date) - $dir.LastWriteTime).TotalDays)
        }
    }
}

$emptyDirs = @()
if ($IncludeEmptyDirs.IsPresent) {
    $roots = @($ScratchRoot, $ChatpackRoot)
    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) {
            continue
        }

        $dirs = Get-ChildItem -LiteralPath $root -Recurse -Directory |
            Sort-Object FullName -Descending

        foreach ($dir in $dirs) {
            if (-not (Test-AllowedScope -LiteralPath $dir.FullName)) {
                continue
            }

            $entries = @(Get-ChildItem -LiteralPath $dir.FullName -Force)
            if ($entries.Count -eq 0) {
                $emptyDirs += [pscustomobject]@{
                    Kind = 'EMPTY_DIR'
                    Root = $root
                    Path = $dir.FullName
                    AgeDays = 0
                }
            }
        }
    }
}

$candidates = @($candidates + $emptyDirs | Sort-Object Path -Unique)

$applied = @()
if ($Mode -eq 'Apply') {
    foreach ($item in $candidates) {
        if (-not (Test-AllowedScope -LiteralPath $item.Path)) {
            throw ('OUT_OF_SCOPE_DELETE_BLOCKED: {0}' -f $item.Path)
        }

        if ($item.Kind -eq 'FILE') {
            Remove-Item -LiteralPath $item.Path -Force
            $applied += $item
        }
        elseif ($item.Kind -eq 'DIR' -or $item.Kind -eq 'EMPTY_DIR') {
            Remove-Item -LiteralPath $item.Path -Recurse -Force
            $applied += $item
        }
    }
}

$lines = @()
$lines += '# HYGIENE SAFE REPORT'
$lines += ''
$lines += ('- Timestamp: {0}' -f $Ts)
$lines += ('- Mode: {0}' -f $Mode)
$lines += ('- AgeDays: {0}' -f $AgeDays)
$lines += ('- IncludeEmptyDirs: {0}' -f $IncludeEmptyDirs.IsPresent)
$lines += ''
$lines += '## Allowed roots'
$lines += ''
foreach ($root in $AllowedRoots) {
    $lines += ('- {0}' -f $root)
}
$lines += ''
$lines += ('## Candidates ({0})' -f $candidates.Count)
$lines += ''
if ($candidates.Count -eq 0) {
    $lines += '- None.'
}
else {
    foreach ($item in $candidates) {
        $lines += ('- {0} | {1} | age={2} | {3}' -f $item.Kind, $item.Root, $item.AgeDays, $item.Path)
    }
}
$lines += ''
$lines += ('## Applied ({0})' -f $applied.Count)
$lines += ''
if ($applied.Count -eq 0) {
    $lines += '- None.'
}
else {
    foreach ($item in $applied) {
        $lines += ('- {0} | {1}' -f $item.Kind, $item.Path)
    }
}

Write-Utf8NoBom -LiteralPath $ReportPath -Content (($lines -join "`n") + "`n")

('{0} {1}' -f 'REPORT:', $ReportPath)
('{0} {1}' -f 'MODE:', $Mode)
('{0} {1}' -f 'CANDIDATES:', $candidates.Count)
('{0} {1}' -f 'APPLIED:', $applied.Count)
'PASS: hygiene-safe complete'