#requires -Version 7.0
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { chcp 65001 > $null } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# --- Resolve repo root ---
$Repo = $null
try { $t = (git rev-parse --show-toplevel 2>$null); if($t){ $Repo = $t.Trim() } } catch {}
if(-not $Repo){ $Repo = (Resolve-Path -LiteralPath ".").Path }
$Repo = (Resolve-Path -LiteralPath $Repo).Path

# --- Resolve _INTERN governance/reports ---
$GovCandidates = @(
  "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance",
  (Join-Path (Split-Path -Parent $Repo) "_INTERN\governance"),
  (Join-Path $Repo "_INTERN\governance")
)
$Gov = $null
foreach($c in $GovCandidates){ if($c -and (Test-Path -LiteralPath $c)){ $Gov = (Resolve-Path -LiteralPath $c).Path; break } }
if(-not $Gov){ throw "STOP: _INTERN\governance not found." }

$RepCandidates = @(
  "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\reports",
  (Join-Path (Split-Path -Parent $Gov) "reports"),
  (Join-Path (Split-Path -Parent $Repo) "_INTERN\reports"),
  (Join-Path $Repo "_INTERN\reports")
)
$Rep = $null
foreach($c in $RepCandidates){ if($c -and (Test-Path -LiteralPath $c)){ $Rep = (Resolve-Path -LiteralPath $c).Path; break } }
if(-not $Rep){ $Rep = Join-Path (Split-Path -Parent $Gov) "reports"; New-Item -ItemType Directory -Path $Rep -Force | Out-Null; $Rep = (Resolve-Path -LiteralPath $Rep).Path }

$NL = "`n"
$ts = (Get-Date).ToString("yyyyMMdd_HHmmss")
$reportPath = Join-Path $Rep ("TOOLS_REGISTRY_{0}.md" -f $ts)

# --- Collect tools ---
$toolsDir = Join-Path $Repo "tools"
if(-not (Test-Path -LiteralPath $toolsDir)){ throw "STOP: tools/ not found in repo." }
$files = @(Get-ChildItem -LiteralPath $toolsDir -File -ErrorAction Stop | Sort-Object Name)

# --- Categorize (simple, deterministic) ---
$groups = [ordered]@{}
$groups["01_RUNNERS"] = New-Object System.Collections.Generic.List[object]
$groups["02_GATES"] = New-Object System.Collections.Generic.List[object]
$groups["03_SCANS_AUDITS"] = New-Object System.Collections.Generic.List[object]
$groups["04_FIX_APPLY"] = New-Object System.Collections.Generic.List[object]
$groups["05_PACKS"] = New-Object System.Collections.Generic.List[object]
$groups["99_MISC"] = New-Object System.Collections.Generic.List[object]

$runnerNames = @("ego-super-run.ps1","ego-law-run.ps1","ego-law-run-safe.ps1","ego-run.ps1","tools-readonly-wrapper.ps1")

foreach($f in $files){
  $n = $f.Name.ToLowerInvariant()
  $isPs1 = $n.EndsWith(".ps1")
  $isTxt = $n.EndsWith(".txt")
  if($isTxt){ $groups["99_MISC"].Add($f) | Out-Null; continue }
  if(-not $isPs1){ $groups["99_MISC"].Add($f) | Out-Null; continue }
  if($runnerNames -contains $f.Name){ $groups["01_RUNNERS"].Add($f) | Out-Null; continue }
  if($n.StartsWith("gate_") -or $n.Contains("-gate") -or $n.Contains("gate_")){ $groups["02_GATES"].Add($f) | Out-Null; continue }
  if($n.Contains("scan") -or $n.Contains("audit") -or $n.Contains("checksums") -or $n.EndsWith("-audit.ps1")){ $groups["03_SCANS_AUDITS"].Add($f) | Out-Null; continue }
  if($n.Contains("fix") -or $n.Contains("patch") -or $n.StartsWith("apply-") -or $n.Contains("strip") -or $n.Contains("leading")){ $groups["04_FIX_APPLY"].Add($f) | Out-Null; continue }
  if($n.Contains("pack") -or $n.Contains("export") -or $n.Contains("backup")){ $groups["05_PACKS"].Add($f) | Out-Null; continue }
  $groups["99_MISC"].Add($f) | Out-Null
}

# --- Build markdown report ---
$md = New-Object System.Collections.Generic.List[string]
$md.Add("# Tools Registry (Repo/tools)") | Out-Null
$md.Add(("Generated: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))) | Out-Null
$md.Add(("Repo: {0}" -f $Repo)) | Out-Null
$md.Add("") | Out-Null
$md.Add("## Canonical usage order (project law)") | Out-Null
$md.Add("1) APPLY (idempotent, UTF-8 no BOM, binaersicher)") | Out-Null
$md.Add("2) GATES (must PASS)") | Out-Null
$md.Add("3) COMMIT/PUSH only if changed") | Out-Null
$md.Add("4) LIVE-HEAD-200 smoke") | Out-Null
$md.Add("") | Out-Null

$catOrder = @("01_RUNNERS","02_GATES","03_SCANS_AUDITS","04_FIX_APPLY","05_PACKS","99_MISC")
foreach($cat in $catOrder){
  $list = $groups[$cat]
  if(-not $list -or $list.Count -eq 0){ continue }
  $title = switch($cat){
    "01_RUNNERS" { "Runners (entry points)" }
    "02_GATES" { "Gates (must PASS)" }
    "03_SCANS_AUDITS" { "Scans / Audits (evidence)" }
    "04_FIX_APPLY" { "Fix / Apply (write changes)" }
    "05_PACKS" { "Packs / Exports (reports)" }
    default { "Misc" }
  }
  $md.Add(("## {0}" -f $title)) | Out-Null
  $md.Add("") | Out-Null
  foreach($f in $list){
    $rel = ("tools/{0}" -f $f.Name)
    $md.Add(("- {0} ({1} bytes)  lastwrite: {2}" -f $rel, $f.Length, $f.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))) | Out-Null
  }
  $md.Add("") | Out-Null
}

[IO.File]::WriteAllText($reportPath, ($md.ToArray() -join $NL) + $NL, [System.Text.UTF8Encoding]::new($false))
if(-not (Test-Path -LiteralPath $reportPath)){ throw ("STOP: report write failed: {0}" -f $reportPath) }

# --- Patch SSOT files with markers (No-Guess law + registry link) ---
$ssotFiles = @("BOOTSTRAP_INTERNAL.md","GOVERNANCE_INTERNAL.md","QA_GATE_INTERNAL.md","LEARNINGS_INTERNAL.md","ROADMAP_INTERNAL.md")
$archiveDir = Join-Path $Gov "_archive"
if(-not (Test-Path -LiteralPath $archiveDir)){ New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null }
$start = "<!-- TOOLS_REGISTRY_START -->"
$end   = "<!-- TOOLS_REGISTRY_END -->"

$patchLines = @(
  $start,
  "",
  "## Gesetz: No-Guess Rule (Evidenzpflicht)",
  "",
  "- Bevor Aenderungen/Fixes vorgeschlagen oder geliefert werden, MUSS Evidenz vorliegen:",
  "  - Entweder betroffene Datei-Inhalte (Full-Swap) hier im Chat, ODER",
  "  - Output aus Scan/Gate mit Datei + Zeile + Match.",
  "- Keine Aenderungen auf Verdacht. Keine Vermutungen.",
  "- param() gehoert nur in Script-Dateien, nie in die Konsole.",
  "",
  "## Tools Registry (Single Source of Truth)",
  "",
  ("- Aktuelle Registry (auto-generated): {0}" -f $reportPath),
  "- Die Registry ist die offizielle Reihenfolge/Kategorisierung fuer Repo/tools.",
  "",
  $end
)
$patch = ($patchLines -join $NL)

$updated = @()
foreach($name in $ssotFiles){
  $path = Join-Path $Gov $name
  if(-not (Test-Path -LiteralPath $path)){ continue }
  $orig = [IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
  $backup = Join-Path $archiveDir ("{0}.{1}.bak" -f $name, $ts)
  [IO.File]::WriteAllText($backup, $orig, [System.Text.UTF8Encoding]::new($false))
  $norm = $orig -replace "`r`n", "`n"
  $patchN = $patch -replace "`r`n", "`n"
  if($norm.Contains($start) -and $norm.Contains($end)){
    $rx = [regex]::new("(?s)\Q$start\E.*?\Q$end\E")
    $norm2 = $rx.Replace($norm, $patchN)
  } else {
    $norm2 = ($norm.TrimEnd() + "`n`n" + $patchN + "`n")
  }
  $out = $norm2 -replace "`n", "`r`n"
  [IO.File]::WriteAllText($path, $out, [System.Text.UTF8Encoding]::new($false))
  $updated += $name
}

# --- Try ssot-refresh.ps1 (best effort) ---
$refresh = $null
$refreshCandidates = @(
  (Join-Path (Split-Path -Parent $Gov) "tools\ssot-refresh.ps1"),
  "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools\ssot-refresh.ps1",
  (Join-Path $Repo "tools\ssot-refresh.ps1"),
  (Join-Path $Repo "_INTERN\tools\ssot-refresh.ps1")
)
foreach($c in $refreshCandidates){ if($c -and (Test-Path -LiteralPath $c)){ $refresh = $c; break } }

"OK: Wrote report = " + $reportPath
if($updated.Count -gt 0){ "OK: Patched SSOT = " + ($updated -join ", ") } else { "WARN: No SSOT files patched (missing?)" }
if($refresh){ "OK: Running ssot-refresh = " + $refresh; & pwsh -NoProfile -File $refresh } else { "WARN: ssot-refresh.ps1 not found (skipped)" }
