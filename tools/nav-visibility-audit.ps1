param()
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Get-Utf8TextNoBom {
  param([byte[]]$Bytes)
  if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
    $Bytes = $Bytes[3..($Bytes.Length-1)]
  }
  return [System.Text.Encoding]::UTF8.GetString($Bytes)
}
function Write-Utf8NoBom {
  param([string]$Path, [string]$Text)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}
$must = @(
  @{ key="MONEY_PAGES";  link="{{ site.baseurl }}/seiten/money-pages.html" },
  @{ key="RECHNER";     link="{{ site.baseurl }}/seiten/rechner-uebersicht.html" },
  @{ key="DER_WEG";     link="{{ site.baseurl }}/seiten/der-weg.html" },
  @{ key="FIXKOSTEN";   link="{{ site.baseurl }}/pillar/fixkosten.html" },
  @{ key="MONAT";       link="{{ site.baseurl }}/seiten/monatliche-ausgaben.html" },
  @{ key="ORDNUNG";     link="{{ site.baseurl }}/pillar/ordnung-halten.html" }
)
# "Visibility targets" (pages that should expose the flow)
$targets = @(
  "seiten/index.md",
  "pillar/index.md",
  "seiten/money-pages.md",
  "seiten/rechner-uebersicht.md",
  "seiten/downloads.md",
  "seiten/der-weg.md"
)
$root = Get-Location
$report = New-Object System.Collections.Generic.List[string]
$report.Add("NAV/VISIBILITY AUDIT - " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) | Out-Null
$report.Add("") | Out-Null
$report.Add("Must-have links:") | Out-Null
foreach ($m in $must) { $report.Add(" - " + $m.key + " => " + $m.link) | Out-Null }
$report.Add("") | Out-Null
$missingTotal = 0
$checked = 0
foreach ($rel in $targets) {
  $full = Join-Path $root $rel
  if (-not (Test-Path -LiteralPath $full)) {
    $report.Add("MISSING FILE: " + $full) | Out-Null
    $missingTotal++
    continue
  }
  $checked++
  $txt = Get-Utf8TextNoBom -Bytes ([System.IO.File]::ReadAllBytes($full))
  $report.Add("FILE: " + $full) | Out-Null
  foreach ($m in $must) {
    $has = ($txt -match [regex]::Escape($m.link))
    if ($has) { $report.Add("  OK  " + $m.key) | Out-Null }
    else      { $report.Add("  FAIL " + $m.key) | Out-Null; $missingTotal++ }
  }
  $report.Add("") | Out-Null
}
$report.Add("Summary: checkedFiles=" + $checked + " missingFlags=" + $missingTotal) | Out-Null
$outPath = Join-Path $root "tools/_nav_visibility_audit.txt"
Write-Utf8NoBom -Path $outPath -Text ($report -join "`n")
"OK: wrote tools/_nav_visibility_audit.txt"