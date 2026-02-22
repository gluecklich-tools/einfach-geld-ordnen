param(
  [Parameter(Mandatory=$true)][string]$File,
  [Parameter(Mandatory=$true)][string]$RR,
  [string]$RepoRoot = ''
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
}
if([string]::IsNullOrWhiteSpace($RepoRoot)){ throw 'STOP: repo root not found.' }
if(!(Test-Path -LiteralPath $RepoRoot)){ throw "STOP: repo root missing: $RepoRoot" }

. (Join-Path $RepoRoot 'tools\ego-rereview-lib.ps1')

$full = $File
if(!(Test-Path -LiteralPath $full)){ throw "STOP: missing file: $full" }

$rel = $full.Replace(($RepoRoot.TrimEnd('\') + '\'),'')
$txt = Read-Utf8NoBom $full
$lines = $txt -split "`n",0,'SimpleMatch'
$lines = $lines | ForEach-Object { $_.TrimEnd("`r") }

$parts = Split-Body $lines
$body = $parts.Body

$ts = (Get-Date).ToString('yyyyMMdd_HHmmss')
$proofDir = Join-Path $RepoRoot '_local\proof'
$repDir   = Join-Path $RepoRoot '_local\rereview\reports'
New-Item -ItemType Directory -Path $proofDir -Force | Out-Null
New-Item -ItemType Directory -Path $repDir -Force | Out-Null

# PROOF hits (umlauts/ss candidates)
$hits = Body-Scan $body $rel
$proofPath = Join-Path $proofDir ("PROOF_{0}_{1}_{2}.txt" -f $ts,$RR,($rel -replace '[\\\/:\s]','_'))
Write-Report $proofPath $hits

# Weiter/footer/links/meta checks
$w = Find-WeiterBlock $body

$issues = New-Object System.Collections.Generic.List[string]
if(!$w.Found){ [void]$issues.Add('ISSUE:WEITER_MISSING') }
else{
  if($w.Links.Length -ne 3){ [void]$issues.Add(('ISSUE:WEITER_LINKS_COUNT={0}' -f $w.Links.Length)) }
  if(!$w.HasFooter){ [void]$issues.Add('ISSUE:FOOTER_INCLUDE_MISSING_IN_WEITER') }
}

# title/description in frontmatter
$fm = $parts.Head -join "`n"
if($parts.FmEnd -lt 0){ [void]$issues.Add('ISSUE:FRONTMATTER_MISSING') }
else{
  if($fm -notmatch '(?m)^\s*title:\s*\S'){ [void]$issues.Add('ISSUE:TITLE_MISSING') }
  if($fm -notmatch '(?m)^\s*description:\s*\S'){ [void]$issues.Add('ISSUE:DESCRIPTION_MISSING') }
  if($fm -match '(?m)^\s*permalink:\s*(/[^ ]+)\s*$'){ } else { [void]$issues.Add('ISSUE:PERMALINK_MISSING') }
}

# crude link hygiene: trailing slash to pages (exclude http(s), mailto)
$trail = New-Object System.Collections.Generic.List[string]
for($i=0;$i -lt $body.Length;$i++){
  $ln = $body[$i]
  if($ln -match '\]\((/[^)]+/)\)'){
    [void]$trail.Add(("TRAILING_SLASH:{0}:{1}" -f ($i+1), $Matches[1]))
  }
}
if($trail.Count -gt 0){
  foreach($t in $trail){ [void]$issues.Add('ISSUE:' + $t) }
}

$reportPath = Join-Path $repDir ("REPORT_{0}_{1}_{2}.txt" -f $ts,$RR,($rel -replace '[\\\/:\s]','_'))
$rep = New-Object System.Collections.Generic.List[string]
[void]$rep.Add(("RR={0}" -f $RR))
[void]$rep.Add(("FILE={0}" -f $rel))
[void]$rep.Add(("PROOF={0}" -f $proofPath))
[void]$rep.Add(("HITS={0}" -f $hits.Length))
[void]$rep.Add(("WEITER_FOUND={0}" -f $w.Found))
[void]$rep.Add(("WEITER_LINKS={0}" -f $w.Links.Length))
[void]$rep.Add(("WEITER_FOOTER={0}" -f $w.HasFooter))
[void]$rep.Add('--- ISSUES ---')
if($issues.Count -eq 0){ [void]$rep.Add('NONE') } else { foreach($x in $issues){ [void]$rep.Add($x) } }

Write-Report $reportPath $rep.ToArray()

"REPORT=" + $reportPath
"PROOF=" + $proofPath