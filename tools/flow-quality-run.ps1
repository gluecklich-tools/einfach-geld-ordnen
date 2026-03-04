#requires -Version 7.0
param(
  [switch]$ReportOnly
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ConfirmPreference="None"
$ProgressPreference="SilentlyContinue"

function Write-Utf8NoBomLF {
  param([Parameter(Mandatory)][string]$Path,[Parameter(Mandatory)][string]$Text)
  $Text = ($Text -replace "`r`n","`n" -replace "`r","`n")
  [System.IO.File]::WriteAllText($Path,$Text,[System.Text.UTF8Encoding]::new($false))
}

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$InternTools = Join-Path $ProjectRoot "_INTERN\tools"
$Gate = Join-Path $InternTools "flow-quality-gate.ps1"
if(!(Test-Path -LiteralPath $Gate -PathType Leaf)){ throw "Missing gate: $Gate" }

$root = Join-Path $RepoRoot "_local\flow_quality"
New-Item -ItemType Directory -Force -Path $root | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$runDir = Join-Path $root ("run_{0}" -f $ts)
New-Item -ItemType Directory -Force -Path $runDir | Out-Null

$logPath  = Join-Path $runDir "flow_quality_gate.log"
$csvPath  = Join-Path $runDir "flow_warns_v2.csv"
$metaPath = Join-Path $runDir "run_meta.json"

# Always create CSV with header (WARNS=0 safe)
Write-Utf8NoBomLF -Path $csvPath -Text "warn`n"

# Run gate, capture all output (including errors)
$args = @()
if($ReportOnly){ $args += "-ReportOnly" }

$lines = & pwsh -NoProfile -ExecutionPolicy Bypass -File $Gate @args 2>&1 | ForEach-Object { $_.ToString() }
$log = ($lines -join "`n")
Write-Utf8NoBomLF -Path $logPath -Text $log

# Parse warns
$warnCount = 0
$m = [regex]::Match($log, '(?m)^WARNS=(\d+)\s*$')
if($m.Success){ $warnCount = [int]$m.Groups[1].Value }

# Extract warning lines after "WARNINGS:" until "---"
$warnLines = New-Object System.Collections.Generic.List[string]
if($warnCount -gt 0){
  $in = $false
  foreach($line in ($log -split "`n")){
    if($line -match '^\s*WARNINGS:\s*$'){ $in = $true; continue }
    if($in -and $line -match '^\s*---\s*$'){ break }
    if($in){
      $t = $line.Trim()
      if($t.Length -gt 0){ $warnLines.Add($t) }
    }
  }
}

# If warns present: write CSV rows (still header + lines)
if($warnLines.Count -gt 0){
  $csv = "warn`n" + (($warnLines | ForEach-Object { $_ -replace '"','""' }) -join "`n") + "`n"
  Write-Utf8NoBomLF -Path $csvPath -Text $csv
}

$meta = @{
  ts = $ts
  run_dir = $runDir
  report_only = [bool]$ReportOnly
  warns = $warnCount
  gate = $Gate
} | ConvertTo-Json -Depth 6

Write-Utf8NoBomLF -Path $metaPath -Text $meta

"RUN_DIR=" + $runDir
"WARNS=" + $warnCount
"OK"