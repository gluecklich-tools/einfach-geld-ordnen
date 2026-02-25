#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)]
  [ValidateSet("default","live-check")]
  [string]$Mode = "default",

  [Parameter(Mandatory=$false)]
  [string]$Message = "",

  [Parameter(Mandatory=$false)]
  [int]$HttpTimeoutSec = 20
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
# EGO_NO_BIG_PASTE_RUNNER_V1
# EGO_GATE_NO_BIG_PASTE_CALL_V1
# EGO_SSOT_REFRESH_PROXY_CALL_V1
# EGO_GATE_SSOT_PROXY_CALL_V1
$RepoRoot = Split-Path -Parent $PSScriptRoot
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-ssot-proxy.ps1') -RepoRoot $RepoRoot | Out-Null
# Optional: run SSOT refresh via repo proxy if env:EGO_SSOT_ROOT is set (no hardpaths in repo)
if (-not [string]::IsNullOrWhiteSpace($env:EGO_SSOT_ROOT)) {
  $proxy = Join-Path $PSScriptRoot 'ssot-refresh-proxy.ps1'
  if (-not (Test-Path -LiteralPath $proxy)) { throw ("Missing SSOT proxy tool: " + $proxy) }
  pwsh -NoProfile -File $proxy | Out-Null
}
$RepoRoot = Split-Path -Parent $PSScriptRoot
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-no-big-paste.ps1') -RepoRoot $RepoRoot | Out-Null
# LAW: Never paste large scripts into the console. Use file-based tools + pwsh -NoProfile -File.
# If you see truncated input / ParserError: STOP and rerun from a fresh session.
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if ($IsWindows) { try { chcp 65001 | Out-Null } catch {} }
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $RepoRoot

function Say([string]$s) { Write-Host ("[KLAUS] " + $s) }

function Ensure-CleanCommitMessage {
  param([string]$Msg)
  $m = ($Msg ?? "").Trim()
  if ([string]::IsNullOrWhiteSpace($m)) {
    return ("Klaus-Run: automated gates + push " + (Get-Date).ToString("yyyy-MM-dd HH:mm"))
  }
  return $m
}

function Live-Smoke200 {
  param([string]$Url)
  $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -MaximumRedirection 5 -TimeoutSec $HttpTimeoutSec
  if ($r.StatusCode -ne 200) { throw ("FAIL: Live smoke expected 200, got " + $r.StatusCode) }
  "PASS: Live 200 " + $Url
}

function Get-CommitCandidates {
  $lines = @(git status --porcelain)
  if ($lines.Length -eq 0) { return @() }

  $filtered = @()
  foreach ($ln in $lines) {
    if ([string]::IsNullOrWhiteSpace($ln) -or $ln.Length -lt 4) { continue }
    $p = $ln.Substring(3)
    if ($p -match '^(assets/audit/|assets\\audit\\)') { continue }
    $filtered += $ln
  }
  return @($filtered)
}

function Run-AutoSitemap {
  # If tools/gen-sitemap.ps1 exists, regenerate sitemap.xml + robots.txt (UTF-8 no BOM) deterministically.
  $gen = Join-Path $PSScriptRoot 'gen-sitemap.ps1'
  if (-not (Test-Path -LiteralPath $gen)) {
    Say 'INFO: tools/gen-sitemap.ps1 not found -> skip auto-sitemap.'
# === EGO_AUTO_FINDINGS_UPSERT_HOOK_V1 BEGIN ===
# AUTO: Findings -> SSOT Docs (mandatory)
$ssot=$env:EGO_SSOT_ROOT
if([string]::IsNullOrWhiteSpace($ssot)){
  $ssot=$env:EGO_SSOT_ROOT
}
if([string]::IsNullOrWhiteSpace($ssot)){
  throw "STOP: EGO_SSOT_ROOT not set. Set env var to SSOT root (example: <PROJECT>/_INTERN/governance)."
}
if(!(Test-Path -LiteralPath $ssot)){
  throw ("STOP: SSOT root missing: " + $ssot)
}
$internRoot = Split-Path -Parent $ssot
$tool = Join-Path -Path (Join-Path -Path $internRoot -ChildPath 'tools') -ChildPath 'ego-findings-upsert.ps1'
if(!(Test-Path -LiteralPath $tool)){ throw "STOP: findings tool missing: $tool" }
& pwsh -NoProfile -ExecutionPolicy Bypass -File $tool -SsotRoot $ssot

# Marker-Gate
$marker='<!-- EGO_FINDINGS_FLOWPLAN_TSV_V1 BEGIN -->'
$learn = Join-Path -Path $ssot -ChildPath 'LEARNINGS_INTERNAL.md'
if(!(Select-String -LiteralPath $learn -SimpleMatch -Pattern $marker -Quiet)){
  throw "STOP: findings marker missing in LEARNINGS_INTERNAL.md after upsert"
}
# === EGO_AUTO_FINDINGS_UPSERT_HOOK_V1 END ===

return
  }

  $enc = [System.Text.UTF8Encoding]::new($false)
  $site = 'https://gluecklich-tools.github.io/einfach-geld-ordnen'
  $pMap = Join-Path $RepoRoot 'sitemap.xml'
  $pRob = Join-Path $RepoRoot 'robots.txt'
$ts = "{0}_{1}" -f (Get-Date).ToString("yyyyMMdd_HHmmss_fff"), (Get-Random -Minimum 1000 -Maximum 9999)
  $bk = Join-Path $RepoRoot ("_local\patch_backups\klaus_autositemap_run_" + $ts)
  New-Item -ItemType Directory -Path $bk -Force | Out-Null
  if (Test-Path -LiteralPath $pMap) { Copy-Item -LiteralPath $pMap -Destination (Join-Path $bk 'sitemap.xml') -Force }
  if (Test-Path -LiteralPath $pRob) { Copy-Item -LiteralPath $pRob -Destination (Join-Path $bk 'robots.txt') -Force }

  Say 'Auto-Sitemap: generating sitemap.xml + robots.txt...'
  $xml = & pwsh -NoProfile -File $gen -Repo $RepoRoot -SiteBase $site
  if ([string]::IsNullOrWhiteSpace($xml) -or $xml.Length -lt 200) { throw 'STOP: auto-sitemap generated output too small'
}

    # Guard: sitemap must be valid XML and contain at least 1 url entry
  try {
    [xml]$sx = $xml
  } catch {
    throw 'STOP: auto-sitemap XML parse failed'
  }
  $urlCount = @($sx.urlset.url).Count
  if ($urlCount -lt 1) { throw 'STOP: auto-sitemap has zero <url> entries' }
$robots = "User-agent: *`r`nAllow: /`r`n`r`nSitemap: $site/sitemap.xml`r`n"
  if ($robots.Length -lt 30) { throw 'STOP: robots output too small' }

  [IO.File]::WriteAllText($pMap, $xml, $enc)
  [IO.File]::WriteAllText($pRob, $robots, $enc)

  Say ('Auto-Sitemap: updated. Backup=' + $bk)
}

Say ("Mode=" + $Mode + "  HttpTimeoutSec=" + $HttpTimeoutSec)

# 0) Auto-sitemap (before gates+commit so it is always current)
Run-AutoSitemap

# 1) VERIFY (gates)
Say "# EGO_PROOF_REQUIRED_GATE_V1
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-proof-required.ps1') -RepoRoot (Split-Path -Parent $PSScriptRoot)
STEP 1/4: running ego-run gates..."
# --- EGO_HARD_STOP_ON_GATE_FAIL_V1 ---
# Run gates, preserve output, but hard-stop on non-zero exitcode
$global:LASTEXITCODE = 0
$gateTool = (Join-Path $PSScriptRoot "ego-run.ps1")
$gateOut = & pwsh -NoProfile -File $gateTool 2>&1
$gateEc = $LASTEXITCODE
$gateOut | ForEach-Object { $_ }
if ($gateEc -ne 0) { throw ("STOP: ego-run gates failed (exitcode=" + $gateEc + ")") }
# --- EGO_HARD_STOP_ON_GATE_FAIL_V1 ---
Say "STEP 1/4: gates OK."

# 2) Optional: Live checklist + explainer + open (audit-only)
if ($Mode -eq "live-check") {
  Say "STEP 2/4: generating live checklist + explainer..."
  $lc = Join-Path $PSScriptRoot "live-checklist.ps1"
  if (-not (Test-Path -LiteralPath $lc)) { throw ("Missing tool: " + $lc) }

  $ex = Join-Path $PSScriptRoot "live-checklist-explainer.ps1"
  if (-not (Test-Path -LiteralPath $ex)) { throw ("Missing tool: " + $ex) }

  pwsh -NoProfile -File $lc -DoHttp200 -HttpTimeoutSec $HttpTimeoutSec | ForEach-Object { $_ }
  pwsh -NoProfile -File $ex | ForEach-Object { $_ }
  Say "STEP 2/4: generated."

  $open = Join-Path $PSScriptRoot "live-checklist-open.ps1"
  if (Test-Path -LiteralPath $open) {
    Say "STEP 2b/4: opening newest checklist + explainer..."
    pwsh -NoProfile -File $open | ForEach-Object { $_ }
  } else {
    Say "WARN: tools/live-checklist-open.ps1 not found -> skip opening."
  }
}

# 3) Commit+Push only if real changes exist (ignore audit artefacts)
Say "STEP 3/4: checking git status for real changes..."
$cand = @(Get-CommitCandidates)
if ($cand.Length -eq 0) {
  Say "OK: No commit candidates (audit-only or clean) -> skip commit/push."
} else {
  Say "OK: Commit candidates:"
  $cand | ForEach-Object { Say ("  " + $_) }

  $msg = Ensure-CleanCommitMessage -Msg $Message
  git add -A | Out-Null
  git commit -m $msg | ForEach-Object { $_ }
  git push | ForEach-Object { $_ }
  Say "OK: Changes pushed."
}

# 4) Live smoke (full URL)
Say "STEP 4/4: live smoke 200..."
$u = "https://gluecklich-tools.github.io/einfach-geld-ordnen/"
Live-Smoke200 -Url $u

Say "DONE."
git status --porcelain