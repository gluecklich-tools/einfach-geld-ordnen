# EGO_SSOT_GUARD_V1
# Optional: SSOT guard (only if EGO_INTERNAL_DIR is set and ssot-guard exists)
$internalRoot = $env:EGO_INTERNAL_DIR
if ($internalRoot) {
  $guard = Join-Path $internalRoot ('tools' + [char]92 + 'ssot-guard.ps1')
  if (Test-Path -LiteralPath $guard) { & $guard -RequireCleanRepo }
}

param(
  [Parameter(Mandatory)][string]$ScriptPath,
  [string[]]$ScriptArgs = @()
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Test-Path $ScriptPath)) { throw "Missing ScriptPath: $ScriptPath" }

function GitStatusPorcelain {
  return (git status --porcelain)
}

$before = GitStatusPorcelain
if ($before -and $before.Trim().Length -gt 0) {
  throw "Repo not clean BEFORE tool run. Aborting."
}

& $ScriptPath @ScriptArgs

$after = GitStatusPorcelain
if ($after -and $after.Trim().Length -gt 0) {
  throw "TOOL VIOLATION: Repo changed AFTER tool run. Commit blocked. Run: git restore . ; git clean -fd"
}

Write-Host "OK: Tool ran read-only. Repo still clean."