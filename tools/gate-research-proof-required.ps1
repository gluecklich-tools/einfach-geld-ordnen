param(
  [string]$RepoRoot = (Get-Location).Path,
  [int]$MaxAgeHours = 72,
  [int]$MinLinks = 3
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001|Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$repo=(Resolve-Path -LiteralPath $RepoRoot).Path
$proofDir = Join-Path $repo "_local/proof"

if(!(Test-Path -LiteralPath $proofDir)){
  Fail "STOP: RESEARCH_PROOF_REQUIRED. Missing dir: _local/proof (create it + add RESEARCH_*.md)."
}

$latest = Get-ChildItem -LiteralPath $proofDir -File -Filter "RESEARCH_*.md" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if(-not $latest){
  Fail "STOP: RESEARCH_PROOF_REQUIRED. Missing file: _local/proof/RESEARCH_*.md"
}

$ageH = ([DateTime]::UtcNow - $latest.LastWriteTimeUtc).TotalHours
if($ageH -gt $MaxAgeHours){
  Fail ("STOP: RESEARCH_PROOF_REQUIRED. Latest research is too old (" + [Math]::Round($ageH,1) + "h). Update: " + $latest.Name)
}

$txt = [IO.File]::ReadAllText($latest.FullName, $enc)
$links = [Regex]::Matches($txt, "https?://[^\s\)]+").Count
if($links -lt $MinLinks){
  Fail ("STOP: RESEARCH_PROOF_REQUIRED. Need >= " + $MinLinks + " links, found " + $links + " in " + $latest.Name)
}

if($txt -notmatch "(?i)#\s*Findings"){
  Fail ("STOP: RESEARCH_PROOF_REQUIRED. Missing section '# Findings' in " + $latest.Name)
}

"PASS: RESEARCH_PROOF_REQUIRED -> " + $latest.Name + " (links=" + $links + ", ageH=" + [Math]::Round($ageH,1) + ")"
return