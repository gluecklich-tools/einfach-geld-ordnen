#requires -Version 7.0
# EGO_CANON:ENTERPRISE_PREFLIGHT_BEGIN

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

& pwsh -NoProfile -File 'tools\enterprise-preflight.ps1'
# EGO_CANON:ENTERPRISE_PREFLIGHT_END

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
# EGO_NO_BIG_PASTE_RUNNER_V1
# EGO_GATE_NO_BIG_PASTE_CALL_V1
# EGO_SSOT_REFRESH_PROXY_CALL_V1
# EGO_GATE_SSOT_PROXY_CALL_V1
$RepoRoot = Split-Path -Parent $PSScriptRoot
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-ssot-proxy.ps1') -RepoRoot $RepoRoot | Out-Null
# Optional: run SSOT refresh via repo proxy if env:EGO_SSOT_ROOT is set (no hardpaths in repo)
if (-not [string]::IsNullOrWhiteSpace($env:EGO_SSOT_ROOT)) {
  $proxy = Join-Path $PSScriptRoot 'ssot-refresh-proxy.ps1'
  if (-not (Test-Path -LiteralPath $proxy)) { throw ("Missing SSOT proxy tool: " + $proxy) }
  pwsh -NoProfile -File $proxy | Out-Null
}
$RepoRoot = Split-Path -Parent $PSScriptRoot
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-no-big-paste.ps1') -RepoRoot $RepoRoot | Out-Null
# LAW: Never paste large scripts into the console. Use file-based tools + pwsh -NoProfile -File.
# If you see truncated input / ParserError: STOP and rerun from a fresh session.
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if ($IsWindows) { try { chcp 65001 | Out-Null } catch {} }
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
if (!(Test-Path -LiteralPath $report)) { Write-Host ("WARN: Missing weiter report (CI ok): " + $report) }
$txt = [IO.File]::ReadAllText($report, [Text.UTF8Encoding]::new($false))

function Get-MetricInt {
  param([string]$Content, [string]$Label)

  $patterns = @(
    ('(?m)^\|\s*' + [regex]::Escape($Label) + '\s*\|\s*(\d+)\s*\|'),
    ('(?m)^\s*' + [regex]::Escape($Label) + '\s*[:=]\s*(\d+)\s*$'),
    ('(?m)^\s*-\s*' + [regex]::Escape($Label) + '\s*[:=]\s*(\d+)\s*$')
  )

  foreach ($pattern in $patterns) {
    $m = [regex]::Match($Content, $pattern)
    if ($m.Success) {
      return [int]$m.Groups[1].Value
    }
  }

  $tableRows = @()
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line -notmatch '^\|\s*[^|]+\|\s*\d+\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*\d+\s*\|$') { continue }
    if ($line -match '^\|\s*Datei\s*\|') { continue }
    if ($line -match '^\|\s*---') { continue }

    $parts = @($line.Trim('|').Split('|') | ForEach-Object { $_.Trim() })
    if ($parts.Count -lt 5) { continue }

    $weiter = 0
    $mdLinks = 0

    if (-not [int]::TryParse($parts[1], [ref]$weiter)) { continue }
    if (-not [int]::TryParse($parts[2], [ref]$mdLinks)) { continue }

    $tableRows += [pscustomobject]@{
      Datei   = $parts[0]
      Weiter  = $weiter
      MdLinks = $mdLinks
    }
  }

  if ($tableRows.Count -gt 0) {
    switch ($Label) {
      'Missing ## Weiter' {
        return @($tableRows | Where-Object { $_.Weiter -eq 0 }).Count
      }
      'HasWeiter + MdLinks!=3' {
        return @($tableRows | Where-Object { $_.Weiter -gt 0 -and $_.MdLinks -ne 3 }).Count
      }
      'HasWeiter + MdLinks=0' {
        return @($tableRows | Where-Object { $_.Weiter -gt 0 -and $_.MdLinks -eq 0 }).Count
      }
    }
  }

  throw ("Metric not found in report: " + $Label)
}

$missing = Get-MetricInt -Content $txt -Label "Missing ## Weiter"
$not3    = Get-MetricInt -Content $txt -Label "HasWeiter + MdLinks!=3"
$zero    = Get-MetricInt -Content $txt -Label "HasWeiter + MdLinks=0"

if ($missing -ne 0 -or $not3 -ne 0 -or $zero -ne 0) {
  throw ("FAIL: Weiter gate not clean (Missing={0} Not3={1} Zero={2}). See {3}" -f @($missing,$not3,$zero,$report))
}

"PASS: Weiter Allowlist Gate ok (seiten+pilla)."
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-weiter-ux-policy.ps1')
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-frontmatter-nav.ps1')
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-thema-alias-map.ps1') -WithAsciiCheck -WithDupCheck

# Mojibake gate (encoding/garbled chars)
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-no-mojibake.ps1')
pwsh -NoProfile -File (Join-Path $PSScriptRoot 'gate-no-emoji.ps1')
"PASS: ego-run completed (required gates OK)."

# === EGO_AUTO_FINDINGS_UPSERT_HOOK_V1 BEGIN ===
# AUTO: Findings -> SSOT Docs (mandatory)
$ssot=$env:EGO_SSOT_ROOT
if([string]::IsNullOrWhiteSpace($ssot)){
  $ssot=$env:EGO_SSOT_ROOT
}
if([string]::IsNullOrWhiteSpace($ssot)){
  throw "STOP: EGO_SSOT_ROOT not set. Set env var to SSOT root (example: <PROJECT>/INTERN_REDACTED/governance)."
}
if(!(Test-Path -LiteralPath $ssot)){
  throw ("STOP: SSOT root missing: " + $ssot)
}
$internRoot = Split-Path -Parent $ssot
$tool = Join-Path -Path (Join-Path -Path $internRoot -ChildPath 'tools') -ChildPath 'ego-findings-upsert.ps1'
if(!(Test-Path -LiteralPath $tool)){ throw "STOP: findings tool missing: $tool" }
& pwsh -NoProfile -ExecutionPolicy Bypass -File $tool -SsotRoot $ssot

# Marker-Gate
$marker='<!-- EGO_FINDINGS_FLOWPLAN_TSV_V1 BEGIN -->'
$learn = Join-Path -Path $ssot -ChildPath 'LEARNINGS_INTERNAL.md'
if(!(Select-String -LiteralPath $learn -SimpleMatch -Pattern $marker -Quiet)){
  throw "STOP: findings marker missing in LEARNINGS_INTERNAL.md after upsert"
}
# === EGO_AUTO_FINDINGS_UPSERT_HOOK_V1 END ===
