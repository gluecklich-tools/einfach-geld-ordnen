$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if ($IsWindows) { try { chcp 65001 > $null } catch {} }
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$repo = Split-Path -Parent $PSScriptRoot
$seitenDir = Join-Path $repo "seiten"
$pillarDir = Join-Path $repo "pillar"
if (-not (Test-Path -LiteralPath $seitenDir)) { throw "Ordner fehlt: $seitenDir" }
if (-not (Test-Path -LiteralPath $pillarDir)) { throw "Ordner fehlt: $pillarDir" }
$hubFiles = Get-ChildItem -LiteralPath $seitenDir -Filter "download-hub-*.md" -File
if (-not $hubFiles -or $hubFiles.Count -lt 1) { throw "Keine download-hub-*.md gefunden." }
function Get-FrontmatterPermalink([string]$path) {
  $t = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $m = [regex]::Match($t, "(?ms)\A---\s*(?<fm>.*?)\s*---")
  if (-not $m.Success) { return $null }
  $fm = $m.Groups["fm"].Value
  $pm = [regex]::Match($fm, "(?mi)^\s*permalink:\s*(?<p>\S+)\s*$")
  if (-not $pm.Success) { return $null }
  return $pm.Groups["p"].Value.Trim()
}
function Add-IndexAliasesIfNeeded([hashtable]$idx, [string]$filePath) {
  $name = [System.IO.Path]::GetFileName($filePath)
  if ($name -ieq "index.md") {
    if (-not $idx.ContainsKey("/index.html")) { $idx["/index.html"] = $filePath }
    if (-not $idx.ContainsKey("/"))          { $idx["/"]          = $filePath }
  }
}
function Build-PermalinkIndex {
  $idx = @{}
  $pages = @()
  $pages += Get-ChildItem -LiteralPath $seitenDir -Filter "*.md" -File
  $pages += Get-ChildItem -LiteralPath $pillarDir -Filter "*.md" -File
  $pages += Get-ChildItem -LiteralPath $repo     -Filter "*.md" -File
  foreach ($p in $pages) {
    $pl = Get-FrontmatterPermalink -path $p.FullName
    if ($pl) {
      if (-not $idx.ContainsKey($pl)) { $idx[$pl] = $p.FullName }
    } else {
      Add-IndexAliasesIfNeeded -idx $idx -filePath $p.FullName
    }
  }
  return $idx
}
$permalinkIndex = Build-PermalinkIndex
function Get-WeiterLinks([string]$text) {
  $m = [regex]::Match($text, "(?ms)^\#\#\s+Weiter\s*$\s*(?<body>.*?)(^\#\#\s+|\z)")
  if (-not $m.Success) { return @() }
  $body = $m.Groups["body"].Value
  $links = @()
  $links = @($links)
  foreach ($lm in [regex]::Matches($body, "\]\((?<url>[^)]+)\)")) {
    $u = $lm.Groups["url"].Value.Trim()
    if ($u) { $links += $u }
  }
  return $links
}
$allowlist = $null
$fail = @()
foreach ($f in $hubFiles) {
  $t = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $okFree   = ($t -match "(^|\r?\n)##\s+Freebie(\r?\n|$)")
  $okVoll   = ($t -match "(^|\r?\n)##\s+Vollversion(\r?\n|$)")
  $okPrem   = ($t -match "(^|\r?\n)##\s+Premium(\r?\n|$)")
  $okFooter = ($t -match "\{\%\s*include\s+no_sackgasse_footer\.html\s*\%\}")
  $links = Get-WeiterLinks -text $t
  $links = @($links)
  $okWeiter  = (@($links).Count -gt 0)
$okWeiter3 = ($true)
  $bad = @()
  if ($okWeiter) {
    $uniq = @($links | Select-Object -Unique)
    if ($uniq.Count -ne 3) { $bad += "duplicateLinks" }
    foreach ($u in $links) {
      if ($u -match "^\s*https?://") { $bad += "external:$u"; continue }
      if ($u -match "\.md(\#.*)?$")  { $bad += "md:$u"; continue }
      if ($u -match "/\s*$")         { $bad += "trailingSlash:$u"; continue }
      if ($u -notmatch "^\{\{\s*site\.baseurl\s*\}\}/") { $bad += "noBaseurl:$u"; continue }
      if ($u -notmatch "\.html(\#.*)?$") { $bad += "noHtml:$u"; continue }
      $uNoHash = ($u -split "#")[0].Trim()
      $pl = ($uNoHash -replace "^\{\{\s*site\.baseurl\s*\}\}", "")
      if (-not $pl.StartsWith("/")) { $pl = "/" + $pl }
      if (-not $permalinkIndex.ContainsKey($pl)) {
        $bad += "targetMissing:$pl"
      }
    }
    if ($allowlist -and $allowlist.Count -gt 0) {
      foreach ($u in $links) {
        $uNoHash2 = ($u -split "#")[0].Trim()
        if (-not ($allowlist -contains $uNoHash2)) {
          $bad += "notAllowlisted:$uNoHash2"
        }
      }
    }
  }
  $okWeiterLinks = ($bad.Count -eq 0)
  if (-not ($okFree -and $okVoll -and $okPrem -and $okFooter -and $okWeiter -and $okWeiter3 -and $okWeiterLinks)) {
    $fail += [pscustomobject]@{
      File        = $f.Name
      Freebie     = $okFree
      Vollversion = $okVoll
      Premium     = $okPrem
      Footer      = $okFooter
      Weiter      = $okWeiter
      Weiter3     = $okWeiter3
      WeiterOK    = $okWeiterLinks
      WeiterBad   = ($bad -join " | ")
    }
  }
}
if ($fail.Count -gt 0) {
  "FAIL: Download-Hub STRICT Gate verletzt:"
  $fail | Sort-Object File | Format-Table -AutoSize
  exit 1
}
"PASS: Download-Hub STRICT Gate ok (3 Stufen + Footer + Weiter=3 + baseurl+.html + targets exist)."