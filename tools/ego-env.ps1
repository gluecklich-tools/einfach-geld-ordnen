#requires -Version 7.0
param(
  [switch]$AsJson
)

. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1')

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try{ if($IsWindows){ chcp 65001 > $null } }catch{}
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)

$RepoRoot = $null
try{
  $t = (git rev-parse --show-toplevel 2>$null)
  if($t){ $RepoRoot = (Resolve-Path -LiteralPath $t).Path }
}catch{}
if(-not $RepoRoot){ throw "RepoRoot konnte nicht via git rev-parse ermittelt werden." }

$ProjectRoot = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "..\..")).Path

$BrainDir      = Join-Path $ProjectRoot "Brain_EGO_Dateien"
$InternDir     = Join-Path $ProjectRoot "_INTERN"
$InternGovDir  = Join-Path $InternDir "governance"

$o = [pscustomobject]@{
  RepoRoot        = $RepoRoot
  ProjectRoot     = $ProjectRoot
  BrainDir        = $BrainDir
  InternDir       = $InternDir
  InternGovDir    = $InternGovDir
  BrainGovernance = (Join-Path $BrainDir "GOVERNANCE_INTERNAL.md")
  BrainQa         = (Join-Path $BrainDir "QA_GATE_INTERNAL.md")
  BrainLearnings  = (Join-Path $BrainDir "LEARNINGS_INTERNAL.md")
}

if($AsJson){ $o | ConvertTo-Json -Depth 3 } else { $o }
