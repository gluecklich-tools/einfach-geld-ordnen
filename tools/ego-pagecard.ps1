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

function ReadUtf8([string]$p){
  return [IO.File]::ReadAllText($p,$enc)
}

function Has([string]$html,[string]$pattern){
  return [bool]([regex]::IsMatch($html,$pattern,([Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::Singleline)))
}

# RepoRoot resolve: prefer explicit, else git, else script root
if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $tmp=$null
  try { $tmp = (git rev-parse --show-toplevel 2>$null) } catch { $tmp=$null }
  $tmp=[string]$tmp
  if(-not [string]::IsNullOrWhiteSpace($tmp)){
    $RepoRoot=$tmp.Trim()
  }
}
if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $RepoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
}
if(!(Test-Path -LiteralPath $RepoRoot)){
  throw "STOP: RepoRoot invalid: $RepoRoot"
}

if(!(Test-Path -LiteralPath $InventoryTsv)){
  throw "STOP: InventoryTsv missing: $InventoryTsv"
}

# Parse TSV row by idx
$lines=[IO.File]::ReadAllLines($InventoryTsv,$enc)
if($lines.Count -lt 2){ throw "STOP: inventory empty" }

$startIndex = 0
if($lines.Length -gt 0 -and -not ($lines[0] -match '^\s*\d+\t')){
  $startIndex = 1
}

$row=$null
for($i=$startIndex; $i -lt $lines.Length; $i++){
  $ln = $lines[$i]
  if([string]::IsNullOrWhiteSpace($ln)){ continue }
  $c=$ln -split "`t", 4
  if($c.Count -lt 4){ continue }
  if($c[0].Trim() -eq $Idx.ToString()){
    $row=$c; break
  }
}
if($null -eq $row){ throw "STOP: idx not found: $Idx" }

$url=$row[1].Trim()     # ABS live URL (for fetch)
$path=$row[2].Trim()    # REL path (/... for local mapping)
$invStatus = $row[3].Trim()  # ABS local source path (preferred)
$srcRel  = ""  # TSV is 4 cols; no repo-relative source here

# Resolve source file
$srcFile=""
if($invStatus -and (Test-Path -LiteralPath $invStatus)){
  $srcFile = $invStatus
}
if($srcRel){
  $cand=Join-Path $RepoRoot $srcRel
  if(Test-Path -LiteralPath $cand){ $srcFile=$cand }
} else {
  if($path -eq "/"){
    $cand=Join-Path $RepoRoot "index.md"
    if(Test-Path -LiteralPath $cand){ $srcFile=$cand }
  } elseif($path -match "^/seiten/(.+)\.html$"){
    $cand=Join-Path $RepoRoot ("seiten\{0}.md" -f $Matches[1])
    if(Test-Path -LiteralPath $cand){ $srcFile=$cand }
  } elseif($path -match "^/pillar/(.+)\.html$"){
    $cand=Join-Path $RepoRoot ("pillar\{0}.md" -f $Matches[1])
    if(Test-Path -LiteralPath $cand){ $srcFile=$cand }
  }
}

# Chat-Contract: LIVE URL first
Write-Output ("LIVE: {0}" -f $url)
Write-Output ("IDX: {0}" -f $Idx)
Write-Output ("PATH: {0}" -f $path)
Write-Output ("INV_STATUS: {0}" -f $invStatus)
$sourceDisplay = if($srcFile){ $srcFile.Substring($RepoRoot.Length).TrimStart('\') } else { 'MISSING_SOURCE_LOCAL' }
Write-Output ("SOURCE: {0}" -f $sourceDisplay)
Write-Output ""

# TECH checks (local)
$tech=@()

if($srcFile){
  $txt=ReadUtf8 $srcFile

  if($txt -notmatch "(?s)\A---\s*.*?\s*---\s*"){ $tech += "NO_FRONTMATTER" }

  if($path -eq "/"){
    if($txt -notmatch "(?m)^\s*permalink:\s*/\s*$"){ $tech += "PERMALINK_NOT_ROOT" }
  } else {
    $expected=$path
    if($expected -notmatch "\.html$"){ $expected=($expected.TrimEnd('/') + ".html") }
    $rx="(?m)^\s*permalink:\s*{0}\s*$" -f [regex]::Escape($expected)
    if($txt -notmatch $rx){ $tech += ("PERMALINK_MISMATCH expected " + $expected) }
  }

  if($txt -match "(?sm)^\s*##\s+Weiter\s*(.*?)(?:\n##\s|\z)"){
    $block=$Matches[0]
    $links=[regex]::Matches($block,'\[[^\]]+\]\(([^)]+)\)') | ForEach-Object { $_.Groups[1].Value.Trim() }
    if($links.Count -ne 3){ $tech += ("WEITER_LINKS_COUNT=" + $links.Count) }
    $bad=0
    foreach($u2 in $links){
      if($u2 -match "^(https?:)?//"){ $bad++ }
      elseif($u2 -notmatch "^(\{\{\s*site\.baseurl\s*\}\}|)/(seiten|pillar)/.+\.html$"){ $bad++ }
    }
    if($bad -gt 0){ $tech += ("WEITER_BAD_LINKS=" + $bad) }
  } else {
    $tech += "NO_WEITER_BLOCK"
  }

  if($txt -match "\.md\)"){ $tech += "FOUND_MD_LINK" }
  if($txt -match "(?i)\{\{\s*.*relative_url.*\}\}"){ $tech += "FOUND_relative_url_TOKEN" }

} else {
  $tech += "MISSING_SOURCE_LOCAL"
}

# Rendered checks (LIVE)
# policy_blocks gating (default=hide)
$policyShow = $false
try{
  $fmAll = [IO.File]::ReadAllText($srcFile,$enc)
  if($fmAll -match "(?s)\A---\s*.*?\s*---\s*"){
    $front = $Matches[0]
    if($front -match "(?im)^\s*policy_blocks\s*:\s*show\s*$"){ $policyShow = $true }
  }
}catch{}

$render=@()
$hasHint = $false
$hasKi = $false
$hasAudit = $false

$spelling=@()

try{
  $r=Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
  $html=$r.Content

  if(-not (Has $html "<h1[^>]*>.*?</h1>")){ $render += "NO_H1_RENDERED" }
  if(-not (Has $html "<link[^>]+rel=""canonical""")){ $render += "NO_CANONICAL" }
  if(-not (Has $html "href=""[^""]*impressum")){ $render += "NO_IMPRESSUM_LINK" }
  if(-not (Has $html "href=""[^""]*datenschutz")){ $render += "NO_DATENSCHUTZ_LINK" }
  $hasHintReq = Has $html "(Hinweis|Wichtig)"
  $hasHintLeak = Has $html "Hinweis\s*\(wichtig\)"
  if($policyShow){
    if($policyShow){  if(-not $hasHintReq){ $render += "NO_HINWEIS_WICHTIG" }} else {  if($hasHintLeak){ $render += "LEAK_HINWEIS_WICHTIG" }}
  } else {
    if($hasHint){ $render += "LEAK_HINWEIS_WICHTIG" }
  }
  $hasKiReq = Has $html "\bKI\b|Künstliche Intelligenz|Kuenstliche Intelligenz"
  $hasKiLeak = Has $html "KI[- ]Hinweis"
  if($policyShow){
    if($policyShow){  if(-not $hasKiReq){ $render += "NO_KI_HINWEIS" }} else {  if($hasKiLeak){ $render += "LEAK_KI_HINWEIS" }}
  } else {
    if($hasKi){ $render += "LEAK_KI_HINWEIS" }
  }

  if(Has $html "Aktualitaet\s+und\s+Audit[-– ]Hinweis"){
    $spelling += "SPELLING: Aktualitaet -> Aktualität"
  }
  if(-not (Has $html "Aktualit(aet|[aä]t)\s+und\s+Audit[-– ]Hinweis")){
    $hasAuditReq = Has $html "Aktualit(aet|[aä]t)\s+und\s+Audit"
    $hasAuditLeak = Has $html "Aktualit(aet|[aä]t)\s+und\s+Audit[-– ]Hinweis"
    if($policyShow){
      if($policyShow){  if(-not $hasAuditReq){ $render += "NO_AKTUALITAET_AUDIT_HINWEIS" }} else {  if($hasAuditLeak){ $render += "LEAK_AKTUALITAET_AUDIT_HINWEIS" }}
    } else {
      if($hasAudit){ $render += "LEAK_AKTUALITAET_AUDIT_HINWEIS" }
    }
  }

  if(-not (Has $html ">\s*Weiter\s*<")){ $render += "NO_WEITER_RENDERED" }
} catch {
  $render += ("LIVE_FETCH_ERR: " + $_.Exception.Message)
}

$techStatus   = if($tech.Count   -eq 0){ "PASS" } else { "FAIL" }
$renderStatus = if($render.Count -eq 0){ "PASS" } else { "FAIL" }
$spellStatus  = if($spelling.Count -eq 0){ "PASS" } else { "WARN" }

Write-Output "CHECKLIST:"
Write-Output ("- TECH: " + $techStatus)
Write-Output ("- Rendered Pflichtteile: " + $renderStatus)
Write-Output ("- Rechtschreibung (kritisch): " + $spellStatus)
Write-Output ""

if($tech.Count -gt 0){
  Write-Output "TECH_ISSUES:"
  $tech | ForEach-Object { Write-Output (" - " + $_) }
  Write-Output ""
}
if($render.Count -gt 0){
  Write-Output "RENDER_ISSUES:"
  $render | ForEach-Object { Write-Output (" - " + $_) }
  Write-Output ""
}
if($spelling.Count -gt 0){
  Write-Output "SPELLING:"
  $spelling | ForEach-Object { Write-Output (" - " + $_) }
  Write-Output ""
}

if($tech.Count -gt 0 -or $render.Count -gt 0){ exit 2 }
exit 0