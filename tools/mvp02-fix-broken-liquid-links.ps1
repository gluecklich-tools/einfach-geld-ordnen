param([switch]$Apply)
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
# Map known "Mini-Rechner" labels to real pages in your repo (from your file list)
$map = @(
  @{ rx = '(?i)\b50-30-20\b';             target = '{{ site.baseurl }}/seiten/budget-50-30-20-rechner.html' },
  @{ rx = '(?i)\b(schneeball|snowball)\b'; target = '{{ site.baseurl }}/seiten/snowball-rechner.html' },
  @{ rx = '(?i)\b(lawine)\b';              target = '{{ site.baseurl }}/seiten/lawine-rechner.html' },
  @{ rx = '(?i)\b(jahreskosten)\b';        target = '{{ site.baseurl }}/seiten/jahreskosten-rechner.html' },
  @{ rx = '(?i)\b(notgroschen)\b';         target = '{{ site.baseurl }}/seiten/notgroschen-rechner.html' },
  @{ rx = '(?i)\b(spielraum)\b';           target = '{{ site.baseurl }}/seiten/spielraum-rechner.html' },
  @{ rx = '(?i)\b(fixkosten)\b';           target = '{{ site.baseurl }}/seiten/fixkosten-rechner.html' }
)
$files = @()
$files += Get-ChildItem -LiteralPath (Join-Path (Get-Location) "seiten") -Filter "*.md" -File -ErrorAction SilentlyContinue
$files += Get-ChildItem -LiteralPath (Join-Path (Get-Location) "pillar") -Filter "*.md" -File -ErrorAction SilentlyContinue
if ($files.Count -eq 0) { throw "No md files found." }
$hits = 0
$written = 0
$log = New-Object System.Collections.Generic.List[string]
foreach ($f in $files | Sort-Object FullName) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $text  = Get-Utf8TextNoBom -Bytes $bytes
  $orig  = $text
  # Fix pattern: [label]({{)
  $pattern = '\[(?<label>[^\]]+)\]\(\{\{\)\)'
  $text = [regex]::Replace($text, $pattern, {
    param($m)
    $label = $m.Groups["label"].Value
    $hits++
    $target = $null
    foreach ($r in $map) {
      if ([regex]::IsMatch($label, $r.rx)) { $target = $r.target; break }
    }
    if ($null -eq $target) {
      $log.Add(($f.FullName + " :: UNMAPPED label=" + $label)) | Out-Null
      return $m.Value
    }
    $log.Add(($f.FullName + " :: FIX label=" + $label + " -> " + $target)) | Out-Null
    return "[" + $label + "](" + $target + ")"
  })
  if ($text -ne $orig -and $Apply) {
    Write-Utf8NoBom -Path $f.FullName -Text $text
    $written++
  }
}
$reportPath = Join-Path (Get-Location) "tools/_mvp02_fix_broken_links.txt"
Write-Utf8NoBom -Path $reportPath -Text ("Hits: " + $hits + "`nWrittenFiles: " + $written + "`nApply: " + $Apply.IsPresent + "`n`n" + ($log -join "`n"))
"OK: wrote tools/_mvp02_fix_broken_links.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }