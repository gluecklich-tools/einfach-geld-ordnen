#requires -Version 7.0
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { chcp 65001 > $null } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# PUBLIC-SAFE tool: generates a registry report for Repo/tools only.
# - No hardpaths
# - No INTERN_REDACTED references
# - No SSOT marker strings

# Resolve repo root
$Repo = $null
try { $t = (git rev-parse --show-toplevel 2>$null); if($t){ $Repo = $t.Trim() } } catch {}
if(-not $Repo){ $Repo = (Resolve-Path -LiteralPath ".").Path }
$Repo = (Resolve-Path -LiteralPath $Repo).Path

$ToolsDir = Join-Path $Repo "tools"
if(-not (Test-Path -LiteralPath $ToolsDir)){ throw "STOP: tools/ not found in repo root." }

# Output goes into public repo (assets/audit/runs)
$OutDir = Join-Path (Join-Path (Join-Path $Repo "assets") "audit") "runs"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$ts = "{0}_{1}" -f (Get-Date).ToString("yyyyMMdd_HHmmss_fff"), (Get-Random -Minimum 1000 -Maximum 9999)
$reportPath = Join-Path $OutDir ("TOOLS_REGISTRY_{0}.md" -f $ts)

function Get-ToolCategory {
  param([string]$Name)
  $n = $Name.ToLowerInvariant()
  if($n -match '^(ego-.*run|ego-run|ego-super-run|ego-law-run|ego-law-run-safe)\.ps1){ return "01_RUNNERS" }){ return "01_RUNNERS" }
  if($n -match '^(gate_|.*-gate)\.ps1){ return "02_GATES" }){ return "02_GATES" }
  if($n -match "(scan|audit|report|htmlproofer|linkcheck)"){ return "03_SCANS_AUDITS" }
  if($n -match "(fix|apply|patch|repair|normalize|refresh)"){ return "04_FIX_APPLY" }
  if($n -match "(pack|export|bundle|zip|release)"){ return "05_PACKS" }
  return "99_MISC"
}

$files = @(Get-ChildItem -LiteralPath $ToolsDir -File -Filter "*.ps1" -ErrorAction Stop | Sort-Object Name)
if($files.Count -eq 0){ throw "STOP: no tools/*.ps1 found." }

$groups = @{}
foreach($f in $files){
  $cat = Get-ToolCategory -Name $f.Name
  if(-not $groups.ContainsKey($cat)){ $groups[$cat] = @() }
  $groups[$cat] += $f
}

$md = New-Object System.Collections.Generic.List[string]
$md.Add("# Tools Registry (Repo/tools)") | Out-Null
$md.Add(("Generated: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))) | Out-Null
$md.Add(("Repo: {0}" -f $Repo)) | Out-Null
$md.Add("") | Out-Null
$md.Add("## Canonical usage order (project law)") | Out-Null
$md.Add("1) APPLY (idempotent, UTF-8 no BOM, binary-safe)") | Out-Null
$md.Add("2) GATES (must PASS)") | Out-Null
$md.Add("3) COMMIT/PUSH only if changed") | Out-Null
$md.Add("4) LIVE-HEAD-200 smoke") | Out-Null
$md.Add("") | Out-Null

$catOrder = @("01_RUNNERS","02_GATES","03_SCANS_AUDITS","04_FIX_APPLY","05_PACKS","99_MISC")
foreach($cat in $catOrder){
  $list = $groups[$cat]
  if(-not $list -or $list.Count -eq 0){ continue }
  $title = switch($cat){
    "01_RUNNERS"      { "Runners (entry points)" }
    "02_GATES"        { "Gates (must PASS)" }
    "03_SCANS_AUDITS" { "Scans / Audits (evidence)" }
    "04_FIX_APPLY"    { "Fix / Apply (write changes)" }
    "05_PACKS"        { "Packs / Exports (reports)" }
    default           { "Misc" }
  }
  $md.Add(("## {0}" -f $title)) | Out-Null
  $md.Add("") | Out-Null
  foreach($f in $list){
    $rel = ("tools/{0}" -f $f.Name)
    $md.Add(("- {0} ({1} bytes)  lastwrite: {2}" -f $rel, $f.Length, $f.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))) | Out-Null
  }
  $md.Add("") | Out-Null
}

$outText = ($md.ToArray() -join [Environment]::NewLine) + [Environment]::NewLine
[IO.File]::WriteAllText($reportPath, $outText, [System.Text.UTF8Encoding]::new($false))
if(-not (Test-Path -LiteralPath $reportPath)){ throw ("STOP: report write failed: {0}" -f $reportPath) }
"OK: Wrote report = " + $reportPath
