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
function Get-WeiterSectionParts {
  param([string]$Body)
  $m = [regex]::Match($Body, '(?is)^(?<pre>.*?\n)##\s+Weiter\s*\n(?<sec>.*?)(?<post>\n##\s+|\z)')
  if (-not $m.Success) { return $null }
  return [pscustomobject]@{ Pre=$m.Groups["pre"].Value; Sec=$m.Groups["sec"].Value; Post=$m.Groups["post"].Value }
}
function Count-InternalLinks {
  param([string]$Text)
  $links = [regex]::Matches($Text, '\[[^\]]+\]\((?<t>[^)]+)\)')
  $cnt = 0
  foreach ($lm in $links) {
    $t = $lm.Groups["t"].Value.Trim()
    if ($t -match '^https?://') { continue }
    if ($t -match '^\{\{\s*site\.baseurl\s*\}\}/') { $cnt++; continue }
    if ($t -match '^/') { $cnt++; continue }
  }
  return $cnt
}
function Has-Target {
  param([string]$Sec, [string]$Target)
  return ($Sec -match [regex]::Escape("](" + $Target + ")"))
}
# Canonical fallbacks (exist in repo)
$canon = @(
  @{ Label="Downloads";          Target="{{ site.baseurl }}/seiten/downloads.html" },
  @{ Label="Rechner Uebersicht"; Target="{{ site.baseurl }}/seiten/rechner-uebersicht.html" },
  @{ Label="Money Pages";        Target="{{ site.baseurl }}/seiten/money-pages.html" }
)
$files = @()
$files += Get-ChildItem -LiteralPath (Join-Path (Get-Location) "seiten") -Filter "*.md" -File -ErrorAction SilentlyContinue
$files += Get-ChildItem -LiteralPath (Join-Path (Get-Location) "pillar") -Filter "*.md" -File -ErrorAction SilentlyContinue
if ($files.Count -eq 0) { throw "No md files found." }
$eligible = 0
$written  = 0
$log = New-Object System.Collections.Generic.List[string]
foreach ($f in $files | Sort-Object FullName) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $text  = Get-Utf8TextNoBom -Bytes $bytes
  $orig  = $text
  $fmObj = Split-Frontmatter -Text $text
  if ($null -eq $fmObj) { continue }
  $ws = Get-WeiterSectionParts -Body $fmObj.Body
  if ($null -eq $ws) { continue }
  $cnt = Count-InternalLinks -Text $ws.Sec
  if ($cnt -ne 2) { continue }
  $eligible++
  $add = $null
  foreach ($c in $canon) {
    if (-not (Has-Target -Sec $ws.Sec -Target $c.Target)) { $add = $c; break }
  }
  if ($null -eq $add) { $add = $canon[2] }
  $sec = $ws.Sec
  if (-not $sec.EndsWith("`n")) { $sec += "`n" }
  $sec += "- [" + $add.Label + "](" + $add.Target + ")`n"
  $newBody = $ws.Pre + "## Weiter`n" + $sec + $ws.Post
  $newText = $fmObj.Frontmatter + $newBody
  if ($Apply) {
    Write-Utf8NoBom -Path $f.FullName -Text $newText
    $written++
    $log.Add(($f.FullName + " :: added -> " + $add.Target)) | Out-Null
  }
}
$reportPath = Join-Path (Get-Location) "tools/_mvp02_fix_weiterlinks.txt"
Write-Utf8NoBom -Path $reportPath -Text ("Eligible: " + $eligible + "`nWritten: " + $written + "`nApply: " + $Apply.IsPresent + "`n`n" + ($log -join "`n"))
"OK: wrote tools/_mvp02_fix_weiterlinks.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }