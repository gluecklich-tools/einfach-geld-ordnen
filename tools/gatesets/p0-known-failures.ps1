#requires -Version 7.0
param([string]$StepPath)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# P0 Gateset: Known failures hardening pack
$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path

function RunGate([string]$rel){
  $p = Join-Path $RepoRoot $rel
  if(!(Test-Path -LiteralPath $p -PathType Leaf)){ throw "FAIL: Missing gate: $rel" }
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $p
}

RunGate "tools/gate-no-dollar0-regex-replace.ps1"
RunGate "tools/gate-no-placeholder-regex-in-gates.ps1"

# Existing hardrails if present (soft-optional: only run when file exists)
$optional = @(
  "tools/gate-step-joinpath-arraysafe.ps1",
  "tools/gate-step-reporoot-absolute.ps1",
  "tools/gate-file-first-step-only.ps1",
  "tools/gate-enterprise-laws-v1.ps1"
)
foreach($rel in $optional){
  $p = Join-Path $RepoRoot $rel
  if(Test-Path -LiteralPath $p -PathType Leaf){
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $p
  }
}

"PASS: gateset p0-known-failures"