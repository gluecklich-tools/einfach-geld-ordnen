#requires -Version 7.0
param(
  [string]$RepoRoot = $null
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Resolve-RepoRoot {
  if($RepoRoot -and $RepoRoot.Trim()){ return (Resolve-Path -LiteralPath $RepoRoot).Path }
  try { $t=(git rev-parse --show-toplevel 2>$null); if($t){ return (Resolve-Path -LiteralPath $t.Trim()).Path } } catch {}
  return (Resolve-Path -LiteralPath ".").Path
}

function Has-NonAscii([byte[]]$bytes){
  foreach($b in $bytes){ if($b -gt 0x7F){ return $true } }
  return $false
}

$root = Resolve-RepoRoot
$toolsDir = Join-Path $root "tools"
if(-not (Test-Path -LiteralPath $toolsDir -PathType Container)){
  "OK: gate-tools-ascii-only: tools dir missing (skip)"
  exit 0
}

$files = Get-ChildItem -LiteralPath $toolsDir -Recurse -File -Filter "*.ps1" -ErrorAction SilentlyContinue
$bad = New-Object 'System.Collections.Generic.List[string]'

foreach($f in $files){
  $bytes = [IO.File]::ReadAllBytes($f.FullName)
  if(Has-NonAscii $bytes){
    $bad.Add($f.FullName) | Out-Null
  }
}

if($bad.Count -gt 0){
  Write-Host "=== GATE FAIL: TOOLS_ASCII_ONLY ==="
  foreach($p in $bad){ Write-Host $p }
  throw "Tools contain non-ascii bytes. Use unicode escapes or ASCII-only source."
}

"OK: gate-tools-ascii-only (all tools/*.ps1 ASCII-only)"