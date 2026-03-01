#requires -Version 7.0
# EGO_PARSERFIX06_MINIMAL
param(
  [string]$RepoRoot = "",
  [string]$InPath = "",
  [string]$OutPath = "",
  [switch]$WhatIf
)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
function Resolve-RepoRoot([string]$arg){
  if($arg){ return (Resolve-Path -LiteralPath $arg).Path }
  try{
    $t = (git rev-parse --show-toplevel 2>$null)
    if($t){ return $t.Trim() }
  }catch{}
  return (Resolve-Path -LiteralPath ".").Path
}
$Repo = (Resolve-Path -LiteralPath (Resolve-RepoRoot $RepoRoot)).Path
Set-Location -LiteralPath $Repo
# Minimal mode:
# - If InPath is given: copy it to OutPath (or print info)
# - Otherwise: no-op with PASS message
if([string]::IsNullOrWhiteSpace($InPath)){
  "PASS: ego-pagecard (minimal) no InPath provided. (parser-safe no-op)"
  exit 0
}
$inFull = $InPath
if(-not (Test-Path -LiteralPath $inFull)){
  # Try relative to repo
  $cand = Join-Path $Repo $InPath
  if(Test-Path -LiteralPath $cand){ $inFull = $cand }
}
if(-not (Test-Path -LiteralPath $inFull)){
  throw "STOP: InPath not found: $InPath"
}
if([string]::IsNullOrWhiteSpace($OutPath)){
  $OutPath = Join-Path $Repo "assets\audit\ego_pagecard_out.html"
}
$outDir = Split-Path -Parent $OutPath
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
if($WhatIf){
  "WHATIF: would copy '$inFull' -> '$OutPath'"
  "PASS: ego-pagecard (minimal) whatif"
  exit 0
}
Copy-Item -LiteralPath $inFull -Destination $OutPath -Force
"PASS: ego-pagecard (minimal) wrote: $OutPath"