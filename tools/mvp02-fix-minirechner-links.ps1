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
function Resolve-Target {
  param([string]$Label)
  # Map to existing pages (based on your repo file list)
  if ($Label -match '(?i)\b50-30-20\b')              { return "{{ site.baseurl }}/seiten/budget-50-30-20-rechner.html" }
  if ($Label -match '(?i)\b(schneeball|snowball)\b') { return "{{ site.baseurl }}/seiten/snowball-rechner.html" }
  if ($Label -match '(?i)\blawine\b')               { return "{{ site.baseurl }}/seiten/lawine-rechner.html" }
  if ($Label -match '(?i)\bjahreskosten\b')         { return "{{ site.baseurl }}/seiten/jahreskosten-rechner.html" }
  if ($Label -match '(?i)\bnotgroschen\b')          { return "{{ site.baseurl }}/seiten/notgroschen-rechner.html" }
  if ($Label -match '(?i)\bspielraum\b')            { return "{{ site.baseurl }}/seiten/spielraum-rechner.html" }
  if ($Label -match '(?i)\bfixkosten\b')            { return "{{ site.baseurl }}/seiten/fixkosten-rechner.html" }
  return $null
}
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
  $lines = $text -split "`n", 0, "SimpleMatch"
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i].TrimEnd("`r")
    # Match: - [Mini-Rechner: ...](...)
    $m = [regex]::Match($line, '^\s*-\s*\[(?<label>Mini-Rechner:[^\]]+)\]\((?<target>[^)]*)\)\s*$')
    if (-not $m.Success) { continue }
    $label  = $m.Groups["label"].Value.Trim()
    $target = $m.Groups["target"].Value.Trim()
    # If target already looks good (has /seiten/ and ends .html), keep it
    if ($target -match '/seiten/.+\.html(\#.*)?$') { continue }
    $newTarget = Resolve-Target -Label $label
    if ($null -eq $newTarget) {
      $log.Add(($f.FullName + " :: UNMAPPED label=" + $label + " :: was=(" + $target + ")")) | Out-Null
      continue
    }
    $newLine = "  - [" + $label + "](" + $newTarget + ")"
    if ($newLine -ne $line) {
      $hits++
      $lines[$i] = $newLine
      $log.Add(($f.FullName + " :: FIX label=" + $label + " :: " + $target + " -> " + $newTarget)) | Out-Null
    }
  }
  $newText = ($lines -join "`n")
  if ($newText -ne $orig -and $Apply) {
    Write-Utf8NoBom -Path $f.FullName -Text $newText
    $written++
  }
}
$reportPath = Join-Path (Get-Location) "tools/_mvp02_fix_minirechner_links.txt"
Write-Utf8NoBom -Path $reportPath -Text ("Hits: " + $hits + "`nWrittenFiles: " + $written + "`nApply: " + $Apply.IsPresent + "`n`n" + ($log -join "`n"))
"OK: wrote tools/_mvp02_fix_minirechner_links.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }