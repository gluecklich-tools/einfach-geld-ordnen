param()

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

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

foreach ($name in (Get-CandidateNames)) {
    $sourcePath = Get-PreferredSourcePath -Name $name
    if ($null -eq $sourcePath) { continue }

    $destPath = Join-Path $GovRoot $name
    if (-not (Test-Path -LiteralPath $destPath -PathType Leaf)) {
        Fail "DEST_MISSING: $name"
    }

    $sourceContent = Read-Utf8 -Path $sourcePath
    $destContent   = Read-Utf8 -Path $destPath

    if ($sourceContent -ne $destContent) {
        Fail "GOVERNANCE_ROOT_OUT_OF_SYNC: $name"
    }

    Write-Host ("OK={0}" -f $name)
}

Write-Host "PASS: governance root files sync gate"