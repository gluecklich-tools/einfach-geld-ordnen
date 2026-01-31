$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 > $null
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$runner = Join-Path $PSScriptRoot 'tools\ego-run.ps1'
if (-not (Test-Path -LiteralPath $runner)) { throw "Missing runner: $runner" }
& $runner