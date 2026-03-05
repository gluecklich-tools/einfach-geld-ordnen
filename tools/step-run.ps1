#requires -Version 7.0
param(
  [string]$StepPath
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$ConfirmPreference = 'None'
$ProgressPreference = 'SilentlyContinue'
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$NL = [Environment]::NewLine
function Fail([string]$m){ throw $m }

function Resolve-RepoRoot {
  $t = (git rev-parse --show-toplevel 2>$null)
  if([string]::IsNullOrWhiteSpace($t)){ Fail 'RepoRoot not found (git rev-parse failed).' }
  (Resolve-Path -LiteralPath $t).Path
}

if(-not $PSBoundParameters.ContainsKey('StepPath') -or [string]::IsNullOrWhiteSpace($StepPath)){
  Fail 'STEPFILE_REQUIRED: -StepPath must be provided (no prompting).'
}

$RepoRoot = Resolve-RepoRoot
& (Join-Path $PSScriptRoot 'gate-step-no-invalid-var-colon.ps1') -StepPath $StepPath

$sp = $StepPath
try { $sp = (Resolve-Path -LiteralPath $StepPath).Path } catch { Fail ('STOP: StepPath not found: {0}' -f $StepPath) }

function Get-ChangedPathsFromPorcelain([string[]]$lines){
  $out = @()
  foreach($ln in @($lines)){
    if(-not $ln){ continue }
    if($ln.Length -ge 4){
      $p = $ln.Substring(3).Trim()
      if($p){
        $p = $p -replace "\\","/"
        if($p -notlike "_local/*"){ $out += $p }
      }
    }
  }
  return $out
}

$preLines = @((git status --porcelain=v1))
$preChanged = Get-ChangedPathsFromPorcelain $preLines
if(@($preChanged).Count -gt 0){
  $msg = @()
  $msg += 'REPO_DIRTY_BEFORE_STEP: make repo clean before running steps.'
  $msg += 'Changed paths (excluding _local):'
  $msg += ($preChanged | ForEach-Object { '- ' + $_ })
  $msg += ''
  $msg += 'Fix (choose one):'
  $msg += '1) Restore all shown paths:'
  $msg += '   git restore -- ' + ($preChanged -join ' ')
  $msg += '2) Or stage/commit if intentional.'
  $msg += '3) Re-run step afterwards.'
  Fail ($msg -join $NL)
}

& $sp
$code = $LASTEXITCODE
if($code -ne 0){
  Fail ('STOP: step failed (exit={0}) Step={1}' -f $code, $sp)
}

$postLines = @((git status --porcelain=v1))
$postChanged = Get-ChangedPathsFromPorcelain $postLines
if(@($postChanged).Count -gt 0){
  $gate = Join-Path $RepoRoot 'tools\gate-step-write-allowlist.ps1'
  if(-not (Test-Path -LiteralPath $gate)){
    Fail 'FAIL: missing gate-step-write-allowlist.ps1 (expected at tools\gate-step-write-allowlist.ps1)'
  }
  try {
    & $gate -RepoRoot $RepoRoot -StepPath $sp -ChangedPaths @($postChanged)
  } catch {
    $m = @()
    $m += 'FAIL: gate-step-write-allowlist failed'
    $m += $_.Exception.Message
    Fail ($m -join $NL)
  }
}

"PASS: step-run"
exit 0
