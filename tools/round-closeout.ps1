#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ConfirmPreference="None"
$ProgressPreference="SilentlyContinue"

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$InternalTools = Join-Path $ProjectRoot "_INTERN\tools"

$ssot = Join-Path $InternalTools "ssot-refresh-proxy.ps1"
if(!(Test-Path -LiteralPath $ssot -PathType Leaf)){
  throw "Missing ssot-refresh-proxy: $ssot"
}

Write-Host "== ROUND CLOSEOUT ==" -ForegroundColor Cyan
& pwsh -NoProfile -ExecutionPolicy Bypass -File $ssot

"PASS: round-closeout"