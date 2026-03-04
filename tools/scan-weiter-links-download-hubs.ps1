#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$seitenDir = Join-Path $RepoRoot "seiten"
if(-not (Test-Path -LiteralPath $seitenDir -PathType Container)){ Fail "MISSING_DIR: seiten/" }

$hubFiles = Get-ChildItem -LiteralPath $seitenDir -File -Filter "download-hub*.md" -ErrorAction SilentlyContinue | Sort-Object Name
$hubFiles = @($hubFiles)
if($hubFiles.Count -eq 0){ Fail "NO_DOWNLOAD_HUB_MD_FILES_FOUND in seiten/" }

function Extract-MarkdownLinks([string]$Text){
  $out = @()
  $ms = [regex]::Matches($Text, '\[[^\]]+\]\(([^)]+)\)')
  foreach($m in $ms){
    $u = $m.Groups[1].Value.Trim()
    if(-not [string]::IsNullOrWhiteSpace($u)){ $out += $u }
  }
  @($out)
}

function Has-WeiterBlock([string]$Text){
  [regex]::IsMatch($Text, '(?im)^\s*##\s+Weiter\s*$')
}

function Get-WeiterSection([string]$Text){
  $m = [regex]::Match($Text, '(?ims)^\s*##\s+Weiter\s*$\s*(.*?)(^\s*##\s+|\z)')
  if($m.Success){ return $m.Groups[1].Value }
  ""
}

function Normalize-InternalTarget([string]$Link){
  $u = $Link
  $u = $u -replace '\{\{\s*site\.baseurl\s*\}\}', ''
  $u = $u -replace '\{\{\s*site\.url\s*\}\}', ''
  $u = ($u -split '\?')[0]
  $u = ($u -split '#')[0]
  $u = $u.Trim()
  if([string]::IsNullOrWhiteSpace($u)){ return "" }
  if($u -match '^(?i)https?://'){ return "" }  # external -> ignore here
  $u.TrimStart('/')
}

function RepoHasTarget([string]$Rel){
  if([string]::IsNullOrWhiteSpace($Rel)){ return $false }

  # html pages: try map to .md under repo
  if($Rel -match '(?i)^seiten/.*\.html$'){
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Rel)
    $md = Join-Path $RepoRoot ("seiten\{0}.md" -f $name)
    return (Test-Path -LiteralPath $md -PathType Leaf)
  }

  # direct md
  if($Rel -match '(?i)^seiten/.*\.md$'){
    return (Test-Path -LiteralPath (Join-Path $RepoRoot $Rel) -PathType Leaf)
  }

  # other internal files
  return (Test-Path -LiteralPath (Join-Path $RepoRoot $Rel) -PathType Leaf)
}

$fail = 0
$totalLinks = 0

"SCAN: Weiter-links in download hubs (repo-local)"
"Files: $($hubFiles.Count)"
"---"

foreach($f in $hubFiles){
  $txt = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  "PAGE: $($f.Name)"

  if(-not (Has-WeiterBlock $txt)){
    $fail++
    "  FAIL: missing ## Weiter"
    "  ---"
    continue
  }

  $sec = Get-WeiterSection $txt
  $links = Extract-MarkdownLinks $sec
  $links = @($links)
  $totalLinks += $links.Count

  if($links.Count -eq 0){
    $fail++
    "  FAIL: Weiter section has no links"
    "  ---"
    continue
  }

  foreach($l in $links){
    $rel = Normalize-InternalTarget $l
    if([string]::IsNullOrWhiteSpace($rel)){
      "  WARN: skip non-internal -> $l"
      continue
    }
    if(-not (RepoHasTarget $rel)){
      $fail++
      "  FAIL: missing target -> $l"
    } else {
      "  OK: target exists -> $l"
    }
  }

  "  ---"
}

"SUMMARY:"
"  total Weiter links: $totalLinks"
"  failures:          $fail"

if($fail -gt 0){
  Fail "WEITER_LINK_SCAN_FAILED (fail=$fail)"
}

"PASS: scan weiter links"
exit 0
