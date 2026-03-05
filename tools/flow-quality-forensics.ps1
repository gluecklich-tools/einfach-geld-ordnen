param(
  [switch]$ReportOnly
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }
function New-Dir([string]$p){ if ($p -and -not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null } }

function Write-Utf8NoBomLf {
  param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$Text)
  $dir = Split-Path -Parent $Path
  New-Dir $dir
  $t = $Text -replace "
","
"
  $t = $t -replace "
","
"
  if (-not $t.EndsWith("
")) { $t += "
" }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $t, $enc)
}

$repo = (& git rev-parse --show-toplevel 2>$null)
if (-not $repo) { Fail "RepoRoot not found" }
$repo = (Resolve-Path -LiteralPath $repo).Path

$runDirBase = Join-Path $repo "_local\_reports"
New-Dir $runDirBase
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$runDir = Join-Path $runDirBase ("scan_flow_quality_output_forensics_{0}" -f $ts)
New-Dir $runDir

$log = Join-Path $runDir "flow_quality_gate_reportonly.log"
$inv = Join-Path $runDir "flow_quality_run_inventory.txt"

$gate = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools\flow-quality-gate.ps1"
if (-not (Test-Path -LiteralPath $gate)) { Fail "Gate fehlt: $gate" }

# run gate
if ($ReportOnly) {
  $out = & pwsh -NoProfile -ExecutionPolicy Bypass -File $gate -ReportOnly 2>&1 | Out-String
} else {
  $out = & pwsh -NoProfile -ExecutionPolicy Bypass -File $gate 2>&1 | Out-String
}
Write-Utf8NoBomLf -Path $log -Text $out

# latest run dir
$flowBase = Join-Path $repo "_local\flow_quality"
if (-not (Test-Path -LiteralPath $flowBase)) { Fail "Fehlt: $flowBase" }

$latestRun = Get-ChildItem -LiteralPath $flowBase -Directory |
  Where-Object { $_.Name -like "run_*" } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1
if (-not $latestRun) { Fail "Kein run_* unter: $flowBase" }

# normalize csv AFTER gate run (hard)
$csv = Join-Path $latestRun.FullName "flow_warns_v2.csv"
$bytesPre = -1
$bytesPost = -1
if (Test-Path -LiteralPath $csv) {
  $bytesPre = (Get-Item -LiteralPath $csv).Length
  if ($bytesPre -lt 20) {
    $header = "kind,reason,from_file,to_file,from_url,to_url,href,line
"
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($csv, $header, $enc)
  }
  $bytesPost = (Get-Item -LiteralPath $csv).Length
}

# inventory
$files = Get-ChildItem -LiteralPath $latestRun.FullName -Recurse -File | Sort-Object Length -Descending
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine(("LATEST_RUN: {0}" -f $latestRun.FullName))
[void]$sb.AppendLine(("CSV_BYTES_PRE: {0}" -f $bytesPre))
[void]$sb.AppendLine(("CSV_BYTES_POST:{0}" -f $bytesPost))
[void]$sb.AppendLine("")
[void]$sb.AppendLine("FILES (path | bytes):")
foreach ($f in $files) { [void]$sb.AppendLine(("{0} | {1}" -f $f.FullName, $f.Length)) }
Write-Utf8NoBomLf -Path $inv -Text ($sb.ToString())

"OK (SCAN ONLY)."
("RUN_DIR: {0}" -f $runDir)
("LOG: {0}" -f $log)
("INV: {0}" -f $inv)
("LATEST_RUN: {0}" -f $latestRun.FullName)
("CSV_BYTES_PRE: {0}" -f $bytesPre)
("CSV_BYTES_POST:{0}" -f $bytesPost)
