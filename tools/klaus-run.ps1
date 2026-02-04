#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)]
  [string]$Message = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# Repo root = parent of /tools
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

# 1) VERIFY (gates)
pwsh -NoProfile -File (Join-Path $PSScriptRoot "ego-run.ps1") | ForEach-Object { $_ }

# 2) Commit+Push only if changes exist
$porc = git status --porcelain
if ([string]::IsNullOrWhiteSpace($porc)) {
  "OK: No changes -> skip commit/push."
} else {
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