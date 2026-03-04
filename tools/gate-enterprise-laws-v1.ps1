#requires -Version 7.0
param(
  [string]$RepoRoot = "",
  [string]$StepPath = ""
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ConfirmPreference='None'
$ProgressPreference='SilentlyContinue'

function Fail([string]$m){ throw $m }

# EGO_P0_REPOROOT_DERIVE (non-interactive)
if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
} else {
  $RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
}

function RunGate([string]$rel,[string]$args=""){
  $p = Join-Path $RepoRoot $rel
  if(!(Test-Path -LiteralPath $p -PathType Leaf)){ Fail "FAIL: Missing gate: $rel" }
  if([string]::IsNullOrWhiteSpace($args)){
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $p
  } else {
    # args string is already fully formatted (e.g. -StepPath "...")
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $p @($args -split ' ')
  }
}

# P0: aggregator for core enterprise hardrails.
# - no prompting
# - step-scoped where supported

# These two are tool-scope (or tool+StepPath where supported)
$argStep = ""
if(-not [string]::IsNullOrWhiteSpace($StepPath)){
  $sp = (Resolve-Path -LiteralPath $StepPath).Path
  $argStep = ('-StepPath "{0}"' -f $sp)
}

# New/known failure gates
if(Test-Path -LiteralPath (Join-Path $RepoRoot "tools\gate-no-dollar0-regex-replace.ps1")){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\gate-no-dollar0-regex-replace.ps1") -StepPath $StepPath
}
if(Test-Path -LiteralPath (Join-Path $RepoRoot "tools\gate-no-placeholder-regex-in-gates.ps1")){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\gate-no-placeholder-regex-in-gates.ps1")
}

# Step-scope gates (only meaningful when StepPath provided)
if(Test-Path -LiteralPath (Join-Path $RepoRoot "tools\gate-step-joinpath-arraysafe.ps1")){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\gate-step-joinpath-arraysafe.ps1") -StepPath $StepPath
}
if(Test-Path -LiteralPath (Join-Path $RepoRoot "tools\gate-step-reporoot-absolute.ps1")){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\gate-step-reporoot-absolute.ps1") -StepPath $StepPath
}

# File-first policy gate (tool scope)
if(Test-Path -LiteralPath (Join-Path $RepoRoot "tools\gate-file-first-step-only.ps1")){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\gate-file-first-step-only.ps1") -RepoRoot $RepoRoot
}

"PASS: gate-enterprise-laws-v1"