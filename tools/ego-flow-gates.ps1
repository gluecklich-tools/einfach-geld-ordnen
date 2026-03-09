$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

if(-not (Test-Path -LiteralPath ".\_config.yml")){ Fail "Not in repo root (missing _config.yml)." }

# LOOPBREAKER: only parse critical entrypoints that are used by the flow.
$entry = @(
  "tools/ego-super-run.ps1",
  "tools/ego-law-run-safe.ps1",
  "tools/enterprise-preflight.ps1",
  "tools/ssot-sync.ps1",
  "tools/step-run.ps1",
  "tools/step-new.ps1",
  "tools/step-new-open.ps1",
  "tools/step-run-latest.ps1",
  "tools/ego-checksums.ps1",
  "tools/audit-l2-pack.ps1",
  "tools/ego-rereview-run.ps1",
  "tools/ego-rereview-lib.ps1"
)

foreach($rel in $entry){
  if(-not (Test-Path -LiteralPath (Join-Path "." $rel))){
    Fail ("Missing entry tool: {0}" -f $rel)
  }
}

foreach($rel in $entry){
  $full = (Resolve-Path (Join-Path "." $rel)).Path
  $t=$null; $e=$null
  [void][System.Management.Automation.Language.Parser]::ParseFile($full, [ref]$t, [ref]$e)
  if($e -and $e.Count -gt 0){
    Fail ("ParserError in entry tool: {0} | {1}" -f $rel, $e[0].Message)
  }
}

"PASS: ego-flow-gates (entrypoints only)"
# Recurring Step Failure Patterns
# - Allowlist must exist in every step
# - No parser-fragile inline report lines via $lines.Add("...") with leading markdown markers
# - No pipeline .Count directly on Where-Object results
# - No helper parameter-binding on empty Generic.List[string]; use direct .Add(...)
# EGO_LEARNING_SYNC_WIRE_START
$EgoLearningSyncAssert = Join-Path $PSScriptRoot "assert-no-pending-learning-sync.ps1"
if (Test-Path -LiteralPath $EgoLearningSyncAssert) {
    & $EgoLearningSyncAssert -AutoDrainSynced
}
# EGO_LEARNING_SYNC_WIRE_END
