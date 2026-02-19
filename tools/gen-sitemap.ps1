param(
  [Parameter(Mandatory=$true)][string]$Repo,
  [Parameter(Mandatory=$true)][string]$SiteBase
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest


# SITEMAP_EXCLUDE_LIST (do not include utility/internal pages)
$Exclude = @(
  '/seiten/audit.html',
  '/seiten/changelog.html'
)
$ExcludeSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$Exclude)

$enc=[Text.UTF8Encoding]::new($false)

function ReadUtf8([string]$path){
  return [IO.File]::ReadAllText($path,$enc)
}

function Get-Frontmatter([string]$text){
  $m=[regex]::Match($text,'(?s)\A---\s*.*?\s*---\s*')
  if($m.Success){ return $m.Value } else { return '' }
}

function Get-Permalink([string]$fm){
  if([string]::IsNullOrWhiteSpace($fm)){ return '' }
  $m=[regex]::Match($fm,'(?m)^\s*permalink:\s*(.+?)\s*$')
  if(!$m.Success){ return '' }
  $v=$m.Groups[1].Value.Trim()
  if($v.StartsWith('"') -and $v.EndsWith('"')){ $v=$v.Substring(1,$v.Length-2) }
  if($v.StartsWith("'") -and $v.EndsWith("'")){ $v=$v.Substring(1,$v.Length-2) }
  return $v.Trim()
}

$targets = New-Object System.Collections.Generic.List[string]

# Home index.md
$idx = Join-Path $Repo 'index.md'
if(Test-Path -LiteralPath $idx){
  $t=ReadUtf8 $idx
  $fm=Get-Frontmatter $t
  if($fm){
    $pl=Get-Permalink $fm
    if([string]::IsNullOrWhiteSpace($pl)){ $pl='/' }
    $targets.Add($pl)
  } else {
    $targets.Add('/')
  }
} else {
  $targets.Add('/')
}

# seiten + pillar
$roots=@('seiten','pillar')
foreach($r in $roots){
  $dir=Join-Path $Repo $r
  if(!(Test-Path -LiteralPath $dir)){ continue }
  $files=Get-ChildItem -LiteralPath $dir -Recurse -File -Filter *.md -EA SilentlyContinue
  foreach($f in $files){
    $txt=ReadUtf8 $f.FullName
    $fm=Get-Frontmatter $txt
    if([string]::IsNullOrWhiteSpace($fm)){ continue }
    $pl=Get-Permalink $fm
    if([string]::IsNullOrWhiteSpace($pl)){ continue }
    $targets.Add($pl)
  }
}

# normalize + unique
$norm = $targets.ToArray() | ForEach-Object {
  $p=$_.Trim()
  if([string]::IsNullOrWhiteSpace($p)){ return $null }
  if(!$p.StartsWith('/')){ $p='/' + $p }
  
  if($ExcludeSet.Contains($p)){ return $null }
# canonicalize: ensure .html stays, allow '/' for home
  return $p
} | Where-Object { $_ } | Sort-Object -Unique

$lm=(Get-Date).ToString('yyyy-MM-dd')
$sb=New-Object System.Text.StringBuilder
[void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$sb.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
foreach($p in $norm){
  $loc = if($p -eq '/'){ $SiteBase + '/' } else { $SiteBase + $p }
  [void]$sb.AppendLine('  <url>')
  [void]$sb.AppendLine("    <loc>$loc</loc>")
  [void]$sb.AppendLine("    <lastmod>$lm</lastmod>")
  [void]$sb.AppendLine('    <changefreq>weekly</changefreq>')
  [void]$sb.AppendLine('    <priority>0.6</priority>')
  [void]$sb.AppendLine('  </url>')
}
[void]$sb.AppendLine('</urlset>')
$sb.ToString()