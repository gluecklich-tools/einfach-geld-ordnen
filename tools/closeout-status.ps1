#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { chcp 65001 > $null } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

# RepoRoot
$RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if([string]::IsNullOrWhiteSpace($RepoRoot)){ Fail "RepoRoot not found." }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

# Get env (BrainDir) via ego-env.ps1
$envJson = & pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools/ego-env.ps1") -AsJson
$envObj = $envJson | ConvertFrom-Json
$BrainDir = $envObj.BrainDir
if([string]::IsNullOrWhiteSpace($BrainDir)){ Fail "BrainDir missing from ego-env." }

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"

# Last commit time (HEAD)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){ Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)" }
$commitTime = [DateTimeOffset]::Parse($commitIso)

# If marker missing -> closeout once (it creates it)
if(!(Test-Path -LiteralPath $marker)){
  Write-Host "INFO: closeout-status: marker missing -> running round-closeout"
  & (Join-Path $RepoRoot "tools/round-closeout.ps1")
  git status --porcelain=v1
  return
}

$brainRaw = (Get-Content -LiteralPath $marker -Raw -Encoding UTF8).Trim()
if([string]::IsNullOrWhiteSpace($brainRaw)){
  Write-Host "INFO: closeout-status: marker empty -> running round-closeout"
  & (Join-Path $RepoRoot "tools/round-closeout.ps1")
  git status --porcelain=v1
  return
}

$brainTime = [DateTimeOffset]::Parse($brainRaw)

if($brainTime -ge $commitTime){
  Write-Host ("OK: closeout-status: skip (BrainSync={0} >= Commit={1})" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
  git status --porcelain=v1
  return
}

Write-Host ("INFO: closeout-status: run (BrainSync={0} < Commit={1})" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
& (Join-Path $RepoRoot "tools/round-closeout.ps1")
git status --porcelain=v1