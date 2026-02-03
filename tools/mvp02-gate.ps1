$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { chcp 65001 > $null } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# tools/mvp02-gate.ps1
# MVP-02 Gate: no_sackgasse footer + "## Weiter" rules (inline OR include-based)
# Marker: EGO_PATCH_MVP02_WEITER_INCLUDE_V1

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

$reOk = "^(?:\{\{\s*site\.baseurl\s*\}\}/(?:$|index\.html(?:\#.*)?$|(seiten|pillar)/.+\.html(?:\#.*)?$))$"
$WeiterIncludeTag = "{% include weiter_links.html %}"
$FooterIncludeRx  = "\{\%\s*include\s+no_sackgasse_footer\.html\s*\%\}"

foreach ($f in $targets) {
  $raw = [System.IO.File]::ReadAllText($f.FullName, [System.Text.UTF8Encoding]::new($false))

  if ($raw.Length -lt 3 -or (-not $raw.StartsWith("---`r`n") -and -not $raw.StartsWith("---`n"))) {
    Add-Bad ("FRONTMATTER_START " + $f.FullName)
  }

  if ($raw -notmatch $FooterIncludeRx) {
    Add-Bad ("MISSING_INCLUDE " + $f.FullName)
  }

  if ($raw -notmatch "(?m)^\#\#\s+Weiter\s*$") {
    Add-Bad ("MISSING_WEITER " + $f.FullName)
    continue
  }

  $m = [regex]::Match($raw, "(?ms)^\#\#\s+Weiter\s*$\s*(?<sec>.*?)(^\#\#\s+|\z)")
  $sec = $m.Groups["sec"].Value

  $usesWeiterInclude = $false
  try { if ($sec -match [regex]::Escape($WeiterIncludeTag)) { $usesWeiterInclude = $true } } catch { $usesWeiterInclude = $false }
  if ($usesWeiterInclude) { continue }

  $links = [regex]::Matches($sec, "\[[^\]]+\]\(([^)]+)\)")
  if ($links.Count -ne 3) {
    Add-Bad ("WEITER_LINK_COUNT=" + [string]$links.Count + " " + $f.FullName)
    continue
  }

  foreach ($lm in $links) {
    $u = $lm.Groups[1].Value.Trim()
    if ($u -match "\.md(\#|$)") { Add-Bad ("BAD_LINK_MD " + $f.FullName + " -> " + $u) }
    if ($u -match "^/seiten/" -or $u -match "^/pillar/") { Add-Bad ("BAD_LINK_ROOTSLASH " + $f.FullName + " -> " + $u) }
    if ($u -match "/seiten/[^)]+/$" -or $u -match "/pillar/[^)]+/$") { Add-Bad ("BAD_LINK_TRAILING_SLASH " + $f.FullName + " -> " + $u) }
    if ($u -notmatch $reOk) { Add-Bad ("BAD_LINK_FORMAT " + $f.FullName + " -> " + $u) }
  }
}

if ($bad.Count -gt 0) {
  "MVP02_GATE_FAIL"
  $bad | Sort-Object
  throw ("MVP02_GATE_FAIL_COUNT=" + [string]$bad.Count)
}

"MVP02_GATE_OK"

