[CmdletBinding()]
param(
    [AllowNull()][AllowEmptyCollection()][string[]]$ScanRoots = @(
        "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\tools",
        "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools"
    ),
    [switch]$ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-PowerShellFiles {
    param(
        [AllowNull()][AllowEmptyCollection()][string[]]$Roots
    )

    $files = New-Object System.Collections.Generic.List[string]

    foreach ($root in @($Roots)) {
        if ([string]::IsNullOrWhiteSpace($root)) {
            continue
        }

        if (-not (Test-Path -LiteralPath $root -PathType Container)) {
            continue
        }

        Get-ChildItem -LiteralPath $root -Recurse -File -Filter "*.ps1" -ErrorAction SilentlyContinue |
            ForEach-Object { $files.Add($_.FullName) | Out-Null }
    }

    return @($files.ToArray() | Sort-Object -Unique)
}

function Test-IsMandatoryParameter {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.ParameterAst]$ParameterAst
    )

    foreach ($attribute in @($ParameterAst.Attributes)) {
        if (-not ($attribute -is [System.Management.Automation.Language.AttributeAst])) {
            continue
        }

        $name = [string]$attribute.TypeName.Name
        $fullName = [string]$attribute.TypeName.FullName

        if ($name -ne "Parameter" -and $fullName -ne "Parameter") {
            continue
        }

        foreach ($namedArgument in @($attribute.NamedArguments)) {
            if ([string]$namedArgument.ArgumentName -ne "Mandatory") {
                continue
            }

            if ($null -eq $namedArgument.Argument) {
                continue
            }

            $argumentText = ([string]$namedArgument.Argument.Extent.Text).Trim()
            if ($argumentText -match '^\$true$' -or $argumentText -match '^true$') {
                return $true
            }
        }
    }

    return $false
}

function Test-HasAllowEmptyCollection {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.ParameterAst]$ParameterAst
    )

    foreach ($attribute in @($ParameterAst.Attributes)) {
        if (-not ($attribute -is [System.Management.Automation.Language.AttributeAst])) {
            continue
        }

        $name = [string]$attribute.TypeName.Name
        $fullName = [string]$attribute.TypeName.FullName

        if ($name -eq "AllowEmptyCollection" -or $fullName -like "*AllowEmptyCollection*") {
            return $true
        }
    }

    return $false
}

function Test-IsArrayParameter {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.ParameterAst]$ParameterAst
    )

    if ($null -eq $ParameterAst.StaticType) {
        return $false
    }

    return [bool]$ParameterAst.StaticType.IsArray
}

$issues = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$files = @(Get-PowerShellFiles -Roots $ScanRoots)

foreach ($file in $files) {
    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)

    if (@($parseErrors).Count -gt 0) {
        foreach ($parseError in @($parseErrors)) {
            $issues.Add(("PARSER_ERROR:{0}:L{1}:{2}" -f $file, $parseError.Extent.StartLineNumber, $parseError.Message)) | Out-Null
        }
        continue
    }

    $parameterAsts = @(
        $ast.FindAll(
            {
                param($node)
                $node -is [System.Management.Automation.Language.ParameterAst]
            },
            $true
        )
    )

    foreach ($parameterAst in $parameterAsts) {
        $isMandatory = Test-IsMandatoryParameter -ParameterAst $parameterAst
        $isArray = Test-IsArrayParameter -ParameterAst $parameterAst
        $hasAllowEmptyCollection = Test-HasAllowEmptyCollection -ParameterAst $parameterAst

        if ($isMandatory -and $isArray -and -not $hasAllowEmptyCollection) {
            $paramName = [string]$parameterAst.Name.VariablePath.UserPath
            $line = [int]$parameterAst.Extent.StartLineNumber
            $staticType = [string]$parameterAst.StaticType.FullName

            $issue = "MANDATORY_ARRAY_WITHOUT_ALLOW_EMPTY_COLLECTION:{0}:L{1}:PARAM={2}:TYPE={3}" -f $file, $line, $paramName, $staticType
            $issues.Add($issue) | Out-Null
        }
    }
}

$status = "PASS"
if ($issues.Count -gt 0) {
    $status = "FAIL"
}

"STATUS=$status"
"SCAN_FILE_COUNT=$($files.Count)"
"ISSUE_COUNT=$($issues.Count)"
"WARNING_COUNT=$($warnings.Count)"

foreach ($issue in @($issues.ToArray())) {
    "ISSUE=$issue"
}

foreach ($warning in @($warnings.ToArray())) {
    "WARNING=$warning"
}

if ($status -ne "PASS" -and -not $ReportOnly) {
    exit 1
}

exit 0