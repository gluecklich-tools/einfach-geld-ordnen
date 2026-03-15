# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# EGO_LAWRUN_ENTRY_GUARD_V1
if ($env:EGO_LAWRUN_ALLOWED -ne '1') {
  Write-Host 'ABORT: do not run ego-law-run.ps1 directly. Use ego-super-run.ps1 (recommended) or ego-law-run-safe.ps1.'
  exit 2
}

function Convert-EgoFile-ToLFNoBOM {
  param([Parameter(Mandatory)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
  $raw = [System.IO.File]::ReadAllText($Path)
  $norm = $raw -replace "`r`n","`n" -replace "`r","`n"
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $norm, $enc)
}

function Invoke-GitPushSafe {
  param(
    [Parameter(Mandatory)][string]$Remote,
    [Parameter(Mandatory)][string]$Branch
  )
  & git push $Remote $Branch
  if ($LASTEXITCODE -ne 0) { throw "git push failed (exit $LASTEXITCODE)" }
}

function Run-Logged {
  param([Parameter(Mandatory)][scriptblock]$Script)
  & $Script *>&1 | Tee-Object -FilePath $runLog -Append | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "LAW_RUN_STEP_FAILED (exit $LASTEXITCODE)"
  }
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
Set-Location -LiteralPath $root

if (-not (Test-Path -LiteralPath '.\tools\ego-run.ps1')) { throw 'Missing: tools\ego-run.ps1' }

# Runlog (evidence)
$runDir = Join-Path $root 'assets\audit\runs'
New-Item -ItemType Directory -Path $runDir -Force | Out-Null
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$runLog = Join-Path $runDir ("law_run_{0}.log" -f $ts)

# 0) Pre-gate
if (Test-Path -LiteralPath '.\tools\no-murx-gate.ps1') { Run-Logged { & .\tools\no-murx-gate.ps1 } }

# 1) APPLY (idempotent only, git-tracked-only)
$apply = New-Object System.Collections.Generic.List[string]
$trackedApply = @(
  git -C $root ls-files -- 'tools/apply-*.ps1'
)

foreach($rel in $trackedApply){
  if([string]::IsNullOrWhiteSpace($rel)){ continue }
  $full = Join-Path $root $rel
  if(-not (Test-Path -LiteralPath $full -PathType Leaf)){ continue }
  $apply.Add((Resolve-Path -LiteralPath $full).Path) | Out-Null
}

$apply = @($apply | Sort-Object -Unique)
foreach ($a in $apply) {
  Run-Logged { & $a }
}

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

$commitDone = $false
$dirtyAfter = $false

try {
  # normalize audit.md BEFORE any git add/commit to avoid CRLF warning
  $__repo  = Split-Path -Parent $PSScriptRoot
  $__audit = Join-Path $__repo 'seiten\audit.md'
  Convert-EgoFile-ToLFNoBOM -Path $__audit

  git add -A
  $d = (Get-Date).ToString('yyyy-MM-dd')
  git commit -m ("LawRun: apply + gates " + $d)
  if ($LASTEXITCODE -eq 0) {
    Invoke-GitPushSafe -Remote 'origin' -Branch 'main'
    $commitDone = $true
  }

  $dirtyAfter = ((@(git status --porcelain=v1)).Count -gt 0)
}
finally {
  ("COMMIT_DONE=" + $commitDone.ToString().ToUpperInvariant()) | Tee-Object -FilePath $runLog -Append | Out-Null
  ("REPO_DIRTY_AFTER=" + $dirtyAfter.ToString().ToUpperInvariant()) | Tee-Object -FilePath $runLog -Append | Out-Null
}

if ($dirtyAfter) { throw 'LAW_RUN_FAIL: repo still dirty after run' }

# 4) LIVE HEAD 200 smoke (always)
$u = @(
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/index.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/downloads.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/rechner-uebersicht.html',
  'https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/audit.html'
)

foreach ($x in $u) {
  try {
    $r = Invoke-WebRequest -Uri $x -UseBasicParsing -Method Head
    if ($r.StatusCode -ne 200) { throw "HEAD not 200: $x => $($r.StatusCode)" }
  }
  catch {
    throw ("LAW_RUN_LIVE_FAIL: " + $x + " :: " + $_.Exception.Message)
  }
}

"LAW_RUN_OK" | Tee-Object -FilePath $runLog -Append | Out-Null
Tee-Object -FilePath $runLog -Append | Out-Null
"LAW_RUN_OK"