#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

# P0 gate: block accidental "$0" usage (PowerShell has no $0 like sed/perl).
# Allow `${0}` (regex backref syntax). Everything else `$0` is a fail.

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path

$targets = @()
$targets += Get-ChildItem -LiteralPath (Join-Path $RepoRoot "tools") -File -Filter "*.ps1" -ErrorAction SilentlyContinue

$scratch = Join-Path $RepoRoot "_local\_scratch"
if(Test-Path -LiteralPath $scratch -PathType Container){
  $targets += Get-ChildItem -LiteralPath $scratch -File -Filter "step_*.ps1" -ErrorAction SilentlyContinue
}

$hits = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8

  # If file contains any $0 not in ${0} => fail
  if(($raw -match '\$0') -and ($raw -notmatch '\$\{0\}')){
    $hits.Add($f.FullName)
  }
}

$hits = @($hits | Sort-Object -Unique)
if($hits.Count -gt 0){
  Fail ("FAIL: NO_DOLLAR0_REPLACE`nFound `$0 usage in:`n - " + ($hits -join "`n - "))
}

"PASS: gate-no-dollar0-regex-replace"