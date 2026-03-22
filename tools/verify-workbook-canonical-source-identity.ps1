param(
    [string]$ManifestPath = 'C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\WORKBOOK_CANONICAL_SOURCE_MANIFEST_20260322.tsv',
    [string]$ReportPath = '',
    [string]$JsonPath = '',
    [switch]$FailOnAnyDrift
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FileSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw ('FAIL: file missing: {0}' -f $Path)
    }
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToUpperInvariant()
}

function Get-ZipMemberSha256 {
    param(
        [Parameter(Mandatory = $true)][string]$ZipPath,
        [Parameter(Mandatory = $true)][string]$MemberName
    )

    if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) {
        throw ('FAIL: zip missing: {0}' -f $ZipPath)
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        $entry = $zip.Entries |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_.FullName) -and
                ([System.IO.Path]::GetFileName($_.FullName)).Equals($MemberName, [System.StringComparison]::OrdinalIgnoreCase)
            } |
            Select-Object -First 1

        if ($null -eq $entry) {
            throw ('FAIL: zip member missing: {0} :: {1}' -f $ZipPath, $MemberName)
        }

        $stream = $entry.Open()
        try {
            $sha = [System.Security.Cryptography.SHA256]::Create()
            try {
                $hashBytes = $sha.ComputeHash($stream)
                return ([System.BitConverter]::ToString($hashBytes)).Replace('-', '').ToUpperInvariant()
            }
            finally {
                $sha.Dispose()
            }
        }
        finally {
            $stream.Dispose()
        }
    }
    finally {
        $zip.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw ('FAIL: manifest missing: {0}' -f $ManifestPath)
}

$rows = Import-Csv -LiteralPath $ManifestPath -Delimiter "`t"
$results = New-Object System.Collections.Generic.List[object]
$driftCount = 0

foreach ($row in $rows) {
    $targetPath = $row.path

    $actual = if ($targetPath -match '^(.*\.zip)::([^:]+)$') {
        $zipPath = $Matches[1]
        $memberName = $Matches[2]
        Get-ZipMemberSha256 -ZipPath $zipPath -MemberName $memberName
    }
    else {
        Get-FileSha256 -Path $targetPath
    }

    $matches = [string]::Equals($actual, $row.expected_sha256, [System.StringComparison]::OrdinalIgnoreCase)
    if (-not $matches) {
        $driftCount++
    }

    $results.Add([pscustomobject]@{
        tier            = $row.tier
        format          = $row.format
        role            = $row.role
        state           = $row.state
        path            = $row.path
        expected_sha256 = $row.expected_sha256
        actual_sha256   = $actual
        matches         = $matches
    }) | Out-Null
}

$summary = [pscustomobject]@{
    manifest   = $ManifestPath
    checked_at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    total      = $results.Count
    drifts     = $driftCount
    rows       = $results
}

if (-not [string]::IsNullOrWhiteSpace($JsonPath)) {
    $summary | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $JsonPath -Encoding utf8NoBOM
}

if (-not [string]::IsNullOrWhiteSpace($ReportPath)) {
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# WORKBOOK CANONICAL SOURCE VERIFY REPORT') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add(('- manifest: {0}' -f $ManifestPath)) | Out-Null
    $lines.Add(('- total: {0}' -f $results.Count)) | Out-Null
    $lines.Add(('- drifts: {0}' -f $driftCount)) | Out-Null
    $lines.Add('') | Out-Null

    foreach ($item in $results) {
        $lines.Add(('## {0} {1} {2}' -f $item.tier, $item.format.ToUpperInvariant(), $item.role)) | Out-Null
        $lines.Add(('- matches: {0}' -f $item.matches)) | Out-Null
        $lines.Add(('- expected_sha256: {0}' -f $item.expected_sha256)) | Out-Null
        $lines.Add(('- actual_sha256: {0}' -f $item.actual_sha256)) | Out-Null
        $lines.Add(('- path: {0}' -f $item.path)) | Out-Null
        $lines.Add('') | Out-Null
    }

    [System.IO.File]::WriteAllLines($ReportPath, $lines.ToArray(), [System.Text.UTF8Encoding]::new($false))
}

$summary

if ($FailOnAnyDrift -and $driftCount -gt 0) {
    throw ('FAIL: workbook artifact identity drift count = {0}' -f $driftCount)
}