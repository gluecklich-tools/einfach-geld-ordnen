#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)]
  [string]$Dir = ""
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $RepoRoot

if ([string]::IsNullOrWhiteSpace($Dir)) {
  $Dir = Join-Path $RepoRoot 'assets\audit\live_checklist'
}

if (-not (Test-Path -LiteralPath $Dir)) {
  throw ("Missing directory: " + $Dir)
}

$latest = Get-ChildItem -LiteralPath $Dir -File -Force |
  Where-Object { $_.Name -like 'live_checklist_*.md' } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $latest) {
  throw ("No live_checklist_*.md found in: " + $Dir)
}

$path = $latest.FullName
"OK: latest checklist: " + $path

$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if ($codeCmd) {
  & code -r $path
  "OK: opened in VS Code"
} else {
  notepad $path
  "OK: opened in Notepad (code not found in PATH)"
}