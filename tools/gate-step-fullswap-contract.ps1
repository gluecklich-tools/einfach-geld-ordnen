#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$scratch = Join-Path $RepoRoot "_local\_scratch"

if(-not (Test-Path -LiteralPath $scratch -PathType Container)){
  "PASS: gate-step-fullswap-contract (no scratch)"
  exit 0
}

$steps = Get-ChildItem -LiteralPath $scratch -File -Filter "step_*.ps1" -ErrorAction SilentlyContinue
$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $steps){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8

  # Must contain allowlist literal assignment
  $hasAllow = $raw -match '(?ms)\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\(\s*.*?\s*\)'
  if(-not $hasAllow){ $bad.Add("MISSING_ALLOWLIST: " + $f.FullName); continue }

  # Must include marker (forces “fullswap discipline” inside file)
  if($raw -notmatch 'FULLSWAP_FILE_CONTRACT'){
    $bad.Add("MISSING_CONTRACT_MARKER: " + $f.FullName)
  }
}

if($bad.Count -gt 0){
  Fail ("FAIL: STEP_FULLSWAP_CONTRACT`n" + ($bad -join "`n"))
}

"PASS: gate-step-fullswap-contract"