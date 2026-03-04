param(
  [Parameter(Mandatory=$false)]
  [string] $RepoRoot = ""
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Get-RepoRoot([string]$Maybe){
  if ($Maybe -and (Test-Path -LiteralPath $Maybe)) { return (Resolve-Path $Maybe).Path }
  return (Resolve-Path ".").Path
}

$root = Get-RepoRoot $RepoRoot

# Scan scope: tools only (where our binder issues happened)
$targets = @()
$targets += Get-ChildItem -LiteralPath (Join-Path $root "tools") -Filter "*.ps1" -File -Recurse -ErrorAction SilentlyContinue

# REPORT-ONLY gate: never block pipeline
if ($targets.Count -eq 0) {
  "PASS: gate-no-binder-traps (no tool files found)"
  exit 0
}

# Heuristics: known binder traps seen in this repo/toolchain
$hits = New-Object System.Collections.Generic.List[object]

foreach ($f in $targets) {
  $ln = 0
  foreach ($line in Get-Content -LiteralPath $f.FullName) {
    $ln++
    $t = $line.Trim()

    if (-not $t) { continue }
    if ($t.StartsWith("#")) { continue }

    # Pattern 1: -f with comma-separated args
    if ($line -match '\s-\s*f\s+.*?,') {
      $hits.Add([pscustomobject]@{ File=$f.FullName; Line=$ln; Rule="FORMAT_COMMA_ARGS"; Text=$t })
      continue
    }

    # Pattern 2: @($var).Count anywhere
    if ($line -match '@\(\s*\$[A-Za-z0-9_]+\s*\)\.Count') {
      $hits.Add([pscustomobject]@{ File=$f.FullName; Line=$ln; Rule="ARRAY_WRAP_COUNT"; Text=$t })
      continue
    }
  }
}

if ($hits.Count -gt 0) {
  $reportDir = Join-Path (Join-Path $root "_local") (Join-Path "reports" "gate_no_binder_traps")
  if (-not (Test-Path -LiteralPath $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $out = Join-Path $reportDir ("binder_traps_" + $ts + ".tsv")

  $rows = New-Object System.Collections.Generic.List[string]
  $rows.Add("File`tLine`tRule`tText")
  foreach ($h in $hits) {
    $rows.Add([string]::Format("{0}`t{1}`t{2}`t{3}", $h.File, $h.Line, $h.Rule, $h.Text))
  }

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $content = (($rows | ForEach-Object { $_ }) -join "`n") + "`n"
  [System.IO.File]::WriteAllText($out, $content, $utf8NoBom)

  # REPORT-ONLY (WARN) — do not block
  "WARN: gate-no-binder-traps found " + $hits.Count + " hit(s). See: " + $out
  exit 0
}

"PASS: gate-no-binder-traps"
exit 0