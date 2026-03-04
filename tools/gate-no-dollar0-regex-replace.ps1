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
# - Always scan tools
# - Optionally scan ONLY the current step (when -StepPath is provided)
# - NEVER self-flag this gate file

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$SelfPath = (Resolve-Path -LiteralPath $PSCommandPath).Path

$targets = @()
$targets += Get-ChildItem -LiteralPath (Join-Path $RepoRoot "tools") -File -Filter "*.ps1" -ErrorAction SilentlyContinue

if(-not [string]::IsNullOrWhiteSpace($StepPath)){
  $sp = (Resolve-Path -LiteralPath $StepPath).Path
  $targets += Get-Item -LiteralPath $sp -ErrorAction Stop
}

$hits = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $fp = (Resolve-Path -LiteralPath $f.FullName).Path
  if($fp -eq $SelfPath){ continue } # self-exclude

  $raw = Get-Content -LiteralPath $fp -Raw -Encoding UTF8

  # Detect literal $0 usage but allow ${0}
  if(($raw -match '\$0') -and ($raw -notmatch '\$\{0\}')){
    $hits.Add($fp)
  }
}

$hits = @($hits | Sort-Object -Unique)
if($hits.Count -gt 0){
  Fail ("FAIL: NO_DOLLAR0_REPLACE Found `$0 usage in:`n - " + ($hits -join "`n - "))
}

"PASS: gate-no-dollar0-regex-replace"