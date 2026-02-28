param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$StepPath,
  [string]$StepName
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
function Fail([string]$m){ throw $m }
function Resolve-Step([string]$RepoRoot,[string]$StepPath,[string]$StepName){
  $scratch = Join-Path $RepoRoot '_local\_scratch'
  if($StepName){
    $cand1 = Join-Path $scratch $StepName
    if(Test-Path -LiteralPath $cand1){ return $cand1 }
    $cand2 = Join-Path $RepoRoot $StepName
    if(Test-Path -LiteralPath $cand2){ return $cand2 }
    "HINT: StepName not found. Top files in _local/_scratch:"
    if(Test-Path -LiteralPath $scratch){
      Get-ChildItem -LiteralPath $scratch -File | Sort-Object LastWriteTime -Descending | Select-Object -First 10 Name,LastWriteTime | Format-Table -AutoSize
    }
    Fail ("STOP: StepName not found: {0}" -f $StepName)
  }
  if($StepPath){
    $sp = $StepPath
    if(!(Test-Path -LiteralPath $sp)){
      $cand = Join-Path $RepoRoot $StepPath
      if(Test-Path -LiteralPath $cand){ $sp = $cand }
    }
    if(Test-Path -LiteralPath $sp){ return $sp }
    "HINT: StepPath not found. Top files in _local/_scratch:"
    if(Test-Path -LiteralPath $scratch){
      Get-ChildItem -LiteralPath $scratch -File | Sort-Object LastWriteTime -Descending | Select-Object -First 10 Name,LastWriteTime | Format-Table -AutoSize
    }
    Fail ("STOP: StepPath not found: {0}" -f $StepPath)
  }
  Fail "STOP: provide -StepName or -StepPath"
}
$here = $PSScriptRoot
$stepResolved = Resolve-Step -RepoRoot $RepoRoot -StepPath $StepPath -StepName $StepName
# Hard rail: must be a real file in _local/_scratch (prevents inline)
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'gate-stepfile-required.ps1') -RepoRoot $RepoRoot -StepPath $stepResolved
if($LASTEXITCODE -ne 0){ Fail "STOP: gate-stepfile-required failed" }
# Preflight (current repo variant)
$preflight = Join-Path $here 'enterprise-preflight.ps1'
if(Test-Path -LiteralPath $preflight){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $preflight -RepoRoot $RepoRoot
  if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed" }
}
# Run step
$runner = Join-Path $here 'step-run.ps1'
if(!(Test-Path -LiteralPath $runner)){ Fail ("STOP: missing step-run: {0}" -f $runner) }
& pwsh -NoProfile -ExecutionPolicy Bypass -File $runner -StepPath $stepResolved
$ec = $LASTEXITCODE
if($ec -ne 0){ Fail ("STOP: step-run failed (exit={0})" -f $ec) }
"OK: enterprise-run completed"