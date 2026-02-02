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
# Ensure we run from repo root
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
Set-Location -LiteralPath $root
if (-not (Test-Path -LiteralPath '.\tools\ego-run.ps1')) { throw 'Missing: tools\ego-run.ps1' }
# Runlog (evidence)
$runDir = Join-Path $root 'assets\audit\_runs'
if (-not (Test-Path -LiteralPath $runDir)) { New-Item -ItemType Directory -Force -Path $runDir | Out-Null }
$runId = (Get-Date).ToString('yyyy-MM-dd_HHmmss')
$runLog = Join-Path $runDir ("run_" + $runId + ".txt")
$env:EGO_RUNLOG_PATH = $runLog
("RUN_ID=" + $runId) | Tee-Object -FilePath $runLog -Append | Out-Null
function Run-Logged {
  param([Parameter(Mandatory=$true)][scriptblock]$Sb)
  # Important: run external scripts with StrictMode OFF to avoid legacy undefined-var fails.
  & {
    $oldEap = $ErrorActionPreference
    try {
      $ErrorActionPreference = 'Stop'
      Set-StrictMode -Off
      & $Sb
    } finally {
      $ErrorActionPreference = $oldEap
    }
  } *>&1 | Tee-Object -FilePath $runLog -Append | Out-Null
}
# 0) Pre-gate
if (Test-Path -LiteralPath '.\tools\no-murx-gate.ps1') { Run-Logged { & .\tools\no-murx-gate.ps1 } }
# 1) APPLY (idempotent only)
$apply = Get-ChildItem -LiteralPath '.\tools' -File -Filter 'apply-*.ps1' -ErrorAction SilentlyContinue
foreach ($a in $apply) { Run-Logged { & $a.FullName } }
# 2) GATES (always)
Run-Logged { & .\tools\ego-run.ps1 }
foreach ($s in @('.\tools\release-gate-0.ps1','.\tools\mvp02-run.ps1','.\tools\stress-baseline.ps1')) {
  if (Test-Path -LiteralPath $s) { Run-Logged { & $s } }
}
# 2b) AUDIT pack (optional) - must run BEFORE commit
foreach ($s in @('.\tools\audit-l2-pack.ps1')) {
  if (Test-Path -LiteralPath $s) { Run-Logged { & $s } }
}
# --- MVP02_GATE_HOOK_START ---
# Ensure MVP02 gate always runs inside LawRun
& (Join-Path $PSScriptRoot 'mvp02-gate.ps1')
if ($LASTEXITCODE -ne 0) { throw "mvp02-gate FAILED (exit $LASTEXITCODE)" }
# --- MVP02_GATE_HOOK_END ---



# 3) COMMIT/PUSH only if changed
$dirtyBefore = [bool](git status --porcelain)
$commitDone = $false
if ($dirtyBefore) {

# EGO_LF_GUARD_AUDITMD_V2
function Convert-EgoFile-ToLFNoBOM {
  param([Parameter(Mandatory=$true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return }
  $u = New-Object System.Text.UTF8Encoding($false)
  [byte[]]$bb = [System.IO.File]::ReadAllBytes($Path)
  if ($bb.Length -ge 3 -and $bb[0] -eq 0xEF -and $bb[1] -eq 0xBB -and $bb[2] -eq 0xBF) {
    $bb = $bb[3..($bb.Length-1)]
  }
  $tx = $u.GetString($bb)
  $cr = [string][char]13
  $lf = [string][char]10
  $tx = $tx.Replace(($cr + $lf), $lf).Replace($cr, $lf)
  [System.IO.File]::WriteAllBytes($Path, $u.GetBytes($tx))
}

# normalize audit.md BEFORE any git add/commit to avoid CRLF warning
$__repo  = Split-Path -Parent $PSScriptRoot
$__audit = Join-Path $__repo 'seiten\audit.md'
Convert-EgoFile-ToLFNoBOM -Path $__audit
  git add -A
  $d = (Get-Date).ToString('yyyy-MM-dd')
  git commit -m ("LawRun: apply + gates " + $d)
  Invoke-GitPushSafe -Remote 'origin' -Branch 'main'
  $commitDone = $true
} else {
  'NO_COMMIT: worktree clean' | Tee-Object -FilePath $runLog -Append | Out-Null
}
$dirtyAfter = [bool](git status --porcelain)
("REPO_DIRTY_BEFORE=" + $dirtyBefore.ToString().ToUpperInvariant()) | Tee-Object -FilePath $runLog -Append | Out-Null
("COMMIT_DONE=" + $commitDone.ToString().ToUpperInvariant()) | Tee-Object -FilePath $runLog -Append | Out-Null
("REPO_DIRTY_AFTER=" + $dirtyAfter.ToString().ToUpperInvariant()) | Tee-Object -FilePath $runLog -Append | Out-Null
if ($dirtyAfter) { throw 'LAW_RUN_FAIL: repo still dirty after run' }
# 4) LIVE HEAD 200 smoke (always)
$u = @(
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/index.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/downloads.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/rechner-index.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/audit.html'
)
foreach ($x in $u) {
  try {
    $sc = (Invoke-WebRequest -UseBasicParsing -Method Head -Uri $x -TimeoutSec 20).StatusCode
    if ($sc -ne 200) { throw ("HTTP_" + $sc + " " + $x) }
    ("200 " + $x) | Tee-Object -FilePath $runLog -Append | Out-Null
  } catch {
    throw ("LIVE_FAIL " + $x)
  }
}
"LAW_RUN_OK" | Tee-Object -FilePath $runLog -Append | Out-Null
Tee-Object -FilePath $runLog -Append | Out-Null
"LAW_RUN_OK"

