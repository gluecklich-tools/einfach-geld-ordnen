#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)]
  [string]$StepPath
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($StepPath)) { throw "FAIL: StepPath empty" }
if (-not (Test-Path -LiteralPath $StepPath -PathType Leaf)) { throw "FAIL: StepPath not found: $StepPath" }

# Detect unsafe "$var:" within double-quoted strings / common patterns that trigger PS var-colon parsing issues.
# Minimal heuristic: find occurrences of $"<name>:" or " ... $name: ... " (dollar var immediately followed by colon)
# Exclude known scopes: $env:, $global:, $script:, $local:, $private:
$txt = Get-Content -LiteralPath $StepPath -Raw -Encoding UTF8

$rx = [regex]'"\s*[^"\r\n]*\$(?!env|global|script|local|private)([A-Za-z_][A-Za-z0-9_]*)\:\s*[^"\r\n]*"'
$m = $rx.Matches($txt)

if ($m.Count -gt 0) {
  $samples = $m | Select-Object -First 3 | ForEach-Object { $_.Value }
  Write-Host "=== GATE FAIL: STEP_INVALID_VAR_COLON_IN_DQ ==="
  Write-Host "StepPath: $StepPath"
  Write-Host "Found unsafe pattern `$var: inside double-quoted string."
  Write-Host "Fix: use `${var}: or use format operator (-f)."
  Write-Host "Samples:"
  $samples | ForEach-Object { Write-Host ("- " + $_) }
  throw "FAIL: STEP_INVALID_VAR_COLON_IN_DQ"
}

Write-Host "OK: gate-step-no-invalid-var-colon (no unsafe `$var: in double-quoted strings)"