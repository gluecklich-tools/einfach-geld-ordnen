$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# GATE_WRAPPER_STAGE1
# STAGE_PROOF_BEFORE_PRODUCTIVE_APPLY=P0
# NO_MICROFIXING=P0
# NEXT=SCAN_STAGE1_MASTERPASS_BASELINE_NO_MUTATION

$RepoRoot = (& git rev-parse --show-toplevel 2>$null)
if (-not $RepoRoot) { throw 'REPOROOT_NOT_FOUND' }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$Tool = Join-Path $RepoRoot '_INTERN\tools\ego-workbook-masterpass-current-truth-gate.ps1'
if (-not (Test-Path -LiteralPath $Tool -PathType Leaf)) {
  throw "MISSING_TOOL: $Tool"
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $Tool -RepoRoot $RepoRoot
