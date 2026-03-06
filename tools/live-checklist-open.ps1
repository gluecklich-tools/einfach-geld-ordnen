param(
  [string]$Dir = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $RepoRoot

if ([string]::IsNullOrWhiteSpace($Dir)) {
  $Dir = Join-Path $RepoRoot 'assets\audit\live_checklist'
}
if (-not (Test-Path -LiteralPath $Dir)) { throw ("Missing directory: " + $Dir) }

function Get-Latest {
  param([string]$Pattern)

  $dirInfo = [System.IO.DirectoryInfo]::new($Dir)
  if (-not $dirInfo.Exists) { return $null }

  $best = $null
  foreach($f in $dirInfo.EnumerateFiles($Pattern, [System.IO.SearchOption]::TopDirectoryOnly)){
    if ($null -eq $best) {
      $best = $f
      continue
    }
    if ($f.LastWriteTimeUtc -gt $best.LastWriteTimeUtc) {
      $best = $f
      continue
    }
    if ($f.LastWriteTimeUtc -eq $best.LastWriteTimeUtc -and $f.Name -gt $best.Name) {
      $best = $f
    }
  }

  return $best
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