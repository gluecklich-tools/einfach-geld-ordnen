#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][string]$RepoRoot,
  [Parameter(Mandatory=$true)][string]$StepPath,
  [Parameter(Mandatory=$true)][string[]]$ChangedPaths
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
function Normalize-Rel([string]$p){
  $p = $p -replace '\\','/'
  $p.TrimStart('./')
}
function Get-AllowlistFromStep([string]$stepFile){
  $raw = Get-Content -LiteralPath $stepFile -Raw -Encoding UTF8
  # Required marker:
  # $EGO_STEP_WRITE_ALLOWLIST = @(
  #   "a",
  #   "b"
  # )
  $m = [regex]::Match($raw, '(?ms)\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\(\s*(.*?)\s*\)')
  if(-not $m.Success){
    throw "FAIL: STEP_WRITE_ALLOWLIST_MISSING in step: $stepFile"
  }
  $inner = $m.Groups[1].Value
  $items = [regex]::Matches($inner, '(?m)^\s*"(.*?)"\s*,?\s*$') | ForEach-Object { $_.Groups[1].Value }
  $list = @($items) | Where-Object { $_ -and $_.Trim().Length -gt 0 } | ForEach-Object { Normalize-Rel $_ }
  if(@($list).Count -lt 1){
    throw "FAIL: STEP_WRITE_ALLOWLIST_EMPTY in step: $stepFile"
  }
  return $list
}
$Repo = Resolve-Path -LiteralPath $RepoRoot
$Step = Resolve-Path -LiteralPath $StepPath
$allow = Get-AllowlistFromStep $Step.Path
$changed = @($ChangedPaths) | ForEach-Object { Normalize-Rel $_ }
$viol = @()
foreach($c in $changed){
  if($allow -notcontains $c){
    $viol += $c
  }
}
if(@($viol).Count -gt 0){
  throw ("FAIL: STEP_WRITE_ALLOWLIST_VIOLATION`nAllowed: " + ($allow -join ", ") + "`nChanged: " + ($changed -join ", ") + "`nViolations: " + ($viol -join ", "))
}
"PASS: gate-step-write-allowlist (changed within allowlist)"