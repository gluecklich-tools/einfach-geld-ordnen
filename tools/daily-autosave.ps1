param(
  [string]$RepoRoot = "",
  [string]$SsotRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Resolve-RepoRoot([string]$hint){
  if(-not [string]::IsNullOrWhiteSpace($hint) -and (Test-Path -LiteralPath $hint)){
    return (Resolve-Path -LiteralPath $hint).Path
  }
  $cur = (Get-Location).Path
  for($i=0;$i -lt 20;$i++){
    if(Test-Path -LiteralPath (Join-Path $cur ".git")){ return $cur }
    if(Test-Path -LiteralPath (Join-Path $cur "_config.yml")){ return $cur }
    $p = Split-Path -Parent $cur
    if([string]::IsNullOrWhiteSpace($p) -or $p -eq $cur){ break }
    $cur = $p
  }
  throw "STOP: repo root not found."
}

function Pick-Runner([string]$root){
  $candidates = @(
    (Join-Path $root "tools\klaus-run.ps1"),
    (Join-Path $root "tools\ego-law-run.ps1"),
    (Join-Path $root "tools\ego-run.ps1")
  )
  foreach($c in $candidates){
    if(Test-Path -LiteralPath $c){ return $c }
  }
  return ""
}

$repo = Resolve-RepoRoot $RepoRoot
Set-Location -LiteralPath $repo

$today = (Get-Date).ToString("yyyy-MM-dd")
$ts = "{0}_{1}" -f @((Get-Date).ToString("yyyyMMdd_HHmmss_fff"), (Get-Random -Minimum 1000 -Maximum 9999))
$dailyDir = Join-Path $repo "_local\daily"
$runDir   = Join-Path $dailyDir ("run_{0}_{1}" -f @($today, $ts))
New-Item -ItemType Directory -Path $runDir -Force | Out-Null

$logPath     = Join-Path $runDir "transcript.txt"
$reportPath  = Join-Path $runDir "daily_report.md"
$zipPath     = Join-Path $runDir ("repo_archive_{0}_{1}.zip" -f @($today, $ts))

Start-Transcript -LiteralPath $logPath | Out-Null

"=== DAILY AUTOSAVE SNAPSHOT ==="
("DATE={0}  TS={1}" -f @($today, $ts))
("REPO={0}" -f $repo)

# -------- SCAN --------
"--- SCAN: git status / diff / head ---"
$git = Get-Command git -ErrorAction SilentlyContinue
if(-not $git){ throw "STOP: git not found in PATH." }

$head = (git rev-parse --short HEAD 2>$null).Trim()
if([string]::IsNullOrWhiteSpace($head)){ $head = "UNKNOWN" }
("HEAD={0}" -f $head)

$st = (git status --porcelain 2>$null)
$dirty = -not [string]::IsNullOrWhiteSpace($st)
("DIRTY={0}" -f $dirty)
if($dirty){
  "GIT_STATUS_PORCELAIN:"
  $st
}

# -------- VERIFY/REPORT via runner --------
$runner = Pick-Runner $repo
$runnerShown = "<none>"
if(-not [string]::IsNullOrWhiteSpace($runner)){ $runnerShown = $runner }
("RUNNER={0}" -f $runnerShown)

$runnerExit = 0
if($runnerShown -ne "<none>"){
  "--- VERIFY/REPORT via runner (default call) ---"
  & pwsh -NoProfile -File $runner
  $runnerExit = $LASTEXITCODE
  ("RUNNER_EXITCODE={0}" -f $runnerExit)
} else {
  "WARN: no runner found (tools\\klaus-run.ps1 / tools\\ego-law-run.ps1 / tools\\ego-run.ps1). Skipping tool gates."
}

# -------- OPTIONAL: Git archive snapshot (only if clean) --------
"--- SNAPSHOT: git archive (only if clean) ---"
$st2 = (git status --porcelain 2>$null)
$clean = [string]::IsNullOrWhiteSpace($st2)
("CLEAN={0}" -f $clean)
if($clean){
  try{
    if(Test-Path -LiteralPath $zipPath){ Remove-Item -LiteralPath $zipPath -Force }
    git archive --format=zip --output $zipPath HEAD 2>$null | Out-Null
    ("ARCHIVE_OK={0}" -f (Test-Path -LiteralPath $zipPath))
  } catch {
    ("WARN: git archive failed: {0}" -f $_.Exception.Message)
  }
} else {
  "SKIP: repo not clean -> no git archive created."
}

# -------- OPTIONAL: SSOT daily log --------
if([string]::IsNullOrWhiteSpace($SsotRoot)){ $SsotRoot = $env:EGO_SSOT_ROOT }
$ssotOk = $false
if(-not [string]::IsNullOrWhiteSpace($SsotRoot) -and (Test-Path -LiteralPath $SsotRoot)){ $ssotOk = $true }

$ssotShown = "<missing/not set>"
if($ssotOk){ $ssotShown = (Resolve-Path -LiteralPath $SsotRoot).Path }
("SSOT_ROOT={0}" -f $ssotShown)

$ssotDailyPath = ""
if($ssotOk){
  $ssotDailyDir = Join-Path $SsotRoot "_daily"
  New-Item -ItemType Directory -Path $ssotDailyDir -Force | Out-Null
  $ssotDailyPath = Join-Path $ssotDailyDir ("daily_{0}.md" -f $today)
}

# -------- REPORT --------
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Daily Autosave Snapshot')
$lines.Add('')
$lines.Add(('* Date: **{0}** (Europe/Berlin)' -f $today))
$lines.Add(('* Timestamp: **{0}**' -f $ts))
$lines.Add(('* Repo: `{0}`' -f $repo))
$lines.Add(('* HEAD: `{0}`' -f $head))
$lines.Add(('* Dirty: `{0}`' -f $dirty))
$lines.Add(('* Runner: `{0}`' -f $runnerShown))
$lines.Add(('* RunnerExit: `{0}`' -f $runnerExit))
$lines.Add(('* Transcript: `{0}`' -f $logPath))
$lines.Add(('* Report: `{0}`' -f $reportPath))
$archiveShown = '<none>'
if(Test-Path -LiteralPath $zipPath){ $archiveShown = $zipPath }
$lines.Add(('* ArchiveZip: `{0}`' -f $archiveShown))
$lines.Add(('* SSOT Root: `{0}`' -f $ssotShown))
$ssotDailyShown = '<skip>'
if($ssotOk){ $ssotDailyShown = $ssotDailyPath }
$lines.Add(('* SSOT DailyLog: `{0}`' -f $ssotDailyShown))
$lines.Add('')
$lines.Add('## Notes')
if($dirty){ $lines.Add('- Repo war **nicht clean**. Kein git-archive erstellt.') } else { $lines.Add('- Repo war **clean**. git-archive erstellt (falls nicht fehlgeschlagen).') }
if($runnerExit -ne 0){ $lines.Add('- Runner meldete **ExitCode != 0**. Gates/Checks bitte in `transcript.txt` pruefen.') }
elseif($runnerShown -ne "<none>"){ $lines.Add('- Runner lief **ExitCode 0**.') }
else { $lines.Add('- Kein Runner gefunden -> Tool-Gates wurden uebersprungen.') }
if(-not $ssotOk){ $lines.Add('- SSOT-Log **uebersprungen**, da `EGO_SSOT_ROOT` nicht gesetzt/auffindbar war.') }

[IO.File]::WriteAllText($reportPath, ($lines -join "`n") + "`n", [System.Text.UTF8Encoding]::new($false))

if($ssotOk){
  $append = @()
  $append += ""
  $append += ("## {0} {1}" -f $today, $ts)
  $append += ("- Repo HEAD: {0}" -f $head)
  $append += ("- Dirty: {0}" -f $dirty)
  $append += ("- RunnerExit: {0}" -f $runnerExit)
  $append += ("- RunDir: {0}" -f $runDir)
  $append += ("- Report: {0}" -f $reportPath)
  if(Test-Path -LiteralPath $ssotDailyPath){
    Add-Content -LiteralPath $ssotDailyPath -Value ($append -join "`n") -Encoding UTF8
  } else {
    [IO.File]::WriteAllText($ssotDailyPath, ("# SSOT Daily Log`n" + ($append -join "`n") + "`n"), [System.Text.UTF8Encoding]::new($false))
  }
}

Stop-Transcript | Out-Null

"=== DONE ==="
("RunDir: {0}" -f $runDir)
("DailyReport: {0}" -f $reportPath)
if(Test-Path -LiteralPath $zipPath){ ("ArchiveZip: {0}" -f $zipPath) }
if($ssotOk){ ("SSOT_Daily: {0}" -f $ssotDailyPath) }

if($runnerExit -ne 0){ exit 2 } else { exit 0 }

