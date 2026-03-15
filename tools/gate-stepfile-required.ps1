param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$StepPath = ""
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001|Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

if([string]::IsNullOrWhiteSpace($StepPath)){
  Fail "STOP: STEPFILE_REQUIRED. enterprise-run must be called with -StepPath <file>."
}

if(!(Test-Path -LiteralPath $StepPath)){
  Fail "STOP: STEPFILE_REQUIRED. StepPath file does not exist: $StepPath"
}

$norm = ($StepPath -replace '\\','/').ToLowerInvariant()
if($norm -notmatch '/_local/_scratch/step_.*\.ps1$'){
  Fail "STOP: STEPFILE_REQUIRED. Step must be in _local/_scratch and named step_*.ps1 (got: $StepPath)"
}

"PASS: STEPFILE_REQUIRED"
return
