param(
  [string]$BaseUrl = 'https://www.einfach-geld-ordnen.de'
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))

function Get-DownloadHubPermalinksFromSsotIndex([string]$IndexPath){
  $out = @()
  if(-not (Test-Path -LiteralPath $IndexPath)){ return @() }

  $raw = Get-Content -LiteralPath $IndexPath -Raw -Encoding UTF8

  # Grab any /seiten/...download-hub....html occurrences anywhere
  $ms = [regex]::Matches($raw, '(?i)(/seiten/[^ \t\r\n\|"]*download-hub[^\t\r\n\|"]*\.html)')
  foreach($m in $ms){ $out += $m.Groups[1].Value }

  return @($out | Sort-Object -Unique)
}

function Get-DownloadHubPermalinksFromRepo(){
  $out = @()

  $trackedHubFiles = @(
    git -C $RepoRoot ls-files -- 'seiten/download-hub*.md'
  )

  foreach($rel in $trackedHubFiles){
    if([string]::IsNullOrWhiteSpace($rel)){ continue }

    $full = Join-Path $RepoRoot $rel
    if(-not (Test-Path -LiteralPath $full -PathType Leaf)){ continue }

    $txt = Get-Content -LiteralPath $full -Raw -Encoding UTF8

    # Try frontmatter permalink: /seiten/xxx.html
    $pm = [regex]::Match($txt, '(?im)^\s*permalink:\s*(/seiten/[^\t\r\n]+)\s*$')
    if($pm.Success){
      $out += $pm.Groups[1].Value
      continue
    }

    # Fallback: derive from filename -> /seiten/<name>.html
    $base = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetFileName($full))
    $out += ("/seiten/{0}.html" -f $base)
  }

  return @($out | Sort-Object -Unique)
}

$ssotIndex = Join-Path $ProjectRoot 'Brain_EGO_Dateien\ARTIFACTS_INDEX.md'
$permalinks = @()

$fromSsot = @(Get-DownloadHubPermalinksFromSsotIndex -IndexPath $ssotIndex)
if($fromSsot.Count -gt 0){
  $permalinks = $fromSsot
} else {
  $permalinks = @(Get-DownloadHubPermalinksFromRepo)
}

$cnt = $permalinks.Count
if($cnt -le 0){
  Fail 'No download hub permalinks found.'
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

    $okStatus = ($r.StatusCode -eq 200)
    $okType = ($ct -match 'text/html')
    if($okStatus -and $okType){
      ("OK   {0} [{1}] {2}" -f $r.StatusCode, $ct, $u)
    } else {
      $fail++
      ("FAIL {0} [{1}] {2}" -f $r.StatusCode, $ct, $u)
    }
  }
  catch {
    $fail++
    $msg = $_.Exception.Message
    ("FAIL EXCEPTION {0} :: {1}" -f $u, $msg)
  }
}

"---"
if($fail -gt 0){
  Fail "DOWNLOAD_HUB_LIVE_CHECK_FAILED (fail=$fail)"
}

"PASS: download hubs live"
exit 0
