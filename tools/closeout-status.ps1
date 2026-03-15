#requires -Version 7.0
param()

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"
$Marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"

$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){ Fail "CLOSEOUT_NO_GIT_LOG (git log -1 failed)" }
$commitTime = [DateTimeOffset]::Parse($commitIso)

if(Test-Path -LiteralPath $Marker -PathType Leaf){
  $raw = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim()
  if(-not [string]::IsNullOrWhiteSpace($raw)){
    try {
      $brainTime = [DateTimeOffset]::Parse($raw)
      if($brainTime -ge $commitTime){
        "SKIP: closeout up-to-date (BrainSync >= last commit)"
        git status --porcelain=v1
        exit 0
      }
    } catch {
      # ignore parse errors -> run closeout
    }
  }
}

& (Join-Path $PSScriptRoot "round-closeout.ps1")
git status --porcelain=v1