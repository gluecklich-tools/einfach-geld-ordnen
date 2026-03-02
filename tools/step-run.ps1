param(
  [Parameter(Mandatory)][string]$StepPath
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

if([string]::IsNullOrWhiteSpace($StepPath)){ Fail "STOP: StepPath empty" }
$sp = $StepPath
try{ $sp = (Resolve-Path -LiteralPath $StepPath).Path } catch { Fail "STOP: StepPath not found: $StepPath" }

& $sp
$code = $LASTEXITCODE
if($code -ne 0){
  Fail "STOP: step failed (exit=$code) Step=$sp"
}

"PASS: step-run"
exit 0

# --- P0: STEP_WRITE_ALLOWLIST enforcement (required)
function Get-ChangedPathsFromPorcelain([string[]]$lines){
  $out = @()
  foreach($ln in @($lines)){
    if(-not $ln){ continue }
    if($ln.Length -ge 4){
      $path = $ln.Substring(3).Trim()
      if($path){ $out += $path }
    }
  }
  return $out
}
# Capture repo state BEFORE running the step (only affects tracked status; _local ignored by design elsewhere)
$preLines = @((git status --porcelain=v1))
$preSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach($p in (Get-ChangedPathsFromPorcelain $preLines)){ [void]$preSet.Add($p) }
# (The step execution happens ABOVE this block in step-run)
$postLines = @((git status --porcelain=v1))
$post = Get-ChangedPathsFromPorcelain $postLines
# Compute delta: files that are present in post but were NOT present in pre
$delta = @()
foreach($p in @($post)){
  if(-not $preSet.Contains($p)){ $delta += $p }
}
# Only enforce if delta exists; if no delta, pass.
if(@($delta).Count -gt 0){
  $gate = Join-Path $RepoRoot "tools\gate-step-write-allowlist.ps1"
  if(-not (Test-Path -LiteralPath $gate)){
    throw "FAIL: missing gate-step-write-allowlist.ps1 (expected at tools\gate-step-write-allowlist.ps1)"
  }
  pwsh -NoProfile -ExecutionPolicy Bypass -File $gate -RepoRoot $RepoRoot -StepPath $StepPath -ChangedPaths $delta
}

$pre = git status --porcelain=v1
# run the step (existing logic runs above)
$post = git status --porcelain=v1
function Get-ChangedPathsFromPorcelain([string[]]$lines){
  $out = @()
  foreach($ln in @($lines)){
    if(-not $ln){ continue }
    # porcelain v1: XY<space>path
    if($ln.Length -ge 4){
      $path = $ln.Substring(3).Trim()
      if($path){ $out += $path }
    }
  }
  return $out
}
$changedPaths = Get-ChangedPathsFromPorcelain ($post -split "`r?`n")
# Only enforce if something changed; if nothing changed, pass.
if(@($changedPaths).Count -gt 0){
  $gate = Join-Path $RepoRoot "tools\gate-step-write-allowlist.ps1"
  if(-not (Test-Path -LiteralPath $gate)){
    throw "FAIL: missing gate-step-write-allowlist.ps1 (expected at tools\gate-step-write-allowlist.ps1)"
  }
  pwsh -NoProfile -ExecutionPolicy Bypass -File $gate -RepoRoot $RepoRoot -StepPath $StepPath -ChangedPaths $changedPaths
}
