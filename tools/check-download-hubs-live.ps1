#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)]
  [ValidateNotNullOrEmpty()]
  [string]$BaseUrl = "https://gluecklich-tools.github.io/einfach-geld-ordnen"
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))

function Get-DownloadHubPermalinksFromSsotIndex([string]$IndexPath){
  $out = @()
  if(-not (Test-Path -LiteralPath $IndexPath -PathType Leaf)){ return @() }
  $raw = Get-Content -LiteralPath $IndexPath -Raw -Encoding UTF8

  # Grab any /seiten/...download-hub....html occurrences anywhere
  $ms = [regex]::Matches($raw, '(?i)(/seiten/[^ \t\r\n\|"]*download-hub[^ \t\r\n\|"]*\.html)')
  foreach($m in $ms){ $out += $m.Groups[1].Value }

  @($out | Sort-Object -Unique)
}

function Get-DownloadHubPermalinksFromRepo(){
  $out = @()
  $seiten = Join-Path $RepoRoot "seiten"
  if(-not (Test-Path -LiteralPath $seiten -PathType Container)){ return @() }

  $files = Get-ChildItem -LiteralPath $seiten -File -Filter "download-hub*.md" -ErrorAction SilentlyContinue
  foreach($f in $files){
    $txt = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8

    # Try frontmatter permalink: /seiten/xxx.html
    $pm = [regex]::Match($txt, '(?im)^\s*permalink:\s*(/seiten/[^ \t\r\n]+)\s*$')
    if($pm.Success){
      $out += $pm.Groups[1].Value
      continue
    }

    # Fallback: derive from filename -> /seiten/<name>.html
    $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $out += ("/seiten/{0}.html" -f $base)
  }

  @($out | Sort-Object -Unique)
}

$indexPath = Join-Path $ProjectRoot "_INTERN\governance\inventory\REPO_PERMALINK_INDEX.md"

$permalinks = Get-DownloadHubPermalinksFromSsotIndex -IndexPath $indexPath
if($permalinks.Count -eq 0){
  $permalinks = Get-DownloadHubPermalinksFromRepo
}

$permalinks = @($permalinks | Sort-Object -Unique)
$cnt = $permalinks.Count
if($cnt -eq 0){
  Fail "NO_DOWNLOAD_HUB_PERMALINKS_FOUND (SSOT index + repo fallback empty)"
}

$fail = 0
"CHECK: download hubs live (count=$cnt)"
"BaseUrl: $BaseUrl"
"---"

foreach($p in $permalinks){
  $u = ($BaseUrl.TrimEnd("/") + $p)
  try {
    $r = Invoke-WebRequest -Uri $u -UseBasicParsing -Method GET
    $ct = ""
    try { $ct = $r.Headers["Content-Type"] } catch {}
    if($r.StatusCode -ne 200){
      $fail++
      "FAIL: HTTP=$($r.StatusCode) $u"
      continue
    }
    if(-not ($ct -match '(?i)text/html')){
      $fail++
      "FAIL: CT=$ct $u"
      continue
    }
    "OK: HTTP=200 CT=$ct $u"
  } catch {
    $fail++
    "FAIL: EXCEPTION $u :: $($_.Exception.Message)"
  }
}

"---"
if($fail -gt 0){
  Fail "DOWNLOAD_HUB_LIVE_CHECK_FAILED (fail=$fail)"
}

"PASS: download hubs live"
exit 0
