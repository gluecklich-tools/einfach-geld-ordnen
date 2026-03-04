#requires -Version 7.0
param(
  [string]$StepPath = ""
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

# P0 gate: block "$0" misuse (PowerShell has no $0 like sed/perl).
# IMPORTANT: do NOT scan scratch history globally. Always scan tools; optionally scan only the current step.

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path

$targets = @()
$targets += Get-ChildItem -LiteralPath (Join-Path $RepoRoot "tools") -File -Filter "*.ps1" -ErrorAction SilentlyContinue

if(-not [string]::IsNullOrWhiteSpace($StepPath)){
  $sp = (Resolve-Path -LiteralPath $StepPath).Path
  $targets += Get-Item -LiteralPath $sp -ErrorAction Stop
}

$hits = New-Object System.Collections.Generic.List[string]
foreach($f in $targets){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  if(($raw -match '\$0') -and ($raw -notmatch '\$\{0\}')){
    $hits.Add($f.FullName)
  }
}

$hits = @($hits | Sort-Object -Unique)
if($hits.Count -gt 0){
  Fail ("FAIL: NO_DOLLAR0_REPLACE`nFound `$0 usage in:`n - " + ($hits -join "`n - "))
}

"PASS: gate-no-dollar0-regex-replace"