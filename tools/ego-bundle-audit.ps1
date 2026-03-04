#requires -Version 7.0
param(
  [string]$RepoRoot = "",
  [Parameter(Mandatory)][string]$OutJson
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Resolve-RepoRoot {
  param([string]$RepoRoot)
  if ($RepoRoot -and $RepoRoot.Trim().Length -gt 0) {
    return (Resolve-Path -LiteralPath $RepoRoot).Path
  }
  try { return (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path } catch { throw "RepoRoot not found." }
}

function Write-Utf8NoBom {
  param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Text)
  $dir = Split-Path -Parent $Path
  if ($dir -and !(Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $t = $Text.Replace("`r`n","`n")
  [System.IO.File]::WriteAllText($Path, $t, $utf8)
}

$repo = Resolve-RepoRoot -RepoRoot $RepoRoot
$downloads = Join-Path $repo "downloads"
$bundles = Join-Path $downloads "bundles"

$findings = New-Object System.Collections.Generic.List[object]
function Add([string]$Level, [string]$Code, [string]$Message, [string]$Path) {
  $findings.Add([pscustomobject]@{ level=$Level; code=$Code; message=$Message; path=$Path })
}

if (!(Test-Path -LiteralPath $downloads)) {
  Add "WARN" "DOWNLOADS_MISSING" "downloads/ folder missing" $downloads
} elseif (!(Test-Path -LiteralPath $bundles)) {
  Add "WARN" "BUNDLES_DIR_MISSING" "downloads/bundles/ folder missing" $bundles
} else {
  $zips = Get-ChildItem -LiteralPath $bundles -File -Filter "*.zip" -ErrorAction Stop
  if (@($zips).Count -eq 0) {
    Add "WARN" "NO_ZIPS" "No bundle ZIPs found in downloads/bundles" $bundles
  } else {
    foreach ($z in $zips) {
      $tier = "UNKNOWN"
      $n = $z.Name
      if ($n -match '(?i)freebie') { $tier = "FREEBIE" }
      elseif ($n -match '(?i)\bpro\b') { $tier = "PRO" }
      elseif ($n -match '(?i)voll|full') { $tier = "VOLL" }

      if ($tier -eq "UNKNOWN") { Add "WARN" "TIER_UNKNOWN" "Bundle tier not recognized from filename" $z.FullName }
      if ($z.Length -lt 10240) { Add "WARN" "ZIP_TOO_SMALL" "ZIP is unusually small (<10KB)" $z.FullName }
      if ($n -match '(?i)placeholder') { Add "WARN" "PLACEHOLDER_ZIP" "ZIP filename suggests placeholder" $z.FullName }
    }
  }
}

$result = [pscustomobject]@{
  repo = $repo
  bundlesDir = $bundles
  findings = @($findings)
}

$json = $result | ConvertTo-Json -Depth 6
Write-Utf8NoBom -Path $OutJson -Text ($json + "`n")

"OK: bundle-audit wrote $OutJson"