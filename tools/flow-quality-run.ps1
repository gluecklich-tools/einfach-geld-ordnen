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
  # Normalize line endings WITHOUT regex
  $Text = $Text.Replace("`r`n","`n").Replace("`r","`n")
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

# Parse WARNS without regex
$warnCount = 0
foreach($line in $lines){
  $t = $line.Trim()
  if($t.StartsWith("WARNS=")){
    $n = $t.Substring(6)
    $tmp = 0
    if([int]::TryParse($n, [ref]$tmp)){ $warnCount = $tmp }
    break
  }
}

# Extract warning lines between "WARNINGS:" and "---"
$warnLines = New-Object System.Collections.Generic.List[string]
if($warnCount -gt 0){
  $in = $false
  foreach($line in $lines){
    $t = $line.Trim()
    if((-not $in) -and ($t -eq "WARNINGS:")){ $in = $true; continue }
    if($in -and ($t -eq "---")){ break }
    if($in -and $t.Length -gt 0){ $warnLines.Add($t) }
  }
}

# If warns present: write CSV rows (header + each warn line)
if($warnLines.Count -gt 0){
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine("warn")
  foreach($w in $warnLines){
    # CSV-safe for quotes (string replace, not regex)
    $x = $w.Replace('"','""')
    [void]$sb.AppendLine($x)
  }
  Write-Utf8NoBomLF -Path $csvPath -Text $sb.ToString()
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