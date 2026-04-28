[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ZipPath,
    [int]$MaxEntries = 8000,
    [double]$MaxExpandedMb = 750.0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) {
    throw ("ZIP_NOT_FOUND:{0}" -f $ZipPath)
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $entries = @($zip.Entries)
    $expandedBytes = ($entries | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $expandedBytes) { $expandedBytes = 0 }
    $expandedMb = [math]::Round(($expandedBytes / 1MB), 2)

    $forbidden = @(
        $entries | Where-Object {
            $_.FullName -match "(?i)(^|/)_local/" -or
            $_.FullName -match "(?i)(openxml|extract|rezip|snapshot|working|forensic|fullread)" -or
            $_.FullName -match "(?i)(workbook_backups|sync_backups)" -or
            $_.FullName -match "(?i)(GitHub_Clone_Dateien/.*/GitHub_Clone_Dateien)" -or
            $_.FullName -match "(?i)(node_modules|\.venv|__pycache__)"
        }
    )

    $status = "PASS"
    if ($entries.Count -gt $MaxEntries -or $expandedMb -gt $MaxExpandedMb -or $forbidden.Count -gt 0) {
        $status = "FAIL"
    }

    "STATUS=$status"
    "ZIP_PATH=$ZipPath"
    "ENTRY_COUNT=$($entries.Count)"
    "EXPANDED_MB=$expandedMb"
    "FORBIDDEN_ENTRY_COUNT=$($forbidden.Count)"
    $forbidden | Select-Object -First 100 | ForEach-Object { "FORBIDDEN_ENTRY=$($_.FullName)" }

    if ($status -ne "PASS") { exit 1 }
    exit 0
}
finally {
    $zip.Dispose()
}
