#requires -Version 7.0
param(
  [string]$RepoRoot,
  [switch]$ForCommit
)



# EGO_P0_REPOROOT_DERIVE
if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
} else {
  $RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
}

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try{ if($IsWindows){ chcp 65001 > $null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw "FAIL: FILE_FIRST_STEP_ONLY: $m" }

$repo = (Resolve-Path -LiteralPath $RepoRoot).Path
Set-Location -LiteralPath $repo

# Staged files (commit scope)
$staged = @(git diff --cached --name-only)
if(@($staged).Count -eq 0){
  "PASS: FILE_FIRST_STEP_ONLY (no staged files)"
  exit 0
}

# Proof file written by wrapper after a step run
$proof = Join-Path $repo "_local\_proof\last_step_run.json"
if(-not (Test-Path -LiteralPath $proof)){
  Fail "commit blocked: missing step proof _local/_proof/last_step_run.json. Run steps via tools/ego-step.ps1."
}

$json = Get-Content -LiteralPath $proof -Raw -Encoding UTF8 | ConvertFrom-Json
$allow = @($json.allowlist) | ForEach-Object { ($_ -replace '\\','/').TrimStart('./') }

if(@($allow).Count -lt 1){
  Fail "commit blocked: allowlist in proof is empty."
}

$bad = @()
foreach($f in $staged){
  $p = ($f -replace '\\','/').TrimStart('./')
  if($allow -notcontains $p){ $bad += $p }
}

if(@($bad).Count -gt 0){
  Fail ("commit blocked: staged files not in last step allowlist: " + ($bad -join ", "))
}

"PASS: FILE_FIRST_STEP_ONLY (staged ⊆ allowlist)"