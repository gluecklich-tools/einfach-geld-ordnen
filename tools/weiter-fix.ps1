param(
  [switch]$Apply
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Read-TextUtf8NoBom([string]$Path) {
  $bytes = [System.IO.File]::ReadAllBytes($Path)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    return [System.Text.UTF8Encoding]::new($false).GetString($bytes, 3, $bytes.Length - 3)
  }
  return [System.Text.UTF8Encoding]::new($false).GetString($bytes)
}

function Write-Utf8NoBom {
  param([string]$Path,[string]$Text)
  $enc = [System.Text.UTF8Encoding]::new($false)
  [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

function Split-FrontMatter {
  param([string]$Text)
  $n = $Text -replace "`r`n","`n" -replace "`r","`n"
  if ($n -notmatch '(?s)\A---\n(.*?)\n---\n?') {
    return [pscustomobject]@{ FrontMatter = ""; Body = $n }
  }
  $m = [regex]::Match($n,'(?s)\A---\n(.*?)\n---\n?')
  [pscustomobject]@{
    FrontMatter = $m.Groups[1].Value
    Body        = $n.Substring($m.Length)
  }
}

function Get-PermalinkFromFrontMatter {
  param([string]$FrontMatter)
  $m = [regex]::Match($FrontMatter, '(?im)^\s*permalink:\s*(?<p>\S+)\s*$')
  if (-not $m.Success) { return $null }
  $p = $m.Groups['p'].Value.Trim()
  if ($p -notmatch '^/') { $p = '/' + $p }
  return $p
}

function Get-WeiterSectionLinks {
  param([string]$Body)
  $b = $Body -replace "`r`n","`n" -replace "`r","`n"
  $m = [regex]::Match($b, '(?is)##\s+Weiter\s*\n(?<sec>.*?)(\n##\s+|\z)')
  if (-not $m.Success) { return @() }
  $sec = $m.Groups["sec"].Value
  $ms = [regex]::Matches($sec, '\((?<u>[^)]+)\)')
  $out = @()
  foreach($x in $ms){
    $u = $x.Groups["u"].Value.Trim()
    if ($u -match '^\{\{\s*site\.baseurl\s*\}\}(?<p>/.*)$') { $u = $Matches['p'] }
    if ($u -match '^https?://') { continue }
    if ($u -notmatch '^/') { continue }
    $out += $u
  }
  return @($out | Sort-Object -Unique)
}

function LabelFromPermalink {
  param([string]$Permalink)
  $p = ($Permalink -replace '^/','' -replace '\.html$','')
  if (-not $p) { return 'Start' }
  $leaf = ($p -split '/')[ -1 ]
  if (-not $leaf) { return 'Start' }
  $t = ($leaf -replace '-',' ')
  $t = (Get-Culture).TextInfo.ToTitleCase($t)
  $t = $t -replace 'Ubersicht','Uebersicht'
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

$root = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$files = New-Object System.Collections.Generic.List[System.IO.FileInfo]

$trackedMdFiles = @(
  git -C $root ls-files -- 'seiten/*.md' 'pillar/*.md'
)

foreach($rel in $trackedMdFiles){
  if([string]::IsNullOrWhiteSpace($rel)){ continue }
  $full = Join-Path $root $rel
  if(-not (Test-Path -LiteralPath $full -PathType Leaf)){ continue }
  $files.Add((Get-Item -LiteralPath $full)) | Out-Null
}

$files = @($files | Sort-Object FullName -Unique)
if ($files.Count -eq 0) { throw "No tracked md files found in seiten/ or pillar/." }

$perma = @{}
foreach ($f in $files) {
  $txt = Read-TextUtf8NoBom -Path $f.FullName
  $fm = Split-FrontMatter -Text $txt
  $p = Get-PermalinkFromFrontMatter -FrontMatter $fm.FrontMatter
  if ($p) { $perma[$p] = $f.FullName }
}

$log = New-Object System.Collections.Generic.List[string]
$written = 0
$checked = 0
$downloadsP = "/seiten/downloads.html"
$clusterP = "/pillar/cluster.html"

foreach ($f in $files | Sort-Object FullName) {
  $txt = Read-TextUtf8NoBom -Path $f.FullName
  $fm = Split-FrontMatter -Text $txt
  $p = Get-PermalinkFromFrontMatter -FrontMatter $fm.FrontMatter
  if (-not $p) { continue }

  $checked++
  $isPillar = $false
  if ((($f.FullName -replace '\\','/') -like '*/pillar/*')) { $isPillar = $true }

  $existingTargets = Get-WeiterSectionLinks -Body $fm.Body
  $norm = @()
  foreach ($t in $existingTargets) {
    if ($t -eq $downloadsP) { continue }
    if ($t -eq "/") { $norm += $t; continue }
    if ($perma.ContainsKey($t)) { $norm += $t }
  }
  $norm = @($norm | Sort-Object -Unique)

  $nextP = $null
  foreach ($n in $norm) {
    if ($n -ne $p -and $n -ne $downloadsP) {
      if ($perma.ContainsKey($n)) { $nextP = $n; break }
    }
  }

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

  $overviewP = "/"
  $overviewLabel = "Start"
  if ($isPillar -and $perma.ContainsKey($clusterP)) {
    $overviewP = $clusterP
    $overviewLabel = "Cluster"
  }

  $nextLabel = "Weiter"
  if ($nextP -eq "/seiten/rechner-uebersicht.html") { $nextLabel = "Rechner Uebersicht" }
  elseif ($nextP -eq "/seiten/der-weg.html") { $nextLabel = "Der Weg" }
  elseif ($nextP -eq "/seiten/monatliche-ausgaben.html") { $nextLabel = "Monatliche Ausgaben" }
  elseif ($nextP -eq "/pillar/cluster.html") { $nextLabel = "Cluster" }
  elseif ($nextP -ne "/") { $nextLabel = LabelFromPermalink -Permalink $nextP }

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
    $newBody = $bodyN + "`n" + $block + "`n"
  }

  $newText = "---`n" + $fm.FrontMatter.Trim("`n") + "`n---`n" + $newBody.TrimStart("`n")
  if ($Apply) {
    Write-Utf8NoBom -Path $f.FullName -Text $newText
    $written++
  }

  $log.Add(("{0}`t{1}`t{2}`t{3}" -f $p, $nextP, $overviewP, $f.FullName)) | Out-Null
}

$report = Join-Path $root "tools/_weiter_fix.txt"
Write-Utf8NoBom -Path $report -Text (
  "WEITER FIX - " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + "`n" +
  "Apply: " + $Apply.IsPresent + "`n" +
  "Permalinks indexed: " + $perma.Count + "`n" +
  "Checked: " + $checked + "`n" +
  "Written: " + $written + "`n`n" +
  "permalink`tnext`toverview`tfile`n" +
  ($log -join "`n")
)

"OK: wrote tools/_weiter_fix.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }
exit 0