#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][string]$StepPath,
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try{ if($IsWindows){ chcp 65001 > $null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo = (Resolve-Path -LiteralPath $RepoRoot).Path
Set-Location -LiteralPath $repo

# Require StepPath exists + absolute
if(-not [IO.Path]::IsPathRooted($StepPath)){ throw "FAIL: StepPath must be absolute: $StepPath" }
if(-not (Test-Path -LiteralPath $StepPath)){ throw "FAIL: StepPath not found: $StepPath" }

# Read allowlist from step
$raw = Get-Content -LiteralPath $StepPath -Raw -Encoding UTF8
$m = [regex]::Match($raw, '(?ms)\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\(\s*(.*?)\s*\)')
if(-not $m.Success){ throw "FAIL: step missing `$EGO_STEP_WRITE_ALLOWLIST = @(...)." }
$inner = $m.Groups[1].Value
$items = [regex]::Matches($inner, '(?m)^\s*"(.*?)"\s*,?\s*$') | ForEach-Object { $_.Groups[1].Value }
$allow = @($items) | Where-Object { $_ -and $_.Trim().Length -gt 0 }

if(@($allow).Count -lt 1){ throw "FAIL: allowlist is empty in step." }

# Run step (single point)
pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo "tools\step-run.ps1") -StepPath $StepPath

# Write proof for commit hook
$proofDir = Join-Path $repo "_local\_proof"
New-Item -ItemType Directory -Path $proofDir -Force | Out-Null
$proofPath = Join-Path $proofDir "last_step_run.json"

[pscustomobject]@{
  timestamp = (Get-Date).ToString("o")
  stepPath  = $StepPath
  allowlist = $allow
} | ConvertTo-Json -Depth 6 | Out-File -LiteralPath $proofPath -Encoding utf8

# Verify (show status)
git status --porcelain=v1