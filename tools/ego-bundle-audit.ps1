#requires -Version 7.0
param(
  [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Resolve-RepoRoot {
  param([string]$RepoRoot)
  if ($RepoRoot -and $RepoRoot.Trim().Length -gt 0) {
    return (Resolve-Path -LiteralPath $RepoRoot).Path
  }
  try { return (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path } catch { throw "RepoRoot not found." }
}

$repo = Resolve-RepoRoot -RepoRoot $RepoRoot
$downloads = Join-Path $repo "downloads"
$bundles = Join-Path $downloads "bundles"

$findings = New-Object System.Collections.Generic.List[object]

function Add-Finding([string]$Level, [string]$Code, [string]$Message, [string]$Path) {
  $findings.Add([pscustomobject]@{
    level = $Level
    code  = $Code
    message = $Message
    path  = $Path
  })
}

if (!(Test-Path -LiteralPath $downloads)) {
  Add-Finding -Level "WARN" -Code "DOWNLOADS_MISSING" -Message "downloads/ folder missing" -Path $downloads
} else {
  if (!(Test-Path -LiteralPath $bundles)) {
    Add-Finding -Level "WARN" -Code "BUNDLES_DIR_MISSING" -Message "downloads/bundles/ folder missing" -Path $bundles
  } else {
    $zips = Get-ChildItem -LiteralPath $bundles -File -Filter "*.zip" -ErrorAction Stop
    if (@($zips).Count -eq 0) {
      Add-Finding -Level "WARN" -Code "NO_ZIPS" -Message "No bundle ZIPs found in downloads/bundles" -Path $bundles
    } else {
      foreach ($z in $zips) {
        # Tier heuristics by filename
        $tier = "UNKNOWN"
        $n = $z.Name
        if ($n -match '(?i)freebie') { $tier = "FREEBIE" }
        elseif ($n -match '(?i)\bpro\b') { $tier = "PRO" }
        elseif ($n -match '(?i)voll|full') { $tier = "VOLL" }

        if ($tier -eq "UNKNOWN") {
          Add-Finding -Level "WARN" -Code "TIER_UNKNOWN" -Message "Bundle tier not recognized from filename" -Path $z.FullName
        }

        if ($z.Length -lt 10240) {
          Add-Finding -Level "WARN" -Code "ZIP_TOO_SMALL" -Message "ZIP is unusually small (<10KB)" -Path $z.FullName
        }

        # Placeholder check (very rough)
        if ($n -match '(?i)placeholder') {
          Add-Finding -Level "WARN" -Code "PLACEHOLDER_ZIP" -Message "ZIP filename suggests placeholder" -Path $z.FullName
        }
      }
    }
  }
}

# Output object (tool output is pipeline-friendly)
[pscustomobject]@{
  repo = $repo
  bundlesDir = $bundles
  findings = $findings
}