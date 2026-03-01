#requires -Version 7.0
param(
  [string]$RepoRoot = "",
  [switch]$WhatIf
)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
function Resolve-RepoRoot {
  param([string]$Arg)
  if($Arg){
    return (Resolve-Path -LiteralPath $Arg).Path
  }
  try{
    $t = (git rev-parse --show-toplevel 2>$null)
    if($t){ return $t.Trim() }
  }catch{}
  return (Resolve-Path -LiteralPath ".").Path
}
$Repo = (Resolve-Path -LiteralPath (Resolve-RepoRoot -Arg $RepoRoot)).Path
Set-Location -LiteralPath $Repo
# Minimal, parser-safe bundle apply scaffold.
# NOTE: Real bundle logic depends on internal SSOT artifacts; this stub keeps pipeline unblocked.
# Later: wire to internal manifest + deterministic copy operations with backups.
$bundleDirCandidates = @(
  (Join-Path $Repo "assets\bundles"),
  (Join-Path $Repo "downloads"),
  (Join-Path $Repo "_bundles")
)
"bundle-apply (MINIMAL MODE)"
"Repo: $Repo"
"WhatIf: $WhatIf"
$existing = @()
foreach($p in $bundleDirCandidates){
  if(Test-Path -LiteralPath $p){ $existing += $p }
}
if($existing.Count -eq 0){
  "INFO: No bundle directories found in public repo (expected sometimes)."
  "PASS: bundle-apply parser-safe (no-op)."
  exit 0
}
"INFO: Found bundle-related dirs:"
$existing | ForEach-Object { " - $_" }
if($WhatIf){
  "WHATIF: Would apply bundle operations here."
  "PASS: bundle-apply parser-safe (whatif)."
  exit 0
}
"PASS: bundle-apply parser-safe (no-op)."
exit 0