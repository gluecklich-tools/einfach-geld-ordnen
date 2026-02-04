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
chcp 65001 | Out-Null
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

Say ("Mode=" + $Mode + "  HttpTimeoutSec=" + $HttpTimeoutSec)

# 1) VERIFY (gates)
Say "STEP 1/4: running ego-run gates..."
pwsh -NoProfile -File (Join-Path $PSScriptRoot "ego-run.ps1") | ForEach-Object { $_ }
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