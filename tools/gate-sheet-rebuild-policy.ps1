$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ACTIVE_HASH=EFBF439CE3EC0450530D48E211CC8FF6887B7259E2333E65C7A5DA595D36390B
# NEXT=REPRIORITIZE_NEXT_ACTIVE_SHEET
# NOTGROSCHEN_FREEZE_ACCEPTED=ENFORCED
# PRODUCT_OPEN_PROOF_REQUIRED_BEFORE_FREEZE=ENFORCED

$RepoRoot = (& git rev-parse --show-toplevel 2>$null)
if (-not $RepoRoot) { throw 'REPOROOT_NOT_FOUND' }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$Tool = Join-Path $RepoRoot '_INTERN\tools\ego-sheet-rebuild-policy-preflight.ps1'
if (-not (Test-Path -LiteralPath $Tool -PathType Leaf)) {
  throw ("MISSING_INTERNAL_TOOL: {0}" -f $Tool)
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $Tool -RepoRoot $RepoRoot
