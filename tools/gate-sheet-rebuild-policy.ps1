$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ACTIVE_HASH=B6C0F00D11F358C59FF369BA5DF491AF1935617BA79CA5D6877836E02490BC29
# NEXT=STOP_APPLY_AND_REPLAN_NOTGROSCHEN_WITH_SAFE_METHOD
# NO_BLIND_OPENXML_STYLE_MERGE_REBUILD=ENFORCED
# EXCEL_REPAIR_DIALOG_IS_HARD_REJECT=ENFORCED

$RepoRoot = (& git rev-parse --show-toplevel 2>$null)
if (-not $RepoRoot) { throw 'REPOROOT_NOT_FOUND' }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$Tool = Join-Path $RepoRoot '_INTERN\tools\ego-sheet-rebuild-policy-preflight.ps1'
if (-not (Test-Path -LiteralPath $Tool -PathType Leaf)) {
  throw ("MISSING_INTERNAL_TOOL: {0}" -f $Tool)
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $Tool -RepoRoot $RepoRoot
