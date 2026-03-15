#requires -Version 7.0
param()

. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1')

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path

# Hard allowlist: critical scripts that must always parse
$targets = @(
  "tools/gate-closeout-after-commit.ps1",
  "tools/ego-step.ps1",
  "tools/step-run-latest.ps1",
  "tools/step-run.ps1",
  "tools/gatesets/p0-known-failures.ps1"
)

foreach($rel in $targets){
  $p = Join-Path $RepoRoot $rel
  if(-not (Test-Path -LiteralPath $p -PathType Leaf)){ Fail "FAIL: TOOLS_PARSE_MISSING: $rel" }

  $s = Get-Content -LiteralPath $p -Raw -Encoding UTF8
  $t = $null
  $e = $null
  [void][System.Management.Automation.Language.Parser]::ParseInput($s,[ref]$t,[ref]$e)
  if($null -ne $e -and $e.Count -gt 0){
    $first = $e[0]
    $line = $first.Extent.StartLineNumber
    $col  = $first.Extent.StartColumnNumber
    Fail ("FAIL: TOOLS_PARSE_ERROR in {0} (line {1}, col {2}): {3}" -f @($rel,$line,$col,$first.Message))
  }
}

"PASS: gate-tools-parse"
exit 0
