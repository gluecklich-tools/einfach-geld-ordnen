param(
  [ValidateSet('Plan','Apply')]
  [string] $Mode = 'Apply',
  [string] $PublicRepo = '',
  [switch] $AutoCommit,
  [string] $CommitMessage = 'EGO: super-run apply + gates',
  [string] $LiveUrl = 'https://gluecklich-tools.github.io/einfach-geld-ordnen/',
  [switch] $SkipLiveHead
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# EGO_HOOK_INTERNAL_REFRESH_V1
$env:EGO_INTERNAL_REFRESH | Out-Null
$InternalRefresh = $env:EGO_INTERNAL_REFRESH
if (-not [string]::IsNullOrWhiteSpace($InternalRefresh) -and (Test-Path -LiteralPath $InternalRefresh)) {
  try {
    "INTERNAL_REFRESH: start"
    & pwsh -NoProfile -File $InternalRefresh
    "INTERNAL_REFRESH: ok"
  } catch {
    "INTERNAL_REFRESH: fail"
    throw
  }
} else {
  "INTERNAL_REFRESH: skip (env not set)"
}

try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
if ($PSVersionTable.PSVersion.Major -lt 7) { throw "NOT IN PWSH 7+. Current: $($PSVersionTable.PSVersion)" }
$repo = (Get-Location).Path
if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) { throw "Run from repo root (where .git exists). Current: $repo" }
if ([string]::IsNullOrWhiteSpace($PublicRepo)) { $PublicRepo = $repo }
function Say([string]$m) { Write-Host $m }
Say ("PWsh OK: " + $PSVersionTable.PSVersion + " | exe: " + (Get-Command pwsh).Source)
Say ("Repo: " + $repo)
Say ("Mode: " + $Mode)
Say ("PublicRepo: " + $PublicRepo)
$tools = Join-Path $repo 'tools'
if (-not (Test-Path -LiteralPath $tools)) { throw "tools folder missing: $tools" }
$lawSafe = Join-Path $tools 'ego-law-run-safe.ps1'
if (-not (Test-Path -LiteralPath $lawSafe)) { throw "missing: $lawSafe" }
$gFlow = Join-Path $tools 'ego-flow-gates.ps1'
$gMvp  = Join-Path $tools 'mvp02-gate.ps1'
$gMurx = Join-Path $tools 'no-murx-gate.ps1'
$gLegalMin = Join-Path $tools 'legal-minimum-warn.ps1'
$gLegal = Join-Path $tools 'legal-hints-gate.ps1'
# ---- APPLY (optional) ----
if ($Mode -eq 'Apply') {
  Say "APPLY: ego-law-run-safe.ps1"
  & $lawSafe -PublicRepo $PublicRepo
} else {
  Say "PLAN: skipped apply (Mode=Plan)"
}
# ---- GATES ----
if (Test-Path -LiteralPath $gFlow) { Say "GATE: ego-flow-gates"; & $gFlow }
if (Test-Path -LiteralPath $gMvp)  { Say "GATE: mvp02-gate"; & $gMvp }
if (Test-Path -LiteralPath $gMurx) { Say "GATE: no-murx-gate"; & $gMurx }
if (Test-Path -LiteralPath $gLegalMin) { Say WARN: legal-minimum; & $gLegalMin }
if (Test-Path -LiteralPath $gLegal) { Say "GATE: legal-hints"; & $gLegal }
# ---- COMMIT/PUSH (optional) ----
$porc = (git status --porcelain)
if ($porc) {
  Say "GIT: working tree has changes."
  if ($AutoCommit) {
    Say "GIT: staging..."
    git add -A
    $staged = (git diff --cached --name-only)
    if (-not $staged) { throw "AutoCommit requested but nothing staged. STOP." }
    Say ("GIT: commit -> " + $CommitMessage)
    git commit -m $CommitMessage
    Say "GIT: push"
    git push
  } else {
    Say "GIT: AutoCommit not set -> leaving changes uncommitted."
    git status
  }
} else {
  Say "GIT: clean."
}
# ---- LIVE HEAD 200 ----
if (-not $SkipLiveHead) {
  Say ("LIVE HEAD: " + $LiveUrl)
  $r = Invoke-WebRequest -Uri $LiveUrl -Method Head -MaximumRedirection 5
  Say ("LIVE HEAD: " + $r.StatusCode + " " + $LiveUrl)
} else {
  Say "LIVE HEAD: skipped."
}
Say "DONE."
