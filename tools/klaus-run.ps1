#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)]
  [ValidateSet("default","live-check")]
  [string]$Mode = "default",

  [Parameter(Mandatory=$false)]
  [string]$Message = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $RepoRoot

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
  $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -MaximumRedirection 5
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

# 1) VERIFY (gates)
pwsh -NoProfile -File (Join-Path $PSScriptRoot "ego-run.ps1") | ForEach-Object { $_ }

# 1b) Optional: Live checklist generation + open (audit-only)
if ($Mode -eq "live-check") {
  $lc = Join-Path $PSScriptRoot "live-checklist.ps1"
  if (-not (Test-Path -LiteralPath $lc)) { throw ("Missing tool: " + $lc) }

  # generate checklist with HTTP 200 checks (writes into assets/audit/...)
  pwsh -NoProfile -File $lc -DoHttp200 | ForEach-Object { $_ }

  $open = Join-Path $PSScriptRoot "live-checklist-open.ps1"
  if (Test-Path -LiteralPath $open) {
    pwsh -NoProfile -File $open | ForEach-Object { $_ }
  } else {
    "WARN: tools/live-checklist-open.ps1 not found -> skip opening."
  }
}

# 2) Commit+Push only if real changes exist (ignore audit artefacts)
$cand = @(Get-CommitCandidates)
if ($cand.Length -eq 0) {
  "OK: No commit candidates (audit-only or clean) -> skip commit/push."
} else {
  "OK: Commit candidates:"
  $cand | ForEach-Object { "  " + $_ }

  $msg = Ensure-CleanCommitMessage -Msg $Message
  git add -A | Out-Null
  git commit -m $msg | ForEach-Object { $_ }
  git push | ForEach-Object { $_ }
  "OK: Changes pushed."
}

# 3) Live smoke (full URL)
$u = "https://gluecklich-tools.github.io/einfach-geld-ordnen/"
Live-Smoke200 -Url $u

# 4) Final status
git status --porcelain