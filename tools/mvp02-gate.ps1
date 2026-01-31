$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 > $null
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
Set-Location -LiteralPath $root
$targets = @()
if (Test-Path -LiteralPath ".\seiten") { $targets += Get-ChildItem -LiteralPath ".\seiten" -File -Filter "*.md" }
if (Test-Path -LiteralPath ".\pillar") { $targets += Get-ChildItem -LiteralPath ".\pillar" -File -Filter "*.md" }
$targets = $targets | Sort-Object FullName -Unique
if ($targets.Count -eq 0) { throw "NO_TARGET_MD_FOUND in .\seiten or .\pillar" }
$bad = New-Object System.Collections.Generic.List[string]
function Add-Bad([string]$msg) { $bad.Add($msg) | Out-Null }
# Allowed links in section "## Weiter":
# - {{ site.baseurl }}/seiten/... .html
# - {{ site.baseurl }}/pillar/... .html
# - home: {{ site.baseurl }}/  or {{ site.baseurl }}/index.html
$reOk = "^(?:\{\{\s*site\.baseurl\s*\}\}/(?:$|index\.html(?:\#.*)?$|(seiten|pillar)/.+\.html(?:\#.*)?$))$"
foreach ($f in $targets) {
  $raw = [System.IO.File]::ReadAllText($f.FullName, (New-Object System.Text.UTF8Encoding($false)))
  if ($raw.Length -lt 3 -or (-not $raw.StartsWith("---`r`n") -and -not $raw.StartsWith("---`n"))) {
    Add-Bad ("FRONTMATTER_START " + $f.FullName)
  }
  if ($raw -notmatch "\{\%\s*include\s+no_sackgasse_footer\.html\s*\%\}") {
    Add-Bad ("MISSING_INCLUDE " + $f.FullName)
  }
  if ($raw -notmatch "(?m)^\#\#\s+Weiter\s*$") {
    Add-Bad ("MISSING_WEITER " + $f.FullName)
    continue
  }
  $m = [regex]::Match($raw, "(?ms)^\#\#\s+Weiter\s*$\s*(?<sec>.*?)(^\#\#\s+|\z)")
  $sec = $m.Groups["sec"].Value
  $links = [regex]::Matches($sec, "\[[^\]]+\]\(([^)]+)\)")
  if ($links.Count -ne 3) {
    Add-Bad ("WEITER_LINK_COUNT=" + [string]$links.Count + " " + $f.FullName)
  }
  foreach ($lm in $links) {
    $u = $lm.Groups[1].Value.Trim()
    if ($u -match "\.md(\#|$)") { Add-Bad ("BAD_LINK_MD " + $f.FullName + " -> " + $u) }
    if ($u -match "^/seiten/" -or $u -match "^/pillar/") { Add-Bad ("BAD_LINK_ROOTSLASH " + $f.FullName + " -> " + $u) }
    if ($u -match "/seiten/[^)]+/$" -or $u -match "/pillar/[^)]+/$") { Add-Bad ("BAD_LINK_TRAILING_SLASH " + $f.FullName + " -> " + $u) }
    if ($u -notmatch $reOk) {
      Add-Bad ("BAD_LINK_FORMAT " + $f.FullName + " -> " + $u)
    }
  }
}
if ($bad.Count -gt 0) {
  "MVP02_GATE_FAIL"
  $bad | Sort-Object
  throw ("MVP02_GATE_FAIL_COUNT=" + [string]$bad.Count)
}
"MVP02_GATE_OK"