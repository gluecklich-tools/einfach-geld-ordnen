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

# V2 is an alias/wrapper that must never prompt and must always parse.
# It delegates to v1 (which is the aggregator).
$v1 = Join-Path $RepoRoot "tools\gate-enterprise-laws-v1.ps1"
if(!(Test-Path -LiteralPath $v1 -PathType Leaf)){
  Fail "FAIL: Missing gate-enterprise-laws-v1.ps1"
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $v1 -RepoRoot $RepoRoot -StepPath $StepPath

"PASS: gate-enterprise-laws-v2"