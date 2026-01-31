param([switch]$Apply)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Get-Utf8TextNoBom {
  param([byte[]]$Bytes)
  if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) { $Bytes = $Bytes[3..($Bytes.Length-1)] }
  [System.Text.Encoding]::UTF8.GetString($Bytes)
}
function Write-Utf8NoBom {
  param([string]$Path, [string]$Text)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}
function Split-Frontmatter {
  param([string]$Text)
  $t = $Text -replace "`r`n","`n" -replace "`r","`n"
  $m = [regex]::Match($t, '\A---\s*\n(?<fm>.*?\n)---\s*\n(?<body>.*)\z', [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { return $null }
  [pscustomobject]@{ Frontmatter="---`n" + $m.Groups["fm"].Value + "---`n"; Body=$m.Groups["body"].Value }
}
function Get-PermalinkFromFrontmatter {
  param([string]$Front)
  $m = [regex]::Match($Front, '(?im)^\s*permalink:\s*(?<p>.+?)\s*$')
  if (-not $m.Success) { return $null }
  $p = $m.Groups["p"].Value.Trim()
  if (($p.StartsWith('"') -and $p.EndsWith('"')) -or ($p.StartsWith("'") -and $p.EndsWith("'"))) { $p = $p.Substring(1, $p.Length-2).Trim() }
  return $p
}
function Get-WeiterSectionLinks {
  param([string]$Body)
  $b = $Body -replace "`r`n","`n" -replace "`r","`n"
  $m = [regex]::Match($b, '(?is)##\s+Weiter\s*\n(?<sec>.*?)(\n##\s+|\z)')
  if (-not $m.Success) { return @() }
  $sec = $m.Groups["sec"].Value
  $hits = [regex]::Matches($sec, '\[[^\]]+\]\((?<t>[^)]+)\)')
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($h in $hits) {
    $t = $h.Groups["t"].Value
    if ($t) { $out.Add($t) | Out-Null }
  }
  return $out.ToArray()
}
function Normalize-TargetToPermalink {
  param([string]$Target)
  $t = ($Target -replace "`r`n","`n" -replace "`r","`n").Trim()
  # kill broken liquid fragments
  if ($t -match '^\{\{\s*$') { return $null }
  if ($t -match '^\{\{\s*site\.baseurl\s*\}\}(?<rest>/.*)$') { $t = $Matches["rest"] }
  if ($t -match '^/einfach-geld-ordnen(?<rest>/.*)$') { $t = $Matches["rest"] }
  $t = $t -replace '#.*$',''
  $t = $t -replace '\?.*$',''
  if ($t -eq "/index.html") { $t = "/" }
  return $t
}
function Build-WeiterBlock {
  param(
    [string]$NextLabel,
    [string]$NextHref,
    [string]$OverviewLabel,
    [string]$OverviewHref
  )
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("## Weiter") | Out-Null
  $lines.Add("") | Out-Null
  $lines.Add("- **Weiter:** [" + $NextLabel + "](" + $NextHref + ")") | Out-Null
  $lines.Add("- **Vorlage/Download:** [Downloads]({{ site.baseurl }}/seiten/downloads.html)") | Out-Null
  $lines.Add("- **Uebersicht:** [" + $OverviewLabel + "](" + $OverviewHref + ")") | Out-Null
  $lines.Add("") | Out-Null
  return ($lines -join "`n")
}
$root = Get-Location
$files = @()
$files += Get-ChildItem -LiteralPath (Join-Path $root "seiten") -Filter "*.md" -File -ErrorAction SilentlyContinue
$files += Get-ChildItem -LiteralPath (Join-Path $root "pillar") -Filter "*.md" -File -ErrorAction SilentlyContinue
if ($files.Count -eq 0) { throw "No md files found in seiten/ or pillar/." }
# permalink index
$perma = @{}
foreach ($f in $files) {
  $txt = Get-Utf8TextNoBom -Bytes ([System.IO.File]::ReadAllBytes($f.FullName))
  $fm = Split-Frontmatter -Text $txt
  if ($null -eq $fm) { continue }
  $p = Get-PermalinkFromFrontmatter -Front $fm.Frontmatter
  if ($p) { $perma[$p] = $f.FullName }
}
# root alias
if ($perma.ContainsKey("/") -and -not $perma.ContainsKey("/index.html")) { $perma["/index.html"] = $perma["/"] }
if ($perma.ContainsKey("/index.html") -and -not $perma.ContainsKey("/")) { $perma["/"] = $perma["/index.html"] }
$log = New-Object System.Collections.Generic.List[string]
$changed = 0
$written = 0
$checked = 0
$downloadsP = "/seiten/downloads.html"
$clusterP = "/pillar/cluster.html"
foreach ($f in $files | Sort-Object FullName) {
  $txt = Get-Utf8TextNoBom -Bytes ([System.IO.File]::ReadAllBytes($f.FullName))
  $fm = Split-Frontmatter -Text $txt
  if ($null -eq $fm) { continue }
  $p = Get-PermalinkFromFrontmatter -Front $fm.Frontmatter
  if (-not $p) { continue }
  $checked++
  $isPillar = $false
  if ($f.FullName -match '\\pillar\\') { $isPillar = $true }
  $existingTargets = Get-WeiterSectionLinks -Body $fm.Body
  $norm = @()
  foreach ($t in $existingTargets) {
    $n = Normalize-TargetToPermalink -Target $t
    if ($n) { $norm += $n }
  }
  # choose next from existing that exists + not self + not downloads/cluster/root
  $nextP = $null
  foreach ($n in $norm) {
    if ($n -eq $p) { continue }
    if ($n -eq "/") { continue }
    if ($n -eq $downloadsP) { continue }
    if ($n -eq $clusterP) { continue }
    if ($perma.ContainsKey($n)) { $nextP = $n; break }
  }
  # defaults (didaktik: seiten -> Der Weg / Monatliche Ausgaben; pillar -> Rechner)
  if (-not $nextP) {
    if (-not $isPillar) {
      if ($p -eq "/seiten/der-weg.html") { $nextP = "/seiten/monatliche-ausgaben.html" }
      else { $nextP = "/seiten/der-weg.html" }
    } else {
      $nextP = "/seiten/rechner-uebersicht.html"
    }
    if (-not $perma.ContainsKey($nextP)) { $nextP = "/pillar/cluster.html" }
    if (-not $perma.ContainsKey($nextP)) { $nextP = "/" }
  }
  # overview
  $overviewP = "/"
  $overviewLabel = "Start"
  if ($isPillar -and $perma.ContainsKey($clusterP)) {
    $overviewP = $clusterP
    $overviewLabel = "Cluster"
  }
  # labels (minimal, stabil)
  $nextLabel = "Weiter"
  if ($nextP -eq "/seiten/rechner-uebersicht.html") { $nextLabel = "Rechner Uebersicht" }
  elseif ($nextP -eq "/seiten/der-weg.html") { $nextLabel = "Der Weg" }
  elseif ($nextP -eq "/seiten/monatliche-ausgaben.html") { $nextLabel = "Monatliche Ausgaben" }
  elseif ($nextP -eq "/pillar/cluster.html") { $nextLabel = "Cluster" }
  $nextHref = "{{ site.baseurl }}" + $nextP
  if ($nextP -eq "/") { $nextHref = "{{ site.baseurl }}/" }
  $overviewHref = "{{ site.baseurl }}" + $overviewP
  if ($overviewP -eq "/") { $overviewHref = "{{ site.baseurl }}/" }
  $block = Build-WeiterBlock -NextLabel $nextLabel -NextHref $nextHref -OverviewLabel $overviewLabel -OverviewHref $overviewHref
  $bodyN = $fm.Body -replace "`r`n","`n" -replace "`r","`n"
  if ([regex]::IsMatch($bodyN, '(?is)##\s+Weiter\s*\n')) {
    $newBody = [regex]::Replace($bodyN, '(?is)##\s+Weiter\s*\n.*?(?=\n##\s+|\z)', $block.TrimEnd() + "`n", 1)
  } else {
    if (-not $bodyN.EndsWith("`n")) { $bodyN += "`n" }
    $newBody = $bodyN + "`n" + $block
  }
  if ($newBody -ne $bodyN) {
    $changed++
    $log.Add("CHANGE: " + $p + " -> next=" + $nextP + " overview=" + $overviewP) | Out-Null
    if ($Apply) {
      $newText = $fm.Frontmatter + $newBody
      Write-Utf8NoBom -Path $f.FullName -Text $newText
      $written++
    }
  }
}
$report = Join-Path $root "tools/_weiter_fix.txt"
Write-Utf8NoBom -Path $report -Text (
  "WEITER FIX - " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + "`n" +
  "Apply: " + $Apply.IsPresent + "`n" +
  "Permalinks indexed: " + $perma.Count + "`n" +
  "Checked: " + $checked + "`n" +
  "Changed: " + $changed + "`n" +
  "Written: " + $written + "`n`n" +
  ($log -join "`n")
)
"OK: wrote tools/_weiter_fix.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }