#requires -Version 7.0
param(
  [string]$StepPath = ""
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path

if([string]::IsNullOrWhiteSpace($StepPath)){
  "PASS: JOINPATH_ARGCOUNT (no StepPath provided)"
  exit 0
}

$sp = (Resolve-Path -LiteralPath $StepPath).Path
$raw = Get-Content -LiteralPath $sp -Raw -Encoding UTF8

# Parse step (if parser fails, we fail with clear message)
$t=$null; $e=$null
$ast=[System.Management.Automation.Language.Parser]::ParseInput($raw,[ref]$t,[ref]$e)
if($e -and $e.Count -gt 0){
  $x=$e[0]
  Fail ("FAIL: JOINPATH_ARGCOUNT PARSER_FAIL {0} (line {1}, col {2}): {3}" -f $sp,$x.Extent.StartLineNumber,$x.Extent.StartColumnNumber,$x.Message)
}

# Heuristic: detect Join-Path with comma-separated args inside array literals (classic)
# (We keep it simple: search for 'Join-Path' lines with '),' pattern and commas.)
if($raw -match '(?m)Join-Path\s+\([^)]*,[^)]*\)'){
  Fail ("FAIL: JOINPATH_ARGCOUNT Possible Join-Path array/argcount trap in step: {0}" -f $sp)
}

"PASS: JOINPATH_ARGCOUNT"