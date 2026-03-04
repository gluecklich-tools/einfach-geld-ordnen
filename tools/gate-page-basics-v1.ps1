param(
  [Parameter(Mandatory=$true)][string]$RepoRoot,
  [Parameter(Mandatory=$true)][string[]]$TargetsRel,
  [switch]$FailFast
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

if(!(Test-Path -LiteralPath $RepoRoot)){ throw "STOP: repo missing: $RepoRoot" }

function IsAsciiOnly([string]$s){
  foreach($ch in $s.ToCharArray()){
    if([int]$ch -gt 127){ return $false }
  }
  return $true
}

function HasBomUtf8([string]$path){
  $b = [IO.File]::ReadAllBytes($path)
  if($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF){ return $true }
  return $false
}

function ReadUtf8NoBom([string]$p){
  $enc=[Text.UTF8Encoding]::new($false)
  return [IO.File]::ReadAllText($p,$enc)
}

function FindFrontmatterEnd([string[]]$lines){
  if($lines.Count -lt 3){ return -1 }
  if($lines[0].Trim() -ne '---'){ return -1 }
  for($i=1;$i -lt $lines.Count;$i++){
    if($lines[$i].Trim() -eq '---'){ return $i }
  }
  return -1
}

function GetFmValue([string]$fm,[string]$key){
  $m=[regex]::Match($fm,"(^|`n)"+[regex]::Escape($key)+":\s*(.+?)\s*($|`n)",[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if(!$m.Success){ return $null }
  return $m.Groups[2].Value.Trim()
}

function CountWeiterLinksExact3([string[]]$bodyLines){
  $idx=-1
  for($i=0;$i -lt $bodyLines.Count;$i++){
    if($bodyLines[$i].Trim() -eq '## Weiter'){ $idx=$i; break }
  }
  if($idx -lt 0){ return @{ ok=$false; count=0; reason='missing' } }

  $cnt=0
  for($j=$idx+1;$j -lt $bodyLines.Count;$j++){
    $t=$bodyLines[$j].Trim()
    if($t.StartsWith('## ')){ break }
    if($t.Length -eq 0){ continue }
    if($t -match '^\-\s+\[.+\]\((.+)\)\s*$'){
      $href = $Matches[1]
      if($href -eq '#'){ continue } # (#) zählt nicht
      $cnt++
      continue
    }
    if($t -match '\{\%\s*include\s+'){ return @{ ok=$false; count=$cnt; reason='include_in_weiter' } }
  }

  if($cnt -ne 3){ return @{ ok=$false; count=$cnt; reason='count' } }
  return @{ ok=$true; count=$cnt; reason='ok' }
}

function CheckFile([string]$rel){
  $abs = Join-Path $RepoRoot $rel
  if(!(Test-Path -LiteralPath $abs)){ return @("MISSING_FILE: $rel") }

  $fails=@()

  if(!(IsAsciiOnly $rel)){ $fails += "ASCII_PATH_FAIL: $rel" }
  if(HasBomUtf8 $abs){ $fails += "UTF8_BOM_FAIL: $rel" }

  $txt = ReadUtf8NoBom $abs
  $lines = $txt -split "`r?`n"
  $fmEnd = FindFrontmatterEnd $lines
  if($fmEnd -lt 0){
    $fails += "FRONTMATTER_FENCE_FAIL: $rel"
    return $fails
  }

  $fm = ($lines[1..($fmEnd-1)] -join "`n")
  $title = GetFmValue $fm 'title'
  $perma = GetFmValue $fm 'permalink'

  if([string]::IsNullOrWhiteSpace($title)){ $fails += "FM_MISSING_TITLE: $rel" }
  if([string]::IsNullOrWhiteSpace($perma)){ $fails += "FM_MISSING_PERMALINK: $rel" }
  else {
    if(!$perma.StartsWith('/')){ $fails += "FM_PERMALINK_NOT_ABS: $rel ($perma)" }
    if(!$perma.EndsWith('.html')){ $fails += "FM_PERMALINK_NOT_HTML: $rel ($perma)" }
    if($rel -match '^(?i)pillar[\\/].+\.md$' -and !$perma.StartsWith('/pillar/')){
      $fails += "FM_PERMALINK_NOT_PILLAR: $rel ($perma)"
    }
  }

  $body = ''
  if($fmEnd + 1 -le $lines.Count-1){
    $body = ($lines[($fmEnd+1)..($lines.Count-1)] -join "`n")
  }
  $bodyLines = $body -split "`r?`n"

  $first=$null
  foreach($ln in @($bodyLines)){
    if($ln.Trim().Length -eq 0){ continue }
    $first=$ln.Trim(); break
  }
  if($null -eq $first -or $first -notmatch '^#\s+\S'){ $fails += "H1_FAIL: $rel" }

  $w = CountWeiterLinksExact3 $bodyLines
  if(-not $w.ok){
    if($w.reason -eq 'missing'){ $fails += "WEITER_MISSING: $rel" }
    elseif($w.reason -eq 'include_in_weiter'){ $fails += "WEITER_INCLUDE_FAIL: $rel" }
    else { $fails += "WEITER_LINKS_NOT_3($($w.count)): $rel" }
  }

  if($txt -notmatch '\{\%\s*include\s+no_sackgasse_footer\.html\s*\%\}'){
    $fails += "FOOTER_INCLUDE_MISSING: $rel"
  }
  if($txt -match '\{\{\s*site\.baseurl\s*\}\}\s*\{\%\s*include\s+no_sackgasse_footer\.html\s*\%\}'){
    $fails += "FOOTER_INCLUDE_BASEURL_FORBIDDEN: $rel"
  }

  return $fails
}

$failsAll=@()
foreach($rel in @($TargetsRel)){
  $f = CheckFile $rel
  foreach($x in @($f)){
    $failsAll += $x
    if($FailFast){ break }
  }
  if($FailFast -and $failsAll.Count -gt 0){ break }
}

if($failsAll.Count -gt 0){
  "GATE_PAGE_BASICS_V1: FAIL"
  foreach($x in @($failsAll)){ " - $x" }
  throw "STOP: GATE_PAGE_BASICS_V1 failed ($($failsAll.Count))"
}

"GATE_PAGE_BASICS_V1: PASS ($($TargetsRel.Count))"
