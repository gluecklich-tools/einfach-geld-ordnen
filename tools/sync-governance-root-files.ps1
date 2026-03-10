param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ToolPath    = $MyInvocation.MyCommand.Path
$ToolsRoot   = Split-Path -Parent $ToolPath
$RepoRoot    = Split-Path -Parent $ToolsRoot
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $RepoRoot)

$BrainRoot   = Join-Path $ProjectRoot "Brain_EGO_Dateien"
$InternRoot  = Join-Path $ProjectRoot "_INTERN"
$GovRoot     = Join-Path $InternRoot "governance"
$BrainMirror = Join-Path $GovRoot "brain_mirror"

function Fail {
    param([Parameter(Mandatory = $true)][string]$Message)
    throw $Message
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $dir = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Read-Utf8 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Get-CandidateNames {
    $names = New-Object System.Collections.Generic.HashSet[string] ([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($root in @($BrainRoot, $BrainMirror)) {
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }

        $files = Get-ChildItem -LiteralPath $root -File -Force |
            Where-Object { $_.Extension -in @(".md", ".json", ".tsv", ".txt") }

        foreach ($f in $files) {
            [void]$names.Add($f.Name)
        }
    }

    return @($names | Sort-Object)
}

function Get-PreferredSourcePath {
    param([Parameter(Mandatory = $true)][string]$Name)

    $brainPath  = Join-Path $BrainRoot $Name
    $mirrorPath = Join-Path $BrainMirror $Name

    $brainExists  = Test-Path -LiteralPath $brainPath -PathType Leaf
    $mirrorExists = Test-Path -LiteralPath $mirrorPath -PathType Leaf

    if ($brainExists -and $mirrorExists) {
        $brainItem  = Get-Item -LiteralPath $brainPath
        $mirrorItem = Get-Item -LiteralPath $mirrorPath
        if ($brainItem.LastWriteTimeUtc -ge $mirrorItem.LastWriteTimeUtc) {
            return $brainPath
        }
        return $mirrorPath
    }

    if ($brainExists)  { return $brainPath }
    if ($mirrorExists) { return $mirrorPath }

    return $null
}

if (-not (Test-Path -LiteralPath $GovRoot -PathType Container)) {
    Fail "GOV_ROOT_MISSING: $GovRoot"
}

$changed = New-Object System.Collections.Generic.List[string]
$ok      = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]

foreach ($name in (Get-CandidateNames)) {
    $sourcePath = Get-PreferredSourcePath -Name $name
    if ($null -eq $sourcePath) {
        $skipped.Add($name) | Out-Null
        continue
    }

    $destPath = Join-Path $GovRoot $name
    $sourceContent = Read-Utf8 -Path $sourcePath
    $destContent = $null

    if (Test-Path -LiteralPath $destPath -PathType Leaf) {
        $destContent = Read-Utf8 -Path $destPath
    }

    if ($destContent -ne $sourceContent) {
        Write-Utf8NoBom -Path $destPath -Content $sourceContent
        $changed.Add($name) | Out-Null
    } else {
        $ok.Add($name) | Out-Null
    }
}

Write-Host ("CHANGED_COUNT={0}" -f $changed.Count)
foreach ($n in $changed) { Write-Host ("CHANGED={0}" -f $n) }
foreach ($n in $ok)      { Write-Host ("OK={0}" -f $n) }
foreach ($n in $skipped) { Write-Host ("SKIPPED={0}" -f $n) }
Write-Host "PASS: sync governance root files"