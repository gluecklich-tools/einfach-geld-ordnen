param(
  [Parameter(Mandatory=$true)][string]$StepPath
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

function Get-RepoRoot {
  $p = (& git rev-parse --show-toplevel 2>$null)
  if (-not $p) { Fail "RepoRoot konnte nicht bestimmt werden (git rev-parse)." }
  return (Resolve-Path -LiteralPath $p).Path
}

function Read-AllowlistFromStepText {
  param([Parameter(Mandatory=$true)][string]$Text)
  # Erwartet literal: $EGO_STEP_WRITE_ALLOWLIST = @( 'path', ... )
  $m = [regex]::Match($Text, '(?is)\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\((.*?)\)\s*', [System.Text.RegularExpressions.RegexOptions]::None)
  if (-not $m.Success) { return $null }

  $inner = $m.Groups[1].Value
  # Nur single-quoted Strings extrahieren (Enterprise: literal-only)
  $ms = [regex]::Matches($inner, "'([^']*)'")
  $list = @()
  foreach ($x in $ms) { $list += $x.Groups[1].Value }
  if (@($list).Count -eq 0) { return $null }
  return $list
}

$RepoRoot = Get-RepoRoot
$StepFull = (Resolve-Path -LiteralPath $StepPath).Path
if (-not (Test-Path -LiteralPath $StepFull)) { Fail "Step not found: $StepFull" }

# Gate: Tools parse (existing scripts call this upstream; keep local minimal)
# Gate: Step Allowlist MUST exist (read from file, not from session scope)
$txt = Get-Content -LiteralPath $StepFull -Raw -ErrorAction Stop
$allow = Read-AllowlistFromStepText -Text $txt
if (-not $allow) { Fail "FAIL: step missing `$EGO_STEP_WRITE_ALLOWLIST = @(...)." }

# Execute step
& pwsh -NoProfile -ExecutionPolicy Bypass -File $StepFull
if ($LASTEXITCODE -ne 0) { Fail "STOP: step-run failed (exit=$LASTEXITCODE)" }

"PASS: step-run"
