$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Gate tokens:
# ACTIVE_HASH=C173914A98321FFA1FFB2B58A07361E6401F0BD869D52967AA2DE789C927BD82
# NEXT=SCREENSHOT_NOTGROSCHEN_100_PERCENT
# POLICY=SHEET_CONTRACT_REBUILD_FIRST
# CORRECTION_LIMIT=MAX_3_CORRECTIONS_THEN_REBUILD
# TECHNICAL_PASS_IS_NOT_VISUAL_ACCEPTANCE=ENFORCED

$RepoRoot = (& git rev-parse --show-toplevel 2>$null)
if (-not $RepoRoot) {
  throw 'REPOROOT_NOT_FOUND'
}
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$Tool = Join-Path $RepoRoot '_INTERN\tools\ego-sheet-rebuild-policy-preflight.ps1'
if (-not (Test-Path -LiteralPath $Tool -PathType Leaf)) {
  throw ("MISSING_INTERNAL_TOOL: {0}" -f $Tool)
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $Tool -RepoRoot $RepoRoot
