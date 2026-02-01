param(
  [Parameter(Mandatory=$true)]
  [string]$Result,
  [Parameter(Mandatory=$true)]
  [string]$Scope,
  [Parameter(Mandatory=$true)]
  [string]$MonthDir
)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
Set-Location -LiteralPath $root
function Write-TextIfChanged {
  param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$Text)
# --- EOL_NORMALIZE_TEXT_START ---
# Force LF-only output for all generated text files (prevents CRLF warnings)
if ($null -ne $Text) {
  $Text = $Text -replace "`r`n", "`n"
  $Text = $Text -replace "`r", "`n"
}
# --- EOL_NORMALIZE_TEXT_END ---

  $enc = New-Object System.Text.UTF8Encoding($false)
  $old = $null
  if (Test-Path -LiteralPath $Path) { $old = [System.IO.File]::ReadAllText($Path, $enc) }
  if ($old -ne $Text) { [System.IO.File]::WriteAllText($Path, $Text, $enc); return $true }
  return $false
}
function Upsert-MarkerBlock {
  param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$Start,[Parameter(Mandatory=$true)][string]$End,[Parameter(Mandatory=$true)][string]$Block)
  $enc = New-Object System.Text.UTF8Encoding($false)
  $raw = [System.IO.File]::ReadAllText($Path, $enc)
  $si = $raw.IndexOf($Start, [System.StringComparison]::Ordinal)
  $ei = $raw.IndexOf($End,   [System.StringComparison]::Ordinal)
  if (($si -ge 0) -and ($ei -gt $si)) {
    $before = $raw.Substring(0, $si)
    $after  = $raw.Substring($ei + $End.Length)
    $newTxt = $before + $Block + $after
  } else {
    $trim = $raw.TrimEnd()
    $newTxt = $trim + "`r`n`r`n" + $Block + "`r`n"
  }
  if ($newTxt -ne $raw) { [System.IO.File]::WriteAllText($Path, $newTxt, $enc); return $true }
  return $false
}
if (-not (Test-Path -LiteralPath $MonthDir)) { New-Item -ItemType Directory -Force -Path $MonthDir | Out-Null }
$now = Get-Date
$dt = $now.ToString("yyyy-MM-dd HH:mm:ss zzz")
$month = $now.ToString("yyyy-MM")
$base = "assets/audit/" + $month
$runlog = $env:EGO_RUNLOG_PATH
if ($runlog -and (Test-Path -LiteralPath $runlog)) {
  $dst = Join-Path $MonthDir ("runlog_" + $now.ToString("yyyy-MM-dd_HHmmss") + ".txt")
  Copy-Item -LiteralPath $runlog -Destination $dst -Force
}
$sum = @()
$sum += "# EGO Audit"
$sum += ""
$sum += ("result: " + $Result)
$sum += ("scope: " + $Scope)
$sum += ("date: " + $dt)
$sum += ""
$sum += "evidence:"
$sum += ("- folder: " + $base + "/")
$sum += ("- checksums: " + $base + "/checksums.txt")
$sumTxt = ($sum -join "`r`n") + "`r`n"
Write-TextIfChanged -Path (Join-Path $MonthDir 'summary.md') -Text $sumTxt | Out-Null
$auditPage = Join-Path $root 'seiten\audit.md'
if (Test-Path -LiteralPath $auditPage) {
  $start = '<!-- AUDIT_L2_STATUS_START -->'
  $end   = '<!-- AUDIT_L2_STATUS_END -->'
  $block = @()
  $block += '<!-- AUDIT_L2_STATUS_START -->'
  $block += "### Letzter Audit"
  $block += ""
  $block += ("- Datum: " + $dt)
  $block += ("- Ergebnis: **" + $Result + "**")
  $block += ("- Scope: " + $Scope)
  $block += ("- Evidence: {{ site.baseurl }}/" + $base + "/")
  $block += ("- Checksums: {{ site.baseurl }}/" + $base + "/checksums.txt")
  $block += '<!-- AUDIT_L2_STATUS_END -->'
  $blk = ($block -join "`r`n") + "`r`n"
  Upsert-MarkerBlock -Path $auditPage -Start $start -End $end -Block $blk | Out-Null
}
"AUDIT_PACK_OK"