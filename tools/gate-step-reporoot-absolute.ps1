#requires -Version 7.0
param(
  [string]$StepPath = ""
)

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

if([string]::IsNullOrWhiteSpace($StepPath)){
  "PASS: GATE_STEP_REPOROOT_ABSOLUTE (no StepPath provided)"
  exit 0
}

$sp = (Resolve-Path -LiteralPath $StepPath).Path
$raw = Get-Content -LiteralPath $sp -Raw -Encoding UTF8

# Hard fail if step contains a hard-coded user home path patterns (basic)
if($raw -match '(?i)C:\\Users\\'){
  Fail ("FAIL: GATE_STEP_REPOROOT_ABSOLUTE Hard-coded user path in step: {0}" -f $sp)
}

# Hard fail if step uses relative IO paths (very basic heuristic)
if($raw -match '(?m)^\s*Get-Content\s+-LiteralPath\s+"\.\\"' -or $raw -match '(?m)^\s*Set-Content\s+-LiteralPath\s+"\.\\"'){
  Fail ("FAIL: GATE_STEP_REPOROOT_ABSOLUTE Relative IO path in step: {0}" -f $sp)
}

"PASS: GATE_STEP_REPOROOT_ABSOLUTE"
