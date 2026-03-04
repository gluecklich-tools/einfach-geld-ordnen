#requires -Version 7.0
param(
  [string]$RepoRoot = "",
  [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Resolve-RepoRoot([string]$RepoRoot){
  if($RepoRoot -and $RepoRoot.Trim().Length -gt 0){ return (Resolve-Path -LiteralPath $RepoRoot).Path }
  try { return (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path } catch { throw "RepoRoot not found." }
}

function Write-Utf8NoBom([string]$Path,[string]$Text){
  $dir = Split-Path -Parent $Path
  if($dir -and !(Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, ($Text.Replace("`r`n","`n")), $utf8)
}

function Repo-IsClean([string]$repo){
  $s = (git -C $repo status --porcelain=v1)
  return ([string]::IsNullOrWhiteSpace($s))
}

$repo = Resolve-RepoRoot $RepoRoot
if(-not (Repo-IsClean $repo)){ throw "STOP: repo not clean. Commit/restore first." }

$projectRoot = Split-Path -Parent (Split-Path -Parent $repo)
$brainRoot = Join-Path $projectRoot "Brain_EGO_Dateien"

$outDir = if($OutDir -and $OutDir.Trim().Length -gt 0){ $OutDir } else { Join-Path $repo "_local\reports" }
if(!(Test-Path -LiteralPath $outDir)){ New-Item -ItemType Directory -Force -Path $outDir | Out-Null }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss K"

$logPreflight = Join-Path $outDir ("round_preflight_{0}.log" -f $ts)
$logBrain     = Join-Path $outDir ("round_brain_verify_{0}.log" -f $ts)
$todoMd       = Join-Path $outDir ("round_todo_priorized_{0}.md" -f $ts)
$closeMd      = Join-Path $outDir ("round_closeout_{0}.md" -f $ts)

$toolPreflight = Join-Path $repo "tools\enterprise-preflight.ps1"
$toolBrainReq  = Join-Path $repo "tools\brain-sync-required.ps1"
$gateBrainRoot = Join-Path $repo "tools\gate-brain-root-freshness.ps1"
$toolBundle    = Join-Path $repo "tools\ego-bundle-audit.ps1"

# --- 1) Brain required + freshness gate ---
$brainLog = New-Object System.Collections.Generic.List[string]
$brainLog.Add("[$now] brain verify")
$brainLog.Add("RepoRoot: $repo")
$brainLog.Add("BrainRoot: $brainRoot")

if(Test-Path -LiteralPath $toolBrainReq){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $toolBrainReq 2>&1 | ForEach-Object { $brainLog.Add("req: $_") }
} else {
  $brainLog.Add("WARN: missing $toolBrainReq")
}

$last = Join-Path $brainRoot "BRAIN_SYNC_LAST.txt"
if(Test-Path -LiteralPath $last){
  $brainLog.Add("BRAIN_SYNC_LAST:")
  (Get-Content -LiteralPath $last -Encoding UTF8 | Select-Object -First 8) | ForEach-Object { $brainLog.Add("  $_") }
} else {
  $brainLog.Add("WARN: missing $last")
}

if(Test-Path -LiteralPath $gateBrainRoot){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $gateBrainRoot -RepoRoot $repo 2>&1 | ForEach-Object { $brainLog.Add("gate: $_") }
} else {
  $brainLog.Add("WARN: missing $gateBrainRoot")
}

Write-Utf8NoBom $logBrain (($brainLog -join "`n") + "`n")

# --- 2) Enterprise preflight ---
$pre = New-Object System.Collections.Generic.List[string]
$pre.Add("[$now] enterprise-preflight")
$pre.Add("RepoRoot: $repo")
if(Test-Path -LiteralPath $toolPreflight){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $toolPreflight 2>&1 | ForEach-Object { $pre.Add("preflight: $_") }
} else {
  $pre.Add("WARN: missing $toolPreflight")
}
Write-Utf8NoBom $logPreflight (($pre -join "`n") + "`n")

# --- 3) Bundle audit (optional) -> JSON file if tool supports it ---
$bundleNote = "SKIP"
try {
  if(Test-Path -LiteralPath $toolBundle){
    $json = Join-Path $outDir ("round_bundle_audit_{0}.json" -f $ts)
    # attempt json-out; if tool doesn't support, catch
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $toolBundle -RepoRoot $repo -OutJson $json 2>$null | Out-Null
    if(Test-Path -LiteralPath $json){ $bundleNote = "OK: wrote $json" } else { $bundleNote = "WARN: bundle audit json not written" }
  } else {
    $bundleNote = "WARN: missing tools/ego-bundle-audit.ps1"
  }
} catch {
  $bundleNote = "WARN: bundle audit failed: $($_.Exception.Message)"
}

# --- 4) TODO prioritization from Brain TODO.md (if present) ---
$todoPath = Join-Path $brainRoot "TODO.md"
$todoLines = @()
$todoLines += "# TODO Priorisierung (Round Closeout) – $now"
$todoLines += ""
$todoLines += "Source: $todoPath"
$todoLines += ""

if(Test-Path -LiteralPath $todoPath){
  $todo = Get-Content -LiteralPath $todoPath -Raw -Encoding UTF8
  $lines = $todo -split "`n"
  $items = New-Object System.Collections.Generic.List[object]
  $i=0
  foreach($l in $lines){
    $i++
    $t = $l.TrimEnd("`r")
    if($t -match '^\s*[-*]\s+\[.\]\s+.+$' -or $t -match '^\s*[-*]\s+.+$'){
      $items.Add([pscustomobject]@{ LineNo=$i; Text=$t })
    }
  }

  function Score([string]$t){
    $s=50
    if($t -match '(?i)\bP0\b'){ $s+=80 }
    if($t -match '(?i)\bblocker\b'){ $s+=60 }
    if($t -match '(?i)\bgate\b'){ $s+=40 }
    if($t -match '(?i)\bpreflight\b'){ $s+=40 }
    if($t -match '(?i)\bparser\b'){ $s+=40 }
    if($t -match '(?i)\bSSOT\b'){ $s+=25 }
    if($t -match '(?i)\bbrain\b'){ $s+=25 }
    if($t -match '(?i)\bseo\b|\bbing\b|\bgsc\b|\bcontent\b'){ $s-=20 }
    if($t -match '^\s*[-*]\s+\[x\]\s+'){ $s-=999 }
    return $s
  }

  $scored = $items | ForEach-Object {
    [pscustomobject]@{ Score=(Score $_.Text); LineNo=$_.LineNo; Text=$_.Text }
  } | Sort-Object @{Expression='Score';Descending=$true}, @{Expression='LineNo';Descending=$false}

  $todoLines += "## Top-Prios (heuristisch)"
  $todoLines += ""
  foreach($r in ($scored | Select-Object -First 40)){
    $tier = if($r.Score -ge 120){"P0"} elseif($r.Score -ge 90){"P1"} else {"P2"}
    $todoLines += ("- [{0}] (score={1}, line={2}) {3}" -f $tier,$r.Score,$r.LineNo,$r.Text)
  }
} else {
  $todoLines += "WARN: TODO.md missing in BrainRoot"
}

Write-Utf8NoBom $todoMd (($todoLines -join "`n") + "`n")

# --- 5) Closeout report ---
$close = @()
$close += "# Round Closeout – $now"
$close += ""
$close += "RepoRoot: $repo"
$close += "OutDir: $outDir"
$close += ""
$close += "## Belege"
$close += "- Brain verify log: $logBrain"
$close += "- Preflight log: $logPreflight"
$close += "- TODO report: $todoMd"
$close += "- Bundle audit: $bundleNote"
$close += ""
$close += "## Regel"
$close += "- Dieser Report entspricht P0 AUTO_CLOSEOUT_AFTER_COMMIT_PUSH."

Write-Utf8NoBom $closeMd (($close -join "`n") + "`n")

"PASS: round-closeout"
"OK: closeout $closeMd"