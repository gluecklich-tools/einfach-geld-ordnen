#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoRoot
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$CanonicalInternRoot = 'C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN'
$RunnerPath = Join-Path $CanonicalInternRoot 'tools\ps-parser-lint-run.ps1'

if (-not (Test-Path -LiteralPath $RunnerPath -PathType Leaf)) {
    throw ('FAIL: parser lint runner missing: {0}' -f $RunnerPath)
}

& $RunnerPath -RepoRoot $RepoRoot
Write-Host 'PASS: gate ps parser all tools'
