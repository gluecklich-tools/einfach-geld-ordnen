param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ProjectRoot = (Resolve-Path (Join-Path $RepoRoot '..\..')).Path

$Roots = @(
    (Join-Path $ProjectRoot '_INTERN\tools')
    (Join-Path $RepoRoot '_INTERN\tools')
    (Join-Path $RepoRoot 'tools')
    (Join-Path $ProjectRoot '_INTERN\governance\tools')
) | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -Unique

$Files = foreach ($root in $Roots) {
    Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.ps1'
}

$Errors = New-Object System.Collections.Generic.List[string]

foreach ($file in $Files) {
    $null = $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors) | Out-Null
    foreach ($err in $parseErrors) {
        $Errors.Add(('{0}:{1}:{2}: {3}' -f $file.FullName, $err.Extent.StartLineNumber, $err.Extent.StartColumnNumber, $err.Message))
    }
}

Write-Host ("ROOT_COUNT={0}" -f @($Roots).Count)
Write-Host ("FILE_COUNT={0}" -f @($Files).Count)
Write-Host ("ERROR_COUNT={0}" -f $Errors.Count)

if ($Errors.Count -gt 0) {
    $Errors | ForEach-Object { Write-Host $_ }
    throw 'FAIL: parser gate found errors'
}

Write-Host 'PASS: parser gate all tool roots'
