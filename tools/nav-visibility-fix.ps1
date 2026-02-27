# ALLOW_REGEX_PATCH (temporary; must be removed when refactored to literal/AST patching)
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
function Split-Frontmatter {
  param([string]$Text)
  if (-not $Text.StartsWith("---`n") -and -not $Text.StartsWith("---`r`n")) { return $null }
  $endLf   = $Text.IndexOf("`n---`n", 4)
  $endCrLf = $Text.IndexOf("`r`n---`r`n", 5)
  if ($endLf -ge 0)   { return [pscustomobject]@{ Frontmatter=$Text.Substring(0, $endLf + 5);   Body=$Text.Substring($endLf + 5) } }
  if ($endCrLf -ge 0) { return [pscustomobject]@{ Frontmatter=$Text.Substring(0, $endCrLf + 8); Body=$Text.Substring($endCrLf + 8) } }
  return $null
}
$links = @(
  @{ key="DER_WEG";    label="Der Weg";             href="{{ site.baseurl }}/seiten/der-weg.html" },
  @{ key="FIXKOSTEN";  label="Fixkosten";           href="{{ site.baseurl }}/pillar/fixkosten.html" },
  @{ key="MONAT";      label="Monatliche Ausgaben"; href="{{ site.baseurl }}/seiten/monatliche-ausgaben.html" },
  @{ key="ORDNUNG";    label="Ordnung halten";      href="{{ site.baseurl }}/pillar/ordnung-halten.html" },
  @{ key="MONEY_PAGES";label="Money Pages";         href="{{ site.baseurl }}/seiten/money-pages.html" },
  @{ key="RECHNER";    label="Rechner Uebersicht";  href="{{ site.baseurl }}/seiten/rechner-uebersicht.html" }
)
$targets = @(
  "seiten/index.md",
  "pillar/index.md",
  "seiten/downloads.md",
  "seiten/der-weg.md",
  "seiten/money-pages.md",
  "seiten/rechner-uebersicht.md"
)
$root = Get-Location
$log  = New-Object System.Collections.Generic.List[string]
$changed = 0
$written = 0
$missingFiles = 0
$startMarker = "<!-- VISIBILITY_START -->"
$endMarker   = "<!-- VISIBILITY_END -->"
function Build-Block {
  param([string]$ExcludeKey)
  $b = New-Object System.Collections.Generic.List[string]
  $b.Add($startMarker) | Out-Null
  $b.Add("") | Out-Null
  $b.Add("## Einstieg") | Out-Null
  $b.Add("") | Out-Null
  foreach ($l in $links) {
    if ($ExcludeKey -and ($l.key -eq $ExcludeKey)) { continue }
    $b.Add("- [" + $l.label + "](" + $l.href + ")") | Out-Null
  }
  $b.Add("") | Out-Null
  $b.Add($endMarker) | Out-Null
  $b.Add("") | Out-Null
  return ($b -join "`n")
}
function Guess-ExcludeKey {
  param([string]$RelPath)
  if ($RelPath -eq "seiten/money-pages.md")        { return "MONEY_PAGES" }
  if ($RelPath -eq "seiten/rechner-uebersicht.md") { return "RECHNER" }
  if ($RelPath -eq "seiten/der-weg.md")            { return "DER_WEG" }
  return $null
}
foreach ($rel in $targets) {
  $full = Join-Path $root $rel
  if (-not (Test-Path -LiteralPath $full)) {
    $log.Add("MISSING FILE: " + $full) | Out-Null
    $missingFiles++
    continue
  }
  $bytes = [System.IO.File]::ReadAllBytes($full)
  $text  = Get-Utf8TextNoBom -Bytes $bytes
  $fmObj = Split-Frontmatter -Text $text
  if ($null -eq $fmObj) {
    $log.Add("SKIP (no frontmatter): " + $full) | Out-Null
    continue
  }
  $body = $fmObj.Body
  $exclude = Guess-ExcludeKey -RelPath $rel
  $block = Build-Block -ExcludeKey $exclude
  $newBody = $null
  $pattern = [regex]::Escape($startMarker) + "(?s).*?" + [regex]::Escape($endMarker) + "\s*"
  if ([regex]::IsMatch($body, $pattern)) {
    $newBody = [regex]::Replace($body, $pattern, ($block + "`n"), 1)
  }
  else {
    $m = [regex]::Match($body, "(?m)^\s*##\s+Weiter\s*$")
    if ($m.Success) {
      $pos = $m.Index
      $newBody = $body.Substring(0, $pos) + $block + "`n" + $body.Substring($pos)
    } else {
      if (-not $body.EndsWith("`n")) { $body += "`n" }
      $newBody = $body + "`n" + $block
    }
  }
  if ($newBody -ne $fmObj.Body) {
    $changed++
    $ex = "none"
    if ($exclude) { $ex = $exclude }
    $log.Add("CHANGE: " + $full + " (exclude=" + $ex + ")") | Out-Null
    if ($Apply) {
      $newText = $fmObj.Frontmatter + $newBody
      Write-Utf8NoBom -Path $full -Text $newText
      $written++
    }
  } else {
    $log.Add("OK: " + $full) | Out-Null
  }
}
$reportPath = Join-Path $root "tools/_nav_visibility_fix.txt"
Write-Utf8NoBom -Path $reportPath -Text (
  "NAV/VISIBILITY FIX - " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + "`n" +
  "Apply: " + $Apply.IsPresent + "`n" +
  "MissingFiles: " + $missingFiles + "`n" +
  "Changed: " + $changed + "`n" +
  "Written: " + $written + "`n`n" +
  ($log -join "`n")
)
"OK: wrote tools/_nav_visibility_fix.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }