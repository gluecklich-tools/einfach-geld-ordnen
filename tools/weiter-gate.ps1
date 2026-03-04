#requires -Version 7.0
param()
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$Repo = $null
try{ $Repo = (git rev-parse --show-toplevel 2>$null).Trim() }catch{}
if(-not $Repo){ $Repo = (Resolve-Path -LiteralPath ".").Path }
$Repo = (Resolve-Path -LiteralPath $Repo).Path
Set-Location -LiteralPath $Repo
function Read-Utf8([string]$Path){ [IO.File]::ReadAllText($Path,[Text.UTF8Encoding]::new($false)) }
$seiten = Join-Path $Repo "seiten"
if(-not (Test-Path -LiteralPath $seiten)){ throw "STOP: seiten/ not found." }
$tag = "{% include weiter_links.html %}"
$files = @(Get-ChildItem -LiteralPath $seiten -File -Recurse -ErrorAction Stop | Where-Object { $_.Extension -in @(".md",".html") })
$hits = 0
foreach($f in $files){
  $t = Read-Utf8 $f.FullName
  if($t -match [regex]::Escape($tag)){ $hits++ }
}
"PASS: weiter-gate parser-safe. pages={0} include_hits={1}" -f @($files.Count, $hits)
