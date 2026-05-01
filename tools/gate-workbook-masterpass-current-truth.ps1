$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = (& git rev-parse --show-toplevel 2>$null)
if (-not $RepoRoot) { throw 'REPOROOT_NOT_FOUND' }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$Tool = Join-Path $RepoRoot '_INTERN\tools\ego-workbook-masterpass-current-truth-gate.ps1'
if (-not (Test-Path -LiteralPath $Tool -PathType Leaf)) {
  throw "MISSING_TOOL: $Tool"
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $Tool -RepoRoot $RepoRoot
