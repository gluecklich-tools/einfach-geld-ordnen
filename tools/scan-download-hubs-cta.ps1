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

if(-not (Test-Path -LiteralPath $seitenDir -PathType Container)){
  Fail "MISSING_DIR: seiten/"
}

$files = Get-ChildItem -LiteralPath $seitenDir -File -Filter "download-hub*.md" -ErrorAction SilentlyContinue
$files = @($files | Sort-Object Name)

if($files.Count -eq 0){
  Fail "NO_DOWNLOAD_HUB_MD_FILES_FOUND in seiten/"
}

function Get-FrontmatterValue([string]$Text,[string]$Key){
  $m = [regex]::Match($Text, "(?im)^\s*$([regex]::Escape($Key))\s*:\s*(.+?)\s*$")
  if($m.Success){ return $m.Groups[1].Value.Trim() }
  return ""
}

function Extract-MarkdownLinks([string]$Text){
  $out = @()
  $ms = [regex]::Matches($Text, '\[[^\]]+\]\(([^)]+)\)')
  foreach($m in $ms){
    $u = $m.Groups[1].Value.Trim()
    if(-not [string]::IsNullOrWhiteSpace($u)){ $out += $u }
  }
  @($out)
}

function Normalize-DownloadLinkToRepoPath([string]$Link){
  # returns relative repo path like "downloads/xxx.zip" or "" if not a download-ish link
  $u = $Link

  # strip liquid baseurl
  $u = $u -replace '\{\{\s*site\.baseurl\s*\}\}', ''
  $u = $u -replace '\{\{\s*site\.url\s*\}\}', ''
  $u = $u.Trim()

  # only consider downloads (zip/ods/xlsx/pdf) or /downloads/ path
  if($u -notmatch '(?i)(/downloads/|downloads/|\.zip(\b|$)|\.ods(\b|$)|\.xlsx(\b|$)|\.pdf(\b|$))'){
    return ""
  }

  # remove leading slashes and baseurl artifacts
  $u = $u.TrimStart('/')

  # if it contains "downloads/" somewhere, cut to that
  $idx = $u.ToLower().IndexOf("downloads/")
  if($idx -ge 0){ $u = $u.Substring($idx) }

  # drop query/hash
  $u = ($u -split '\?')[0]
  $u = ($u -split '#')[0]
  $u.Trim()
}

function Has-WeiterBlock([string]$Text){
  # simple heuristic: heading "## Weiter" exists
  return [regex]::IsMatch($Text, '(?im)^\s*##\s+Weiter\s*$')
}

function Get-WeiterSectionLinks([string]$Text){
  if(-not (Has-WeiterBlock $Text)){ return @() }
  # take text from "## Weiter" until next "## " heading
  $m = [regex]::Match($Text, '(?ims)^\s*##\s+Weiter\s*$\s*(.*?)(^\s*##\s+|\z)')
  if(-not $m.Success){ return @() }
  $sec = $m.Groups[1].Value
  Extract-MarkdownLinks $sec
}

$missingDownloads = 0
$missingWeiter = 0
$okPages = 0

"SCAN: download hubs CTA + Weiter (repo-local)"
"Files: $($files.Count)"
"---"

foreach($f in $files){
  $txt = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $permalink = Get-FrontmatterValue -Text $txt -Key "permalink"
  $title = Get-FrontmatterValue -Text $txt -Key "title"

  if([string]::IsNullOrWhiteSpace($permalink)){ $permalink = "(no permalink)" }
  if([string]::IsNullOrWhiteSpace($title)){ $title = "(no title)" }

  "PAGE: $($f.Name) | $title | $permalink"

  $links = Extract-MarkdownLinks $txt
  $dl = @()
  foreach($l in $links){
    $rp = Normalize-DownloadLinkToRepoPath $l
    if(-not [string]::IsNullOrWhiteSpace($rp)){ $dl += $rp }
  }
  $dl = @($dl | Sort-Object -Unique)

  if($dl.Count -eq 0){
    "  WARN: no download-like links found"
  } else {
    foreach($rp in $dl){
      $abs = Join-Path $RepoRoot $rp
      if(-not (Test-Path -LiteralPath $abs -PathType Leaf)){
        $missingDownloads++
        "  FAIL: missing file -> $rp"
      } else {
        "  OK: file exists -> $rp"
      }
    }
  }

  if(-not (Has-WeiterBlock $txt)){
    $missingWeiter++
    "  FAIL: missing '## Weiter' block"
  } else {
    $wlinks = Get-WeiterSectionLinks $txt
    if($wlinks.Count -eq 0){
      $missingWeiter++
      "  FAIL: '## Weiter' has no links"
    } else {
      "  OK: Weiter links -> $($wlinks.Count)"
    }
  }

  "  ---"
}

"SUMMARY:"
"  missing download files: $missingDownloads"
"  missing/empty Weiter:    $missingWeiter"

if(($missingDownloads + $missingWeiter) -gt 0){
  Fail "SCAN_FAILED (missingDownloads=$missingDownloads missingWeiter=$missingWeiter)"
}

"PASS: scan-download-hubs-cta"
exit 0
