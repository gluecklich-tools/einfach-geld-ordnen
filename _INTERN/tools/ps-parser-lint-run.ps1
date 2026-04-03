#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoRoot,
    [string[]]$ExtraPaths = @()
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Fail {
    param([Parameter(Mandatory = $true)][string]$Message)
    throw ('FAIL: {0}' -f $Message)
}

function Should-ExcludeParserScope {
    param([Parameter(Mandatory = $true)][string]$Path)

    $Full = [System.IO.Path]::GetFullPath($Path)
    $Needles = @(
        '\_local\_scratch\_broken\',
        '\_local\_scratch\_patch_backups\',
        '\_local\_scratch\projectwide_perfection_sync_apply',
        '\_patch_backups\',
        '\_backup\',
        '\archive\',
        '\_archive\'
    )

    foreach ($Needle in $Needles) {
        if ($Full.IndexOf($Needle, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            return $true
        }
    }

    return $false
}

$ResolvedRepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$Targets = New-Object System.Collections.Generic.List[string]

# Active default scope only: repo tools.
$DefaultTargets = @(
    (Join-Path $ResolvedRepoRoot 'tools')
)

foreach ($PathItem in @($DefaultTargets + $ExtraPaths)) {
    if ([string]::IsNullOrWhiteSpace($PathItem)) { continue }
    if (-not (Test-Path -LiteralPath $PathItem)) { continue }

    $ResolvedTarget = (Resolve-Path -LiteralPath $PathItem).Path
    if (Should-ExcludeParserScope -Path $ResolvedTarget) { continue }

    [void]$Targets.Add($ResolvedTarget)
}

$Files = New-Object System.Collections.Generic.List[object]

foreach ($Target in ($Targets | Select-Object -Unique)) {
    if (Test-Path -LiteralPath $Target -PathType Leaf) {
        if ($Target -like '*.ps1' -and -not (Should-ExcludeParserScope -Path $Target)) {
            [void]$Files.Add((Get-Item -LiteralPath $Target -Force))
        }
        continue
    }

    if (Test-Path -LiteralPath $Target -PathType Container) {
        $Found = Get-ChildItem -LiteralPath $Target -Recurse -File -Filter '*.ps1' -ErrorAction SilentlyContinue |
            Where-Object { -not (Should-ExcludeParserScope -Path $_.FullName) }

        foreach ($File in $Found) {
            [void]$Files.Add($File)
        }
    }
}

$UniqueFiles = @($Files | Sort-Object FullName -Unique)

if (@($UniqueFiles).Count -eq 0) {
    Fail 'NO_PS1_FILES_FOUND_FOR_PARSER_LINT'
}

$Errors = New-Object System.Collections.Generic.List[object]

foreach ($File in $UniqueFiles) {
    $Tokens = $null
    $ParseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$Tokens, [ref]$ParseErrors)

    foreach ($ParseError in @($ParseErrors)) {
        [void]$Errors.Add([pscustomobject]@{
            path    = $File.FullName
            line    = $ParseError.Extent.StartLineNumber
            column  = $ParseError.Extent.StartColumnNumber
            message = $ParseError.Message
        })
    }
}

if ($Errors.Count -gt 0) {
    foreach ($Item in $Errors) {
        Write-Host ('PARSER_ERROR: {0}:{1}:{2} | {3}' -f $Item.path, $Item.line, $Item.column, $Item.message)
    }
    Fail ('PARSER_LINT_FAILED: {0} error(s)' -f $Errors.Count)
}

Write-Host ('PARSER_LINT_FILE_COUNT: {0}' -f @($UniqueFiles).Count)
Write-Host 'PASS: ps parser lint run'

# EGO_MANAGED_BLOCK:APRIL03_PARSERROOTS:START
# Parser/Lint muessen `_INTERN\tools`, `repo\_INTERN\tools`, `repo\tools`, `_INTERN\governance\tools` abdecken.
# EGO_MANAGED_BLOCK:APRIL03_PARSERROOTS:END
