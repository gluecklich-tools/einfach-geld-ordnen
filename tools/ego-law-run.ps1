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
if (-not (Test-Path -LiteralPath '.\tools\ego-run.ps1')) { throw 'Missing: tools\ego-run.ps1' }
if (Test-Path -LiteralPath '.\tools\no-murx-gate.ps1') { & .\tools\no-murx-gate.ps1 }
# --- 1) APPLY (idempotent only): run all tools\apply-*.ps1 if present
$apply = Get-ChildItem -LiteralPath '.\tools' -File -Filter 'apply-*.ps1' -ErrorAction SilentlyContinue
foreach ($a in $apply) { & $a.FullName }
# --- 2) GATES
.\tools\ego-run.ps1
foreach ($s in @('.\tools\release-gate-0.ps1','.\tools\mvp02-run.ps1','.\tools\stress-baseline.ps1')) {
  if (Test-Path -LiteralPath $s) { & $s }
}
# --- 3) COMMIT/PUSH only if changed
$porc = git status --porcelain
if ($porc) {
  git add -A
  git commit -m 'LawRun: apply + gates (2026-01-31)'
  Invoke-GitPushSafe -Remote 'origin' -Branch 'main'
} else {
  'NO_COMMIT: worktree clean'
}
# --- 4) LIVE HEAD 200 smoke
$u = @(
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/index.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/downloads.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/rechner-index.html'
)
foreach ($x in $u) {
  try { (Invoke-WebRequest -UseBasicParsing -Method Head -Uri $x -TimeoutSec 20).StatusCode.ToString() + ' ' + $x }
  catch { throw ('LIVE_FAIL ' + $x) }
}