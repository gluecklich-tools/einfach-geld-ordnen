param(
  [string]$RepoRoot = (Get-Location).Path,
  [Parameter(Mandatory)][string]$StepPath
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
function Fail([string]$m){ throw $m }
# Resolve StepPath (allow relative paths)
$sp = $StepPath
if(!(Test-Path -LiteralPath $sp)){
  $cand = Join-Path $RepoRoot $StepPath
  if(Test-Path -LiteralPath $cand){ $sp = $cand }
}
if(!(Test-Path -LiteralPath $sp)){ Fail ("STOP: StepPath not found: {0}" -f $StepPath) }
$StepResolved = $sp
$here = $PSScriptRoot
# P0 Hard Rail: Step must be a real file in _local/_scratch
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'gate-stepfile-required.ps1') -RepoRoot $RepoRoot -StepPath $StepResolved
if($LASTEXITCODE -ne 0){ Fail "STOP: gate-stepfile-required failed" }
# HARD GATE: research proof present (local)
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'gate-research-proof-required.ps1') -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: gate-research-proof-required failed" }
# HARD GATE: brain sync required (local)
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'brain-sync-required.ps1') -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: brain-sync-required failed" }
# P0 Gate: prevent risky dq regex + dollar sequences in step
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'gate-no-dq-regex-with-dollar.ps1') -RepoRoot $RepoRoot -StepPath $StepResolved
if($LASTEXITCODE -ne 0){ Fail "STOP: gate-no-dq-regex-with-dollar failed" }
# P0 Gate: no command glue
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'gate-no-command-glue.ps1') -StepPath $StepResolved
if($LASTEXITCODE -ne 0){ Fail "STOP: gate-no-command-glue failed" }
# P0 Gate: steps must not contain 'exit'
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'gate-no-exit-in-steps.ps1') -StepPath $StepResolved
if($LASTEXITCODE -ne 0){ Fail "STOP: gate-no-exit-in-steps failed" }
# Preflight (public repo variant)
$preflight = Join-Path $here 'enterprise-preflight.ps1'
if(!(Test-Path -LiteralPath $preflight)){ Fail ("STOP: missing preflight: {0}" -f $preflight) }
& pwsh -NoProfile -ExecutionPolicy Bypass -File $preflight -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed" }
# Run step
$runner = Join-Path $here 'step-run.ps1'
if(!(Test-Path -LiteralPath $runner)){ Fail ("STOP: missing step-run: {0}" -f $runner) }
& pwsh -NoProfile -ExecutionPolicy Bypass -File $runner -StepPath $StepResolved
$ec = $LASTEXITCODE
if($ec -ne 0){
  Fail ("STOP: step-run failed (exit={0})" -f $ec)
}
"OK: enterprise-run completed"