# P0 Gate: NO_DQ_REGEX_WITH_DOLLAR (StrictMode-safe regex hygiene)
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'gate-no-dq-regex-with-dollar.ps1') -RepoRoot $RepoRoot -StepPath $StepPath
if($LASTEXITCODE -ne 0){ throw "STOP: gate-no-dq-regex-with-dollar failed (exit=$LASTEXITCODE)" }
# P0 Gate: NO_COMMAND_GLUE (prevents ""REPORT: ...""pwsh ... class)
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'gate-no-command-glue.ps1') -StepPath $StepPath
if($LASTEXITCODE -ne 0){ throw "STOP: gate-no-command-glue failed (exit=$LASTEXITCODE)" }
param(
  [Parameter(Mandatory)][string]$StepPath
)

$ErrorActionPreference='Stop'
# EGO_GUARD_PLACEHOLDER_STEP
if($StepPath -match "[<>]" -or $StepPath -like "*...*"){
  Fail ("STOP: StepPath looks like a placeholder. Use a real file path. GivenArg: [{0}]" -f $StepPath)
}
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

# P0 Gate: steps must not contain 'exit' (prevents terminal/session kill)
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'gate-no-exit-in-steps.ps1') -StepPath $StepPath
if($LASTEXITCODE -ne 0){ throw "STOP: gate-no-exit-in-steps failed (exit=$LASTEXITCODE)" }
$enc=[Text.UTF8Encoding]::new($false)

function WriteRunReport([string]$Status,[string]$Message,[string]$RepoRoot,[string]$StepArg,[string]$StepResolved){
  $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
  $dir = Join-Path $RepoRoot "_local\reports"
  if(!(Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $rep = Join-Path $dir ("enterprise_run_{0}.md" -f $ts)
  $lines = @()
  $lines += "# ENTERPRISE RUN"
  $lines += ""
  $lines += "* Timestamp: $ts"
  $lines += "* Status: $Status"
  $lines += "* RepoRoot: $RepoRoot"
  $lines += "* StepArg: $StepArg"
  $lines += "* StepResolved: $StepResolved"
  $lines += "* PSVersion: $($PSVersionTable.PSVersion)"
  $lines += ""
  $lines += "## Message"
  $lines += ""
  $lines += $Message
  [IO.File]::WriteAllText($rep, ($lines -join "`n"), $enc)
}

function Fail([string]$m){
  try{ WriteRunReport -Status 'FAIL' -Message $m -RepoRoot $repoRoot -StepArg $stepArg -StepResolved $stepResolved }catch{}
  Write-Error $m
  exit 3
}

$toolsRoot = $PSScriptRoot
$repoRoot  = Split-Path -Parent $toolsRoot
if(!(Test-Path -LiteralPath (Join-Path $repoRoot ".git"))){ Fail "STOP: not in repo root. RepoRoot=$repoRoot" }

$preflight = Join-Path $toolsRoot "enterprise-preflight.ps1"
$stepRun   = Join-Path $toolsRoot "step-run.ps1"
if(!(Test-Path -LiteralPath $preflight)){ Fail "STOP: missing preflight: $preflight" }
if(!(Test-Path -LiteralPath $stepRun)){   Fail "STOP: missing step-run: $stepRun" }

$stepArg = $StepPath
if([string]::IsNullOrWhiteSpace($stepArg)){ Fail "STOP: StepPath empty" }

# Normalize: trim + strip quotes + absolutize relative to repoRoot
$p = $stepArg.Trim().Trim('"').Trim("'")
if(-not [IO.Path]::IsPathRooted($p)){ $p = Join-Path $repoRoot $p }
$p = [IO.Path]::GetFullPath($p)

# Existence check (robust)
if(-not [IO.File]::Exists($p)){
  $msg = @()
  $msg += "STOP: StepPath not found."
  $msg += "GivenArg: [$stepArg]"
  $msg += "Normalized: [$p]"
  $msg += "ArgLength: $($stepArg.Length)"
  $msg += "Hint: check trailing spaces/newlines/quotes."
  Fail ($msg -join "`n")
}

# Enforce NO_STUECKWERK: step must be under _local\_scratch
$scratch = Join-Path $repoRoot "_local\_scratch"
if(!(Test-Path -LiteralPath $scratch)){ New-Item -ItemType Directory -Force -Path $scratch | Out-Null }
$scratchFull = (Resolve-Path -LiteralPath $scratch).Path
if(-not $p.StartsWith($scratchFull,[StringComparison]::OrdinalIgnoreCase)){
  Fail ("STOP: StepPath must be under _local\_scratch. Given: {0}`nAllowedRoot: {1}" -f $p,$scratchFull)
}

$stepResolved = $p

# Preflight then Step-run
& pwsh -NoProfile -File $preflight -RepoRoot $repoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: preflight failed (exit=$LASTEXITCODE)" }

& pwsh -NoProfile -File $stepRun -StepPath $stepResolved
$code = $LASTEXITCODE
if($code -ne 0){ Fail "STOP: step-run failed (exit=$code) Step=$stepResolved" }

WriteRunReport -Status 'PASS' -Message 'PASS: enterprise-run' -RepoRoot $repoRoot -StepArg $stepArg -StepResolved $stepResolved
"PASS: enterprise-run"
exit 0
