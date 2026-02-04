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
if (-not (Test-Path -LiteralPath $Dir)) { throw ("Missing directory: " + $Dir) }

function Get-Latest {
  param([string]$Pattern)
  Get-ChildItem -LiteralPath $Dir -File -Force |
    Where-Object { $_.Name -like $Pattern } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
}

$latestChecklist = Get-Latest -Pattern 'live_checklist_*.md'
$latestExplainer = Get-Latest -Pattern 'live_check_explainer_*.md'

if (-not $latestChecklist) { throw ("No live_checklist_*.md found in: " + $Dir) }
"OK: latest checklist: " + $latestChecklist.FullName

if ($latestExplainer) {
  "OK: latest explainer: " + $latestExplainer.FullName
} else {
  "WARN: no live_check_explainer_*.md found (yet)."
}

$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if ($codeCmd) {
  & code -r $latestChecklist.FullName
  if ($latestExplainer) { & code -r $latestExplainer.FullName }
  "OK: opened in VS Code"
} else {
  notepad $latestChecklist.FullName
  if ($latestExplainer) { notepad $latestExplainer.FullName }
  "OK: opened in Notepad (code not found in PATH)"
}