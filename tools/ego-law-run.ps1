$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 > $null
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
function Invoke-GitPushSafe {
  param([string]$Remote='origin',[string]$Branch='main')
  $eap = $ErrorActionPreference
  $out = ''
  try {
    $ErrorActionPreference='Continue'
    $out = (git push $Remote $Branch 2>&1 | Out-String)
  } finally { $ErrorActionPreference=$eap }
  if ($out -match 'Everything up-to-date' -or $out -match 'To ' -or $out -match '->') { 'PUSH_OK'; return }
  throw ("PUSH_FAIL:`n" + $out)
}
# Ensure we run from repo root even if called from elsewhere
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
Set-Location -LiteralPath $root
if (-not (Test-Path -LiteralPath '.\tools\ego-run.ps1')) { throw 'Missing: tools\ego-run.ps1' }
# 0) Pre-gate: no-murx gate if present
if (Test-Path -LiteralPath '.\tools\no-murx-gate.ps1') { & .\tools\no-murx-gate.ps1 }
# 1) APPLY (idempotent only): run all tools\apply-*.ps1 if present
$apply = Get-ChildItem -LiteralPath '.\tools' -File -Filter 'apply-*.ps1' -ErrorAction SilentlyContinue
foreach ($a in $apply) { & $a.FullName }
# 2) GATES (always)
.\tools\ego-run.ps1
foreach ($s in @('.\tools\release-gate-0.ps1','.\tools\mvp02-run.ps1','.\tools\stress-baseline.ps1')) {
  if (Test-Path -LiteralPath $s) { & $s }
}
# 3) COMMIT/PUSH only if changed
$dirtyBefore = [bool](git status --porcelain)
$commitDone = $false
if ($dirtyBefore) {
  git add -A
  $d = (Get-Date).ToString('yyyy-MM-dd')
  git commit -m ("LawRun: apply + gates " + $d)
  Invoke-GitPushSafe -Remote 'origin' -Branch 'main'
  $commitDone = $true
} else {
  'NO_COMMIT: worktree clean'
}
$dirtyAfter = [bool](git status --porcelain)
("REPO_DIRTY_BEFORE=" + $dirtyBefore.ToString().ToUpperInvariant())
("COMMIT_DONE=" + $commitDone.ToString().ToUpperInvariant())
("REPO_DIRTY_AFTER=" + $dirtyAfter.ToString().ToUpperInvariant())
if ($dirtyAfter) { throw 'LAW_RUN_FAIL: repo still dirty after run' }
# 4) LIVE HEAD 200 smoke (always)
$u = @(
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/index.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/downloads.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/rechner-index.html'
)
foreach ($x in $u) {
  try {
    $sc = (Invoke-WebRequest -UseBasicParsing -Method Head -Uri $x -TimeoutSec 20).StatusCode
    if ($sc -ne 200) { throw ("HTTP_" + $sc + " " + $x) }
    ("200 " + $x)
  }
  catch {
    throw ("LIVE_FAIL " + $x)
  }
}
"LAW_RUN_OK"