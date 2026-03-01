#requires -Version 7.0
# EGO_PARSERFIX05D_MINIMAL
param(
  [string]$RepoRoot = "",
  [string]$OutPath = ""
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
$seiten = Join-Path $Repo "seiten"
if(-not (Test-Path -LiteralPath $seiten)){ throw "STOP: seiten/ not found." }
$pages = @(Get-ChildItem -LiteralPath $seiten -File -Recurse -ErrorAction Stop |
  Where-Object { $_.Extension -in @(".md",".html") })
$map = @{}
foreach($p in $pages){
  $rel = $p.FullName.Substring($seiten.Length).TrimStart('\','/')
  $parts = $rel -split '[\\/]+'
  $theme = if($parts.Count -gt 1){ $parts[0].ToLowerInvariant() } else { "root" }
  if(-not $map.ContainsKey($theme)){ $map[$theme] = @() }
  $map[$theme] += ("/seiten/" + $rel.Replace('\','/'))
}
foreach($k in @($map.Keys)){
  $map[$k] = @($map[$k] | Sort-Object -Unique)
}
if(-not $OutPath){
  $OutPath = Join-Path $Repo "assets\audit\themen_pfade_map.json"
}
$OutDir = Split-Path -Parent $OutPath
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$json = ($map | ConvertTo-Json -Depth 6)
[IO.File]::WriteAllText($OutPath, $json + "`n", [Text.UTF8Encoding]::new($false))
"OK: gen-themen-pfade-map (minimal) wrote: $OutPath themes=$($map.Keys.Count) pages=$($pages.Count)"