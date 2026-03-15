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

$RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if([string]::IsNullOrWhiteSpace($RepoRoot)){ Fail "RepoRoot not found." }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

# Repo must be clean
$dirty = @(git status --porcelain=v1)
if($dirty.Count -gt 0){
  $list = ($dirty -join "`n")
  Fail "REPO_DIRTY: make repo clean before finish-one.`n$list"
}

# Upstream must exist
$u = (git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null)
if([string]::IsNullOrWhiteSpace($u)){
  Fail "NO_UPSTREAM: branch has no upstream. Set it once: git push -u origin HEAD"
}

# Ahead count
$aheadText = (git rev-list --count '@{u}..HEAD' 2>$null).Trim()
if([string]::IsNullOrWhiteSpace($aheadText)){ Fail "AHEAD_COUNT_FAILED" }
[int]$ahead = $aheadText

if($ahead -le 0){
  "OK: nothing to push (ahead=0)"
  exit 0
}

# Ensure closeout is done (script may skip if fresh)
& (Join-Path $PSScriptRoot "closeout-status.ps1")

# Re-check clean before push (closeout should not dirty repo)
$dirty2 = @(git status --porcelain=v1)
if($dirty2.Count -gt 0){
  $list2 = ($dirty2 -join "`n")
  Fail "REPO_DIRTY_AFTER_CLOSEOUT: refusing to push.`n$list2"
}

"OK: pushing (ahead=$ahead)"
git push