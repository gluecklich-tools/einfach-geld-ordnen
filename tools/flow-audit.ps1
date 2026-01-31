param()
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Get-Utf8TextNoBom {
  param([byte[]]$Bytes)
  if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
    $Bytes = $Bytes[3..($Bytes.Length-1)]
  }
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
  $fm = "---`n" + $m.Groups["fm"].Value + "---`n"
  $body = $m.Groups["body"].Value
  [pscustomobject]@{ Frontmatter=$fm; Body=$body }
}
function Get-PermalinkFromFrontmatter {
  param([string]$Front)
  $m = [regex]::Match($Front, '(?im)^\s*permalink:\s*(?<p>.+?)\s*$')
  if (-not $m.Success) { return $null }
  $p = $m.Groups["p"].Value.Trim()
  if (($p.StartsWith('"') -and $p.EndsWith('"')) -or ($p.StartsWith("'") -and $p.EndsWith("'"))) {
    $p = $p.Substring(1, $p.Length-2).Trim()
  }
  # normalize root-style
  if ($p -eq "/index.html") { $p = "/" }
  $p
}
function Get-WeiterTargets {
  param([string]$Body)
  $b = $Body -replace "`r`n","`n" -replace "`r","`n"
  $m = [regex]::Match($b, '(?is)##\s+Weiter\s*\n(?<sec>.*?)(\n##\s+|\z)')
  if (-not $m.Success) { return @() }
  $sec = $m.Groups["sec"].Value
  $hits = [regex]::Matches($sec, '\[[^\]]+\]\((?<t>[^)]+)\)')
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($h in $hits) {
    $t = ($h.Groups["t"].Value -replace "`r`n","`n" -replace "`r","`n").Trim()
    if (-not $t) { continue }
    if ($t -match '^https?://') { continue }
    $out.Add($t) | Out-Null
  }
  $out.ToArray()
}
function Normalize-TargetToPermalink {
  param([string]$Target)
  $t = ($Target -replace "`r`n","`n" -replace "`r","`n").Trim()
  # kill broken liquid fragments
  if ($t -match '^\{\{\s*$') { return $null }
  if ($t -match '^\{\{') {
    # if liquid got split (rare), reject to avoid false missing targets
    if ($t -notmatch '\}\}') { return $null }
  }
  if ($t -match '^\{\{\s*site\.baseurl\s*\}\}(?<rest>/.*)$') { $t = $Matches["rest"] }
  if ($t -match '^/einfach-geld-ordnen(?<rest>/.*)$') { $t = $Matches["rest"] }
  $t = $t -replace '#.*$',''
  $t = $t -replace '\?.*$',''
  if ($t -eq "/index.html") { $t = "/" }
  if ($t -eq "") { $t = "/" }
  $t
}
$root = Get-Location
$files = @()
$files += Get-ChildItem -LiteralPath (Join-Path $root "seiten") -Filter "*.md" -File -ErrorAction SilentlyContinue
$files += Get-ChildItem -LiteralPath (Join-Path $root "pillar") -Filter "*.md" -File -ErrorAction SilentlyContinue
if ($files.Count -eq 0) { throw "No md files found in seiten/ or pillar/." }
$perma = @{}
foreach ($f in $files) {
  $txt = Get-Utf8TextNoBom -Bytes ([System.IO.File]::ReadAllBytes($f.FullName))
  $fm = Split-Frontmatter -Text $txt
  if ($null -eq $fm) { continue }
  $p = Get-PermalinkFromFrontmatter -Front $fm.Frontmatter
  if ($p) { $perma[$p] = $f.FullName }
}
# Root aliases / virtual root
if ($perma.ContainsKey("/")) {
  if (-not $perma.ContainsKey("/index.html")) { $perma["/index.html"] = $perma["/"] }
} elseif ($perma.ContainsKey("/index.html")) {
  $perma["/"] = $perma["/index.html"]
} else {
  # even if no page is indexed as "/", the live site root exists (index.html)
  $perma["/"] = "<virtual-root>"
  $perma["/index.html"] = "<virtual-root>"
}
$report = New-Object System.Collections.Generic.List[string]
$report.Add("FLOW AUDIT - " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) | Out-Null
$report.Add("Permalinks indexed: " + $perma.Count) | Out-Null
$report.Add("") | Out-Null
$failCount = 0
$checked = 0
foreach ($f in $files | Sort-Object FullName) {
  $txt = Get-Utf8TextNoBom -Bytes ([System.IO.File]::ReadAllBytes($f.FullName))
  $fm = Split-Frontmatter -Text $txt
  if ($null -eq $fm) { continue }
  $p = Get-PermalinkFromFrontmatter -Front $fm.Frontmatter
  if (-not $p) { continue }
  $checked++
  $targets = Get-WeiterTargets -Body $fm.Body
  $norm = @()
  foreach ($t in $targets) {
    $n = Normalize-TargetToPermalink -Target $t
    if ($n) { $norm += $n }
  }
  $report.Add("PAGE: " + $p) | Out-Null
  $report.Add("FILE: " + $f.FullName) | Out-Null
  if ($targets.Count -ne 3) { $report.Add("  FAIL WeiterTargetsCount=" + $targets.Count) | Out-Null; $failCount++ }
  else { $report.Add("  OK   WeiterTargetsCount=3") | Out-Null }
  $dups = @($norm | Group-Object | Where-Object { $_.Count -gt 1 })
  if ($dups.Count -gt 0) { $report.Add("  FAIL Duplicates=" + (@($dups | ForEach-Object { $_.Name } | Sort-Object) -join ", ")) | Out-Null; $failCount++ }
  else { $report.Add("  OK   NoDuplicates") | Out-Null }
  $self = $false
  foreach ($n in $norm) { if ($n -eq $p) { $self = $true } }
  if ($self) { $report.Add("  FAIL SelfLinkInWeiter") | Out-Null; $failCount++ }
  else { $report.Add("  OK   NoSelfLinkInWeiter") | Out-Null }
  foreach ($n in $norm) {
    if (-not $n) { continue }
    if ($perma.ContainsKey($n)) { $report.Add("  OK   TargetExists " + $n) | Out-Null }
    else { $report.Add("  FAIL MissingTarget " + $n) | Out-Null; $failCount++ }
  }
  $report.Add("") | Out-Null
}
$report.Add("SUMMARY: checked=" + $checked + " failFlags=" + $failCount) | Out-Null
$outPath = Join-Path $root "tools/_flow_audit.txt"
Write-Utf8NoBom -Path $outPath -Text ($report -join "`n")
"OK: wrote tools/_flow_audit.txt"