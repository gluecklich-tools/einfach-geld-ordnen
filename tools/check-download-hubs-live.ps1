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

$indexPath = Join-Path $ProjectRoot "_INTERN\governance\inventory\REPO_PERMALINK_INDEX.md"
if(-not (Test-Path -LiteralPath $indexPath -PathType Leaf)){
  Fail "MISSING_SSOT_INDEX: $indexPath"
}

$lines = Get-Content -LiteralPath $indexPath -Encoding UTF8

# Extract permalinks that look like download hubs
$permalinks = @()
foreach($l in $lines){
  if($l -match '(?i)\|'){
    # table row; grab things that look like /seiten/...download... or /seiten/download-hub...
    if($l -match '(?i)(/[^ \|]+download[^ \|]+\.html)'){
      $p = $Matches[1]
      if($p -match '(?i)download-hub'){
        $permalinks += $p
      }
    }
  }
}

$permalinks = $permalinks | Sort-Object -Unique
if($permalinks.Count -eq 0){
  Fail "NO_DOWNLOAD_HUB_PERMALINKS_FOUND in REPO_PERMALINK_INDEX.md"
}

$fail = 0
"CHECK: download hubs live (count=$($permalinks.Count))"
"BaseUrl: $BaseUrl"
"SSOT: $indexPath"
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
