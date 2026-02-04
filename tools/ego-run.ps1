#requires -Version 7.0
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# Repo root = parent of /tools
$repo = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $repo

# Existing gates
& "$PSScriptRoot\gate_no_local_links.ps1"
& "$PSScriptRoot\gate_tools_no_local_markers.ps1"

$gate = Join-Path $repo "tools\gate_download_hubs_strict.ps1"
if (-not (Test-Path -LiteralPath $gate)) { throw ("Missing required gate: " + $gate) }
& $gate

# New gate: Weiter allowlist (seiten+pilla) via safe-run
$safe = Join-Path $PSScriptRoot "safe-run.ps1"
if (-not (Test-Path -LiteralPath $safe)) { throw ("Missing required tool: " + $safe) }

$null = & pwsh -NoProfile -File $safe -Task weiter-scan

$report = Join-Path $repo "assets\audit\weiter_links\weiter_scan_report.md"
if (-not (Test-Path -LiteralPath $report)) { throw ("Missing weiter report: " + $report) }

$txt = [IO.File]::ReadAllText($report, [Text.UTF8Encoding]::new($false))

function Get-MetricInt {
  param([string]$Content, [string]$Label)
  $m = [regex]::Match($Content, '(?m)^\|\s*' + [regex]::Escape($Label) + '\s*\|\s*(\d+)\s*\|')
  if (-not $m.Success) { throw ("Metric not found in report: " + $Label) }
  [int]$m.Groups[1].Value
}

$missing = Get-MetricInt -Content $txt -Label "Missing ## Weiter"
$not3    = Get-MetricInt -Content $txt -Label "HasWeiter + MdLinks!=3"
$zero    = Get-MetricInt -Content $txt -Label "HasWeiter + MdLinks=0"

if ($missing -ne 0 -or $not3 -ne 0 -or $zero -ne 0) {
  throw ("FAIL: Weiter gate not clean (Missing={0} Not3={1} Zero={2}). See {3}" -f $missing,$not3,$zero,$report)
}

"PASS: Weiter Allowlist Gate ok (seiten+pilla)."
"PASS: ego-run completed (required gates OK)."