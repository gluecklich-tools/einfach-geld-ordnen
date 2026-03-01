#requires -Version 7.0
param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$StepPath,
  [string]$StepName
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

# STRICTMODE_STRINGS_V1_REMINDER:
# - In double-quoted strings, `$var` interpolates. Under StrictMode this can STOP if var not set.
# - For literal `$var` text in messages/docs use single quotes or escape: `` `$ ``.
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

# === HARD LAW: NO_STEPFILE_NO_RUN (P0) ===
# If StepName is provided:
# - MUST match step_*.ps1
# - MUST exist under _local\_scratch
# This prevents "StepName not found" loops and blocks non-file execution patterns.
# EGO_HARDLAW_ONLY_STEPPATH_FIX_V1:
# Only enforce StepName naming/existence rules when StepName is provided.
if(-not [string]::IsNullOrWhiteSpace($StepName)){
  if($StepName -notmatch '^step_.*\.ps1$'){
    Fail ("STOP: StepName must match step_*.ps1, got: {0}" -f $StepName)
  }
  $scratch0 = Join-Path $RepoRoot '_local\_scratch'
  $must = Join-Path $scratch0 $StepName
  if(!(Test-Path -LiteralPath $must)){
    Fail ("STOP: Step file missing: {0}. Create/save it first. (LAW: NO_STEPFILE_NO_RUN)" -f $must)
  }
}
# === /HARD LAW ===

# === STEP MARKER (LAW: NO_INLINE_STEP_EXECUTION) ===
# We write a fresh marker whenever a step is invoked via StepName.
# EGO_HARDLAW_ONLY_STEPPATH_FIX_V1:
# Only enforce StepName naming/existence rules when StepName is provided.
if(-not [string]::IsNullOrWhiteSpace($StepName)){
  $markerDir = Join-Path $RepoRoot "_local\_scratch"
  if(!(Test-Path -LiteralPath $markerDir)){ New-Item -ItemType Directory -Path $markerDir -Force | Out-Null }
  $marker = Join-Path $markerDir "_LAST_STEP_RUN.json"
  $payload = [pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    step_name = $( if(-not [string]::IsNullOrWhiteSpace($StepName)){ $StepName } else { try { Split-Path -Leaf $StepPath } catch { "" } } )
    repo_root = $RepoRoot
    pwsh      = $PSVersionTable.PSVersion.ToString()
  } | ConvertTo-Json -Depth 4
  [IO.File]::WriteAllText($marker, $payload, ([Text.UTF8Encoding]::new($false)))
}
# === /STEP MARKER ===

function Resolve-Step([string]$RepoRoot,[string]$StepPath,[string]$StepName){
  $scratch = Join-Path $RepoRoot '_local\_scratch'
# EGO_HARDLAW_ONLY_STEPPATH_FIX_V1:
# Only enforce StepName naming/existence rules when StepName is provided.
if(-not [string]::IsNullOrWhiteSpace($StepName)){
    # HARD LAW already ensured _local\_scratch\StepName exists.
    $cand1 = Join-Path $scratch $StepName
    if(Test-Path -LiteralPath $cand1){ return $cand1 }
    Fail ("STOP: internal: step missing after LAW check: {0}" -f $cand1)
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
      Get-ChildItem -LiteralPath $scratch -File | Sort-Object LastWriteTime -Descending |
        Select-Object -First 10 Name,LastWriteTime | Format-Table -AutoSize
    }
    Fail ("STOP: StepPath not found: {0}" -f $StepPath)
  }

  Fail "STOP: provide -StepName or -StepPath"
}

$here = $PSScriptRoot
$stepResolved = Resolve-Step -RepoRoot $RepoRoot -StepPath $StepPath -StepName $StepName

# Hard rail: must be a real file in _local/_scratch (prevents inline)
$gateReq = Join-Path $here 'gate-stepfile-required.ps1'
if(Test-Path -LiteralPath $gateReq){
  & pwsh -NoProfile -ExecutionPolicy Bypass -File $gateReq -RepoRoot $RepoRoot -StepPath $stepResolved
  if($LASTEXITCODE -ne 0){ Fail "STOP: gate-stepfile-required failed" }
}

# Preflight (repo variant)
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
exit 0