#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

# P0 gate: block accidental "$0" in replacement strings (PowerShell has no $0 like sed/perl).
# Allowed: regex backreference `${0}` (rare). Block: `... "$0" ...` and `... '$0' ...`.

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path

$targets = @()
$targets += Get-ChildItem -LiteralPath (Join-Path $RepoRoot "tools") -File -Filter "*.ps1" -ErrorAction SilentlyContinue
$targets += Get-ChildItem -LiteralPath (Join-Path $RepoRoot "_local\_scratch") -File -Filter "step_*.ps1" -ErrorAction SilentlyContinue

$hits = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  # flag "$0" or '$0' but not `${0}`
  if($raw -match '(?s)(?<!\`)\$0' -and $raw -notmatch '\$\{0\}'){
    $hits.Add($f.FullName)
  }
  if($raw -match "(?s)'\$0'"){
    $hits.Add($f.FullName)
  }
  if($raw -match '(?s)"\$0"'){
    $hits.Add($f.FullName)
  }
}

$hits = @($hits | Sort-Object -Unique)

if($hits.Count -gt 0){
  Fail ("FAIL: NO_DOLLAR0_REPLACE`nFound `$0 usage in:`n - " + ($hits -join "`n - "))
}

"PASS: gate-no-dollar0-regex-replace"