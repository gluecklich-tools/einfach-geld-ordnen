#requires -Version 7.0
param()
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
function Fail([string]$m){ throw $m }
$Repo = $null
try{ $Repo = (git rev-parse --show-toplevel 2>$null).Trim() }catch{}
if(-not $Repo){ $Repo = (Resolve-Path -LiteralPath ".").Path }
$Repo = (Resolve-Path -LiteralPath $Repo).Path
Set-Location -LiteralPath $Repo
# MVP02 gate (minimal, parser-safe):
# Ziel: Preflight darf nicht am Parser scheitern.
# Inhaltlich konservativ: prüft Grundstruktur (Repo + seiten + includes) und meldet "minimal mode".
$seiten = Join-Path $Repo "seiten"
$includes = Join-Path $Repo "_includes"
$config = Join-Path $Repo "_config.yml"
$missing = @()
foreach($p in @($seiten,$includes,$config)){
  if(-not (Test-Path -LiteralPath $p)){ $missing += $p }
}
if($missing.Count -gt 0){
  "FAIL: MVP02 gate missing required repo structure:"
  $missing
  Fail ("STOP: mvp02-gate fail (missing={0})" -f $missing.Count)
}
$pages = @(Get-ChildItem -LiteralPath $seiten -File -Recurse -ErrorAction Stop | Where-Object { $_.Extension -in @(".md",".html") })
$inc = @(Get-ChildItem -LiteralPath $includes -File -ErrorAction Stop)
"PASS: mvp02-gate parser-safe (minimal mode). pages={0} includes={1}" -f @($pages.Count, $inc.Count)
