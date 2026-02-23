param(
  [Parameter(Mandatory=$true)]
  [int]$Idx,

  [Parameter(Mandatory=$true)]
  [string]$InventoryTsv,

  [string]$RepoRoot = "",
  [string]$BaseUrl  = "https://gluecklich-tools.github.io/einfach-geld-ordnen"
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $RepoRoot=(git rev-parse --show-toplevel 2>$null).Trim()
}
if([string]::IsNullOrWhiteSpace($RepoRoot) -or !(Test-Path -LiteralPath $RepoRoot)){
  throw "STOP: RepoRoot not found"
}
Set-Location -LiteralPath $RepoRoot

if(!(Test-Path -LiteralPath $InventoryTsv)){
  throw "STOP: InventoryTsv missing: $InventoryTsv"
}

# --- Parse inventory row (tsv) ---
$lines=[IO.File]::ReadAllLines($InventoryTsv,$enc)
if($lines.Count -lt 2){ throw "STOP: inventory empty" }

$row=$null
foreach($ln in ($lines | Select-Object -Skip 1)){
  if([string]::IsNullOrWhiteSpace($ln)){ continue }
  $c=$ln -split "`t"
  if($c.Count -lt 3){ continue }
  if($c[0].Trim() -eq $Idx.ToString()){
    $row=$c
    break
  }
}
if($null -eq $row){ throw "STOP: idx not found in inventory: $Idx" }

$path=$row[1].Trim()
$url =$row[2].Trim()
$invStatus= if($row.Count -ge 4){ $row[3].Trim() } else { "" }
$srcRel  = if($row.Count -ge 5){ $row[4].Trim() } else { "" }

# --- Resolve source file (prefer explicit source column; else heuristic) ---
$srcFile=""
if($srcRel){
  $cand=Join-Path $RepoRoot $srcRel
  if(Test-Path -LiteralPath $cand){ $srcFile=$cand }
} else {
  if($path -eq "/"){
    $cand=Join-Path $RepoRoot "index.md"
    if(Test-Path -LiteralPath $cand){ $srcFile=$cand }
  } elseif($path -match '^/seiten/(.+)\.html$'){
    $cand=Join-Path $RepoRoot ("seiten\{0}.md" -f $Matches[1])
    if(Test-Path -LiteralPath $cand){ $srcFile=$cand }
  } elseif($path -match '^/pillar/(.+)\.html$'){
    $cand=Join-Path $RepoRoot ("pillar\{0}.md" -f $Matches[1])
    if(Test-Path -LiteralPath $cand){ $srcFile=$cand }
  }
}

# --- Output header (Chat-Contract: LIVE URL first) ---
"LIVE: {0}" -f $url
"IDX: {0}" -f $Idx
"PATH: {0}" -f $path
"INV_STATUS: {0}" -f $invStatus
"SOURCE: {0}" -f (if($srcFile){ $srcFile.Substring($RepoRoot.Length).TrimStart('\') } else { "MISSING_SOURCE_LOCAL" })
""

# --- TECH (local checks) ---
$techIssues=@()

if($srcFile){
  $txt=[IO.File]::ReadAllText($srcFile,$enc)

  if($txt -notmatch '(?s)\A---\s*.*?\s*---\s*'){ $techIssues += "NO_FRONTMATTER" }

  # permalink: must end .html for non-home; home must be /
  if($path -eq "/"){
    if($txt -notmatch '(?m)^\s*permalink:\s*/\s*$'){ $techIssues += "PERMALINK_NOT_ROOT" }
  } else {
    $expected=$path
    if($expected -notmatch '\.html$'){ $expected = ($expected.TrimEnd('/') + ".html") }
    $rx="(?m)^\s*permalink:\s*{0}\s*$" -f [regex]::Escape($expected)
    if($txt -notmatch $rx){ $techIssues += ("PERMALINK_MISMATCH expected " + $expected) }
  }

  # Weiter block: must exist and have 3 allowed internal html links
  if($txt -match '(?sm)^\s*##\s+Weiter\s*(.*?)(?:\n##\s|\z)'){
    $block=$Matches[0]
    $links=[regex]::Matches($block,'\[[^\]]+\]\(([^)]+)\)') | ForEach-Object { $_.Groups[1].Value.Trim() }
    if($links.Count -ne 3){ $techIssues += ("WEITER_LINKS_COUNT=" + $links.Count) }
    $bad=0
    foreach($u2 in $links){
      if($u2 -match '^(https?:)?//'){ $bad++ }
      elseif($u2 -notmatch '^(\{\{\s*site\.baseurl\s*\}\}|)/(seiten|pillar)/.+\.html$'){ $bad++ }
    }
    if($bad -gt 0){ $techIssues += ("WEITER_BAD_LINKS=" + $bad) }
  } else {
    $techIssues += "NO_WEITER_BLOCK"
  }

  # Quick hygiene
  if($txt -match '\.md\)'){ $techIssues += "FOUND_MD_LINK" }
  if($txt -match '(?i)\{\{\s*.*relative_url.*\}\}'){ $techIssues += "FOUND_relative_url_TOKEN" }

} else {
  $techIssues += "MISSING_SOURCE_LOCAL"
}

# --- Rendered Pflichtteile (LIVE HTML checks) ---
$renderIssues=@()
$spellingIssues=@()

function Has([string]$html,[string]$pattern){
  return [bool]([regex]::IsMatch($html,$pattern,'IgnoreCase,Singleline'))
}

try{
  $r=Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
  $html=$r.Content

  if(-not (Has $html '<h1[^>]*>.*?</h1>')){ $renderIssues += "NO_H1_RENDERED" }
  if(-not (Has $html '<link[^>]+rel="canonical"')){ $renderIssues += "NO_CANONICAL" }
  if(-not (Has $html 'href="[^"]*impressum')){ $renderIssues += "NO_IMPRESSUM_LINK" }
  if(-not (Has $html 'href="[^"]*datenschutz')){ $renderIssues += "NO_DATENSCHUTZ_LINK" }

  # Pflicht-Blocks (robust; spelling separate)
  if(-not (Has $html 'Hinweis\s*\(wichtig\)')){ $renderIssues += "NO_HINWEIS_WICHTIG" }
  if(-not (Has $html 'KI[- ]Hinweis')){ $renderIssues += "NO_KI_HINWEIS" }

  # Audit heading: must be correct spelling "Aktualität" (flag Aktualitaet)
  if(Has $html 'Aktualitaet\s+und\s+Audit[-– ]Hinweis'){
    $spellingIssues += "SPELLING: 'Aktualitaet' -> must be 'Aktualität'"
  }
  if(-not (Has $html 'Aktualit[aä]t\s+und\s+Audit[-– ]Hinweis')){
    $renderIssues += "NO_AKTUALITAET_AUDIT_HINWEIS"
  }

  # Weiter rendered (optional on some pages, but usually expected)
  if(-not (Has $html '>\s*Weiter\s*<')){ $renderIssues += "NO_WEITER_RENDERED" }

} catch {
  $renderIssues += ("LIVE_FETCH_ERR: " + $_.Exception.Message)
}

# --- Print checklist ---
"CHECKLIST:"
"- TECH: " + (if($techIssues.Count -eq 0){ "PASS" } else { "FAIL" })
"- Rendered Pflichtteile: " + (if($renderIssues.Count -eq 0){ "PASS" } else { "FAIL" })
"- Rechtschreibung (kritisch): " + (if($spellingIssues.Count -eq 0){ "PASS" } else { "WARN" })
""

if($techIssues.Count -gt 0){
  "TECH_ISSUES:"
  $techIssues | ForEach-Object { " - " + $_ }
  ""
}
if($renderIssues.Count -gt 0){
  "RENDER_ISSUES:"
  $renderIssues | ForEach-Object { " - " + $_ }
  ""
}
if($spellingIssues.Count -gt 0){
  "SPELLING:"
  $spellingIssues | ForEach-Object { " - " + $_ }
  ""
}

# Exit code: 0 only if TECH+Rendered PASS (spelling warns don't fail build, but are actionable)
if($techIssues.Count -gt 0 -or $renderIssues.Count -gt 0){
  exit 2
}
exit 0
