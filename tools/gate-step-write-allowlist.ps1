param(
  [string]$StepPath
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

function Read-AllowlistFromStepText {
  param([Parameter(Mandatory=$true)][string]$Text)
  $m = [regex]::Match($Text, '(?is)\tools\step-new.ps1 tools\new-step.ps1 tools\gate-step-write-allowlist.ps1 _patch_backups\ _local\_reports\\s*=\s*@\((.*?)\)\s*')
  if (-not $m.Success) { return $null }
  $inner = $m.Groups[1].Value
  $ms = [regex]::Matches($inner, "'([^']*)'")
  $list = @()
  foreach ($x in $ms) { $list += $x.Groups[1].Value }
  if (@($list).Count -eq 0) { return $null }
  return $list
}

# If no StepPath given: do NOT enforce (tool context safe)
if (-not $StepPath) {
  "SKIP: gate-step-write-allowlist (no StepPath)"
  exit 0
}

$full = (Resolve-Path -LiteralPath $StepPath).Path
if (-not (Test-Path -LiteralPath $full)) { Fail "Step not found: $full" }

$txt = Get-Content -LiteralPath $full -Raw -ErrorAction Stop
$allow = Read-AllowlistFromStepText -Text $txt
if (-not $allow) { Fail "FAIL: step missing $EGO_STEP_WRITE_ALLOWLIST = @(...)." }

"PASS: gate-step-write-allowlist"
