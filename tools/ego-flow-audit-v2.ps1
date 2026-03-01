#requires -Version 7.0
# ALLOW_REGEX_PATCH (temporary; must be removed when refactored to literal/AST patching)
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

function Die([string]$m){ throw $m }
function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }

function Resolve-RepoRoot([string]$rr){
  if(-not [string]::IsNullOrWhiteSpace($rr)){ return $rr }
  try{
    $g=(git rev-parse --show-toplevel 2>$null)
    if($g){ $g=$g.Trim() }
    if(-not [string]::IsNullOrWhiteSpace($g)){ return $g }
  } catch {}
  try{ return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path } catch { return $PSScriptRoot }
}

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

# Inventory: IDX | ABS_URL | REL_PATH | SOURCE_ABS
$rows=@()
Get-Content -LiteralPath $InventoryTsv -Encoding UTF8 | ForEach-Object {
  $line=$_.TrimEnd()
  if([string]::IsNullOrWhiteSpace($line)){ return }
  $parts=$line -split "`t"
  if($parts.Count -lt 4){ return }
  $rows += [pscustomobject]@{
    Idx       = $parts[0].Trim()
    AbsUrl    = $parts[1].Trim()
    RelPath   = $parts[2].Trim()
    SourceAbs = $parts[3].Trim()
  }
}
if($rows.Count -lt 1){ Die 'STOP: Inventory had no usable rows.' }

# Known targets (absolute + baseurl-relative)
$known=@{}
foreach($r in $rows){
  if(-not [string]::IsNullOrWhiteSpace($r.AbsUrl)){
    $known[$r.AbsUrl.ToLowerInvariant()]=$true
    if($r.AbsUrl.StartsWith($BaseUrl,[StringComparison]::OrdinalIgnoreCase)){
      $rel=$r.AbsUrl.Substring($BaseUrl.Length)
      if([string]::IsNullOrWhiteSpace($rel)){ $rel='/' }
      $known[$rel.ToLowerInvariant()]=$true
    }
  }
}

function NormalizeLink([string]$href){
  if([string]::IsNullOrWhiteSpace($href)){ return $null }
$h=$href.Trim()
  $q=$h.IndexOf('?')
  if($q -ge 0){ $h=$h.Substring(0,$q) }
  $hash=$h.IndexOf('#')
  if($hash -ge 0){ $h=$h.Substring(0,$hash) }
  if($h -match '^(mailto:|tel:|javascript:)'){ return $null }
  if([string]::IsNullOrWhiteSpace($h)){ return $null }
  $h=$h -replace '\{\{\s*site\.baseurl\s*\}\}',''
  if($h -notmatch '^https?://'){
    while($h.Contains('//')){ $h=$h.Replace('//','/') }
  }
  return $h
}
function IsDownloadsPath([string]$dst){
  if([string]::IsNullOrWhiteSpace($dst)){ return $false }
  if($dst.StartsWith('/downloads/',[StringComparison]::OrdinalIgnoreCase)){ return $true }
  if($dst.StartsWith('downloads/',[StringComparison]::OrdinalIgnoreCase)){ return $true }
  return $false
}
function RepoPageExistsFromSeitenHtml([string]$dst){
  if([string]::IsNullOrWhiteSpace($dst)){ return $false }
  if(-not $dst.StartsWith('/seiten/',[StringComparison]::OrdinalIgnoreCase)){ return $false }
  if(-not $dst.EndsWith('.html',[StringComparison]::OrdinalIgnoreCase)){ return $false }

  $name = [IO.Path]::GetFileNameWithoutExtension($dst)
  if([string]::IsNullOrWhiteSpace($name)){ return $false }

  $md = Join-Path $RepoRoot ('seiten\' + $name + '.md')
  return (Test-Path -LiteralPath $md)
}
function DownloadExistsInRepo([string]$dst){
  if([string]::IsNullOrWhiteSpace($dst)){ return $false }
  $p=$dst
  if($p.StartsWith('/')){ $p=$p.Substring(1) }
  # normalize slashes
  while($p.Contains('//')){ $p=$p.Replace('//','/') }
  $abs = Join-Path $RepoRoot ($p -replace '/','\')
  return (Test-Path -LiteralPath $abs)
}
function ToComparableTarget([string]$norm){
  if([string]::IsNullOrWhiteSpace($norm)){ return @() }
  $n=$norm
  if($n -match '^https?://'){
    if($n.StartsWith($BaseUrl,[StringComparison]::OrdinalIgnoreCase)){
      $rel=$n.Substring($BaseUrl.Length)
      if([string]::IsNullOrWhiteSpace($rel)){ $rel='/' }
      return @($n.ToLowerInvariant(), $rel.ToLowerInvariant())
    }
    return @($n.ToLowerInvariant())
  }
  if($n.StartsWith('/')){ return @($n.ToLowerInvariant()) }
  return @($n.ToLowerInvariant())
}

function ExtractBodyLinks([string]$md){
  $res=@()

  # strip frontmatter quickly
  $body=$md
  $fm=[regex]::Match($md,'(?s)\A---\s*.*?\s*---\s*')
  if($fm.Success){ $body=$md.Substring($fm.Length) }

  # markdown links
  foreach($m in [regex]::Matches($body,'\[[^\]]+\]\(([^)]+)\)')){
    $n=NormalizeLink $m.Groups[1].Value
    if($n){ $res += [pscustomobject]@{ href=$n; kind='body_md' } }
  }

  # html href
  foreach($m in [regex]::Matches($body,'href\s*=\s*["'']([^"'']+)["'']')){
    $n=NormalizeLink $m.Groups[1].Value
    if($n){ $res += [pscustomobject]@{ href=$n; kind='body_html' } }
  }

  return $res
}

$edges=@()
foreach($r in $rows){
  if([string]::IsNullOrWhiteSpace($r.SourceAbs) -or !(Test-Path -LiteralPath $r.SourceAbs)){ continue }
  $md=ReadUtf8 $r.SourceAbs
  foreach($l in (ExtractBodyLinks $md)){
    $edges += [pscustomobject]@{
      kind='body'
      src=$r.AbsUrl
      dst=$l.href
      src_file=$r.SourceAbs
      subkind=$l.kind
    }
  }
}

# keep only internal-ish (BaseUrl or root-relative)
$intEdges=@()
foreach($e in $edges){
  $d=NormalizeLink $e.dst
  if(-not $d){ continue }
  if($d.StartsWith('/') -or $d.StartsWith($BaseUrl,[StringComparison]::OrdinalIgnoreCase)){
    $intEdges += [pscustomobject]@{ kind=$e.kind; src=$e.src; dst=$d; src_file=$e.src_file; subkind=$e.subkind }
  }
}

# Broken internal targets
$broken=@()
foreach($e in $intEdges){
  $cands=ToComparableTarget $e.dst
  $ok=$false
  foreach($c in $cands){ if($known.ContainsKey($c)){ $ok=$true; break } }
  if(-not $ok){
  if(IsDownloadsPath $e.dst){
    if(-not (DownloadExistsInRepo $e.dst)){ $broken += $e }
  } elseif(RepoPageExistsFromSeitenHtml $e.dst){
    # ok (page exists as seiten\<name>.md even if not in inventory yet)
  } else {
    $broken += $e
  }
}
}

# Graph for cycles
$adj=@{}
foreach($e in $intEdges){
  if(-not $adj.ContainsKey($e.src)){ $adj[$e.src]=@() }
  $adj[$e.src] += $e.dst
}

# DFS cycle detection (bounded)
$cycles=@()
$state=@{} # 0=unseen,1=visiting,2=done
$stack = [System.Collections.Generic.List[string]]::new()
function Dfs([string]$u){
  $state[$u]=1
$script:stack.Add($u)
  if($adj.ContainsKey($u)){
    foreach($v in $adj[$u]){
      if(-not $state.ContainsKey($v)){ $state[$v]=0 }
      if($state[$v] -eq 0){
        Dfs $v
      } elseif($state[$v] -eq 1){
        # found back-edge -> cycle
        $idx = [Array]::LastIndexOf($script:stack,$v)
        if($idx -ge 0){
          $cy = $script:stack[$idx..($script:stack.Count-1)] + @($v)
          $cycles += ,([string]::Join(' -> ',$cy))
        }
      }
    }
  }
$null = $script:stack.RemoveAt($script:stack.Count-1)
  $state[$u]=2
}

foreach($r in $rows){
  $u=$r.AbsUrl
  if(-not $state.ContainsKey($u)){ $state[$u]=0 }
  if($state[$u] -eq 0){ Dfs $u }
}

# Outputs
$edgesTsv=Join-Path $OutDir 'edges_body.tsv'
$report =Join-Path $OutDir 'flow_report_body.md'

$intEdges | Sort-Object src,dst | ForEach-Object {
  [string]::Join("`t", @($_.kind,$_.src,$_.dst,$_.subkind,$_.src_file))
} | Set-Content -LiteralPath $edgesTsv -Encoding UTF8

$now=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
$md=@()
$md += "# Flow Report (BODY)"
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
$md += "* Internal body edges: $($intEdges.Count)"
$md += "* Broken internal targets: $($broken.Count)"
$md += "* Cycles (raw, may include duplicates): $($cycles.Count)"
$md += ""
$md += "## Broken targets"
$md += ""
$md += "## Broken targets by source file"
$md += ""
if($broken.Count -eq 0){ $md += "_None_" } else {
  $groups = $broken | Group-Object src_file | Sort-Object Count -Descending
  foreach($g in ($groups | Select-Object -First 30)){
    $md += ("- **{0}**: {1}" -f $g.Name,$g.Count)
  }
  if($groups.Count -gt 30){ $md += ""; $md += "_Truncated to top 30._" }
}
$md += ""
$md += "## Broken targets"
$md += ""
if($broken.Count -eq 0){ $md += "_None_" } else {
  foreach($b in ($broken | Sort-Object src,dst | Select-Object -First 200)){
    $md += ("- {0} -> {1} ({2})" -f $b.src,$b.dst,$b.src_file)
  }
  if($broken.Count -gt 200){ $md += ""; $md += "_Truncated to first 200._" }
}
$md += ""
$md += "## Cycles"
$md += ""
if($cycles.Count -eq 0){ $md += "_None_" } else {
  foreach($c in ($cycles | Sort-Object | Select-Object -First 80)){
    $md += ("- " + $c)
  }
  if($cycles.Count -gt 80){ $md += ""; $md += "_Truncated to first 80._" }
}
$md | Set-Content -LiteralPath $report -Encoding UTF8

"OK: wrote $edgesTsv"
"OK: wrote $report"