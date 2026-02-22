param(
  [int]$FromRR = 1,
  [int]$ToRR = 0,
  [switch]$ApplyFix,
  [switch]$RunKlausAtEnd = $true,
  [switch]$CleanupProofAfterSuccess = $true,
  [string]$Base = 'https://gluecklich-tools.github.io/einfach-geld-ordnen'
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repo = (git rev-parse --show-toplevel 2>$null).Trim()
if([string]::IsNullOrWhiteSpace($repo)){ throw 'STOP: repo root not found.' }
Set-Location -LiteralPath $repo

$analyze = Join-Path $repo 'tools\ego-rereview-analyze.ps1'
$fix     = Join-Path $repo 'tools\ego-rereview-fix.ps1'
$klaus   = Join-Path $repo 'tools\klaus-run.ps1'

if(!(Test-Path -LiteralPath $analyze)){ throw "STOP: missing tool: $analyze" }
if(!(Test-Path -LiteralPath $fix)){ throw "STOP: missing tool: $fix" }
if(!(Test-Path -LiteralPath $klaus)){ throw "STOP: missing tool: $klaus" }

# --- load live sitemap order ---
$sitemapUrl = ($Base.TrimEnd('/') + '/sitemap.xml')
$xml = Invoke-WebRequest -Uri $sitemapUrl -TimeoutSec 25
[xml]$doc = $xml.Content

$urls = @()
foreach($n in $doc.urlset.url){ $urls += [string]$n.loc }

if($urls.Count -lt 1){ throw "STOP: sitemap empty: $sitemapUrl" }

# --- map url->local file by permalink (special case / -> index.md) ---
function Map-UrlToFile([string]$u){
  $path = $u.Replace($Base,'')
  if([string]::IsNullOrWhiteSpace($path)){ $path='/' }

  if($path -eq '/'){
    $p = Join-Path $repo 'index.md'
    if(Test-Path -LiteralPath $p){ return @{ Url=$u; Path=$path; File=$p } }
    return @{ Url=$u; Path=$path; File='' }
  }

  $needle = ('permalink:\s*{0}\s*$' -f [Text.RegularExpressions.Regex]::Escape($path))
  $hit = Select-String -Path (Join-Path $repo '*.md'), (Join-Path $repo 'seiten\*.md'), (Join-Path $repo 'pillar\*.md') -Pattern $needle -Encoding UTF8 -ErrorAction SilentlyContinue | Select-Object -First 1
  if($hit){ return @{ Url=$u; Path=$path; File=$hit.Path } }
  return @{ Url=$u; Path=$path; File='' }
}

# --- rr loop ---
$processed = New-Object System.Collections.Generic.List[int]
$changedAny = $false
$stopReason = ''

for($i=0;$i -lt $urls.Count;$i++){
  $rr = $i + 1
  if($rr -lt $FromRR){ continue }
  if($ToRR -gt 0 -and $rr -gt $ToRR){ break }

  $m = Map-UrlToFile $urls[$i]
  if([string]::IsNullOrWhiteSpace($m.File)){
    $stopReason = "STOP: RR$rr cannot map to local file (PATH=$($m.Path))"
    break
  }

  "=== RR{0:00} ANALYZE ===" -f $rr
  $out = & pwsh -NoProfile -File $analyze -RR ("RR{0:00}" -f $rr) -File $m.File -RepoRoot $repo
  $reportLine = ($out | Where-Object { $_ -like 'REPORT=*' } | Select-Object -First 1)
  $proofLine  = ($out | Where-Object { $_ -like 'PROOF=*' } | Select-Object -First 1)
  if([string]::IsNullOrWhiteSpace($reportLine)){ throw "STOP: analyze produced no REPORT for RR$rr" }

  $reportPath = $reportLine.Substring(7)
  $proofPath  = ''
  if($proofLine){ $proofPath = $proofLine.Substring(6) }

  "REPORT_PATH=" + $reportPath
  if($proofPath){ "PROOF_PATH=" + $proofPath }

  # parse report: if ISSUES != NONE -> STOP (manual required)
  $rep = Get-Content -LiteralPath $reportPath -Encoding UTF8
  $issuesIdx = [Array]::IndexOf($rep,'--- ISSUES ---')
  if($issuesIdx -ge 0 -and ($issuesIdx+1) -lt $rep.Length){
    $first = $rep[$issuesIdx+1]
    if($first -ne 'NONE'){
      $stopReason = "STOP: RR$rr has ISSUES (manual fix required). See report: $reportPath"
      break
    }
  }

  if($ApplyFix){
    "=== RR{0:00} FIX APPLY ===" -f $rr
    $fixOut = & pwsh -NoProfile -File $fix -RR ("RR{0:00}" -f $rr) -Mode 'apply' -File $m.File -RepoRoot $repo
    $ap = ($fixOut | Where-Object { $_ -like 'APPLY=*' } | Select-Object -First 1)
    if($ap -and $ap -eq 'APPLY=CHANGED'){ $changedAny = $true }
    $fixOut
  } else {
    "=== RR{0:00} FIX SKIPPED (plan-only mode) ===" -f $rr
  }

  [void]$processed.Add($rr)
}

if($stopReason){
  $stopReason
  "PROCESSED_RR_COUNT=" + $processed.Count
  if($processed.Count -gt 0){ "PROCESSED_RR_RANGE={0}-{1}" -f $processed[0], $processed[$processed.Count-1] }
  exit 2
}

"PROCESSED_RR_COUNT=" + $processed.Count
if($processed.Count -gt 0){ "PROCESSED_RR_RANGE={0}-{1}" -f $processed[0], $processed[$processed.Count-1] }

if($RunKlausAtEnd){
  "=== KLAUS RUN (END) ==="
  & pwsh -NoProfile -File $klaus
}

if($CleanupProofAfterSuccess -and $processed.Count -gt 0){
  # cleanup proofs for processed RRs (only after successful end)
  $proofDir = Join-Path $repo '_local\proof'
  if(Test-Path -LiteralPath $proofDir){
    foreach($n in $processed){
      $rrTag = ("RR{0:00}" -f $n)
      Get-ChildItem -LiteralPath $proofDir -File -Filter ("PROOF_*_{0}_*.txt" -f $rrTag) -ErrorAction SilentlyContinue |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }
      "PROOF_CLEANED=" + $rrTag
    }
  }
}

"RUN_DONE=OK"