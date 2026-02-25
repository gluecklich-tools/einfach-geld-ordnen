#requires -Version 7.0
param(
  [Parameter()][string]$RepoRoot = '',
  [Parameter()][string]$BaseUrl  = 'https://gluecklich-tools.github.io/einfach-geld-ordnen',
  [Parameter()][string]$InventoryTsv = '',
  [Parameter()][string]$OutDir = ''
)
# --- MOVED BELOW param(...) by fix_paramfirst (20260225_201919) ---
[CmdletBinding()]
# --- END MOVED BLOCK ---


$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$enc=[Text.UTF8Encoding]::new($false)
function Resolve-RepoRoot([string]$rr){
  if(-not [string]::IsNullOrWhiteSpace($rr)){ return $rr }
  try{
    $g=(git rev-parse --show-toplevel 2>$null)
    if($g){ $g=$g.Trim() }
    if(-not [string]::IsNullOrWhiteSpace($g)){ return $g }
  } catch {}
  # fallback: script is in tools\ -> repo root is parent
  try{
    return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
  } catch {
    return $PSScriptRoot
  }
}

function Die([string]$m){ throw $m }
function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }
$RepoRoot = Resolve-RepoRoot $RepoRoot
if(!(Test-Path -LiteralPath $RepoRoot)){ Die ('STOP: RepoRoot not found: ' + $RepoRoot) }

if([string]::IsNullOrWhiteSpace($InventoryTsv)){
  $InventoryTsv = Join-Path $RepoRoot '_local\rereview\rr_queue.tsv'
}
if(!(Test-Path -LiteralPath $InventoryTsv)){ Die ('STOP: Inventory TSV missing: ' + $InventoryTsv) }

if([string]::IsNullOrWhiteSpace($OutDir)){
  $OutDir = Join-Path $RepoRoot '_local\flow'
}
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# --- Inventory loader (headerless): IDX | ABS_URL | REL_PATH | SOURCE_ABS ---
$rows=@()
$i=0
Get-Content -LiteralPath $InventoryTsv -Encoding UTF8 | ForEach-Object {
  $line=$_.TrimEnd()
  if([string]::IsNullOrWhiteSpace($line)){ return }
  $parts=$line -split "`t"
  if($parts.Count -lt 4){ return } # skip junk
  $rows += [pscustomobject]@{
    Idx       = $parts[0].Trim()
    AbsUrl    = $parts[1].Trim()
    RelPath   = $parts[2].Trim()
    SourceAbs = $parts[3].Trim()
  }
  $i++
}

if($rows.Count -lt 1){ Die 'STOP: Inventory had no usable rows.' }

# --- Build known targets set from inventory (ABS_URL + relative path from BaseUrl) ---
$known=@{}
foreach($r in $rows){
  if(-not [string]::IsNullOrWhiteSpace($r.AbsUrl)){
    $known[$r.AbsUrl.ToLowerInvariant()]=$true
    if($r.AbsUrl.StartsWith($BaseUrl,[StringComparison]::OrdinalIgnoreCase)){
      $rel = $r.AbsUrl.Substring($BaseUrl.Length)
      if([string]::IsNullOrWhiteSpace($rel)){ $rel='/' }
      $known[$rel.ToLowerInvariant()]=$true
    }
  }
}

function NormalizeLink([string]$href){
  if([string]::IsNullOrWhiteSpace($href)){ return $null }
  $h=$href.Trim()

  # drop fragments
  $hash=$h.IndexOf('#')
  if($hash -ge 0){ $h=$h.Substring(0,$hash) }

  # drop mailto/tel/javascript
  if($h -match '^(mailto:|tel:|javascript:)'){ return $null }

  # ignore empty
  if([string]::IsNullOrWhiteSpace($h)){ return $null }

  # de-liquid baseurl patterns to a comparable form
  $h=$h -replace '\{\{\s*site\.baseurl\s*\}\}',''
  $h=$h -replace '\{\{\s*site\.baseurl\s*\}\}',''
  $h=$h -replace '\|\s*relative_url\s*','' # defensive (should not exist)

  # collapse double slashes (but keep https://)
  if($h -notmatch '^https?://'){
    while($h.Contains('//')){ $h=$h.Replace('//','/') }
  }

  return $h
}

function ClassifyLink([string]$norm){
  if([string]::IsNullOrWhiteSpace($norm)){ return $null }
  if($norm -match '^https?://'){ return 'abs' }
  if($norm.StartsWith('/')){ return 'rootrel' }
  return 'rel'
}

function ToComparableTarget([string]$norm){
  if([string]::IsNullOrWhiteSpace($norm)){ return $null }
  $n=$norm
  if($n -match '^https?://'){
    # if BaseUrl internal -> relative comparable too
    if($n.StartsWith($BaseUrl,[StringComparison]::OrdinalIgnoreCase)){
      $rel=$n.Substring($BaseUrl.Length)
      if([string]::IsNullOrWhiteSpace($rel)){ $rel='/' }
      return @($n.ToLowerInvariant(), $rel.ToLowerInvariant())
    }
    return @($n.ToLowerInvariant())
  }

  # root-relative is already comparable
  if($n.StartsWith('/')){ return @($n.ToLowerInvariant()) }

  # relative -> treat as-is (rare in repo; still keep)
  return @($n.ToLowerInvariant())
}

# --- Extract "Weiter" links (exactly what matters for loops) ---
function GetWeiterLinksFromMd([string]$md){
  $res=@()
  if([string]::IsNullOrWhiteSpace($md)){ return $res }

  # Find section starting at heading "## Weiter" (or "## WEITER") until next heading "## "
  $m=[regex]::Match($md,'(?is)^\s*##\s*Weiter\s*$.*?(?=^\s*##\s+|\z)','Multiline')
  if(-not $m.Success){ return $res }

  $block=$m.Value
  # Markdown links: [text](href)
  foreach($mm in [regex]::Matches($block,'\[[^\]]*\]\(([^)]+)\)')){
    $href=$mm.Groups[1].Value
    $n=NormalizeLink $href
    if($n){ $res += $n }
  }
  return $res
}

# --- Extract frontmatter next/prev/hub as edges too (for broader cycle detection) ---
function GetFrontmatterNav([string]$md){
  $out=[ordered]@{ next=$null; prev=$null; hub=$null }
  $fm=[regex]::Match($md,'(?s)\A---\s*(.*?)\s*---\s*')
  if(-not $fm.Success){ return $out }
  $body=$fm.Groups[1].Value
  foreach($k in @('next','prev','hub')){
    $mm=[regex]::Match($body,'(?im)^\s*' + $k + '\s*:\s*(.+?)\s*$')
    if($mm.Success){
      $v=$mm.Groups[1].Value.Trim()
      $v=$v.Trim('"').Trim("'")
      $n=NormalizeLink $v
      if($n){ $out[$k]=$n }
    }
  }
  return $out
}

$edges=@()
foreach($r in $rows){
  $srcUrl=$r.AbsUrl
  $srcKey=$srcUrl.ToLowerInvariant()

  $srcMdPath=$r.SourceAbs
  if([string]::IsNullOrWhiteSpace($srcMdPath) -or !(Test-Path -LiteralPath $srcMdPath)){ continue }
  $md=ReadUtf8 $srcMdPath

  # weiter edges
  foreach($t in (GetWeiterLinksFromMd $md)){
    $edges += [pscustomobject]@{ kind='weiter'; src=$srcUrl; dst=$t; src_file=$srcMdPath }
  }

  # nav edges
  $nav=GetFrontmatterNav $md
  foreach($k in @('next','prev','hub')){
    if($nav[$k]){
      $edges += [pscustomobject]@{ kind=$k; src=$srcUrl; dst=$nav[$k]; src_file=$srcMdPath }
    }
  }
}

# --- Evaluate targets ---
$broken=@()
foreach($e in $edges){
  $dstNorm = NormalizeLink $e.dst
  if(-not $dstNorm){ continue }
  $cands = ToComparableTarget $dstNorm
  $ok=$false
  foreach($c in $cands){
    if($known.ContainsKey($c)){ $ok=$true; break }
  }
  if(-not $ok -and ($dstNorm -match '^/|^https?://')){
    $broken += [pscustomobject]@{ kind=$e.kind; src=$e.src; dst=$dstNorm; src_file=$e.src_file }
  }
}

# --- Build graph for cycle checks (use ALL edges) ---
$adj=@{}
foreach($e in $edges){
  $s=$e.src
  $d=(NormalizeLink $e.dst)
  if(-not $d){ continue }
  if(-not $adj.ContainsKey($s)){ $adj[$s]=@() }
  $adj[$s] += [pscustomobject]@{ kind=$e.kind; dst=$d }
}

# Dead ends in WEITER graph: pages with no weiter out
$weiterOut=@{}
foreach($r in $rows){ $weiterOut[$r.AbsUrl]=0 }
foreach($e in $edges){
  if($e.kind -eq 'weiter'){
    if($weiterOut.ContainsKey($e.src)){ $weiterOut[$e.src]++ }
  }
}
$deadWeiter=@()
foreach($k in $weiterOut.Keys){
  if($weiterOut[$k] -eq 0){ $deadWeiter += $k }
}

# 2-cycles in WEITER
$weiterPairs=@{}
foreach($e in $edges){
  if($e.kind -ne 'weiter'){ continue }
  $a=$e.src
  $b=(NormalizeLink $e.dst)
  if(-not $b){ continue }
  $weiterPairs["$a`t$b"]=$true
}
$twoCycles=@()
foreach($k in $weiterPairs.Keys){
  $p=$k -split "`t"
  $a=$p[0]; $b=$p[1]
  $rev="$b`t$a"
  if($weiterPairs.ContainsKey($rev)){
    # stable order to avoid duplicates
    if([string]::Compare($a,$b,$true) -lt 0){
      $twoCycles += [pscustomobject]@{ a=$a; b=$b }
    }
  }
}

# --- Write outputs ---
$edgesTsv=Join-Path $OutDir 'edges.tsv'
$report =Join-Path $OutDir 'flow_report.md'

$edges | Sort-Object kind,src,dst | ForEach-Object {
  [string]::Join("`t", @($_.kind,$_.src,$_.dst,$_.src_file))
} | Set-Content -LiteralPath $edgesTsv -Encoding UTF8

$now=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
$md=@()
$md += "# Flow Report"
$md += ""
$md += "Generated: $now"
$md += ""
$md += "Inventory: $InventoryTsv"
$md += ""
$md += "Edges: $edgesTsv"
$md += ""

$md += "## Summary"
$md += ""
$md += "* Pages in inventory: $($rows.Count)"
$md += "* Total edges: $($edges.Count)"
$md += "* Broken internal targets: $($broken.Count)"
$md += "* Dead ends (no WEITER out): $($deadWeiter.Count)"
$md += "* 2-cycles (WEITER A<->B): $($twoCycles.Count)"
$md += ""

$md += "## Broken targets (internal-ish)"
$md += ""
if($broken.Count -eq 0){
  $md += "_None_"
} else {
  foreach($b in ($broken | Sort-Object kind,src,dst | Select-Object -First 200)){
    $md += ("- **{0}**: {1} -> {2}" -f $b.kind,$b.src,$b.dst)
  }
  if($broken.Count -gt 200){ $md += ""; $md += "_Truncated to first 200._" }
}
$md += ""

$md += "## Dead ends (no WEITER out)"
$md += ""
if($deadWeiter.Count -eq 0){
  $md += "_None_"
} else {
  foreach($d in ($deadWeiter | Sort-Object | Select-Object -First 200)){
    $md += ("- {0}" -f $d)
  }
  if($deadWeiter.Count -gt 200){ $md += ""; $md += "_Truncated to first 200._" }
}
$md += ""

$md += "## 2-cycles in WEITER"
$md += ""
if($twoCycles.Count -eq 0){
  $md += "_None_"
} else {
  foreach($c in ($twoCycles | Sort-Object a,b | Select-Object -First 200)){
    $md += ("- {0} <-> {1}" -f $c.a,$c.b)
  }
  if($twoCycles.Count -gt 200){ $md += ""; $md += "_Truncated to first 200._" }
}
$md += ""

$md | Set-Content -LiteralPath $report -Encoding UTF8

"OK: wrote $edgesTsv"
"OK: wrote $report"