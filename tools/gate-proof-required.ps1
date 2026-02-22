param(
  [string]$RepoRoot = ""
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

if([string]::IsNullOrWhiteSpace($RepoRoot)){
  try{ $RepoRoot=(git rev-parse --show-toplevel 2>$null).Trim() }catch{}
}
if([string]::IsNullOrWhiteSpace($RepoRoot) -or !(Test-Path -LiteralPath $RepoRoot)){
  throw "PROOF-GATE: repo root not found."
}

$proofDir=Join-Path $RepoRoot '_local\proof'
if(!(Test-Path -LiteralPath $proofDir)){
  throw "PROOF-GATE: missing proof dir: $proofDir (create proof before apply)."
}

$latest = Get-ChildItem -LiteralPath $proofDir -File -Filter 'PROOF_*.txt' |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if(!$latest){
  throw "PROOF-GATE: no PROOF_*.txt found in $proofDir."
}

$txt = Get-Content -LiteralPath $latest.FullName -Encoding UTF8

$hasUrl = $false
$hasHit = $false

foreach($line in $txt){
  if($line -match 'https://gluecklich-tools\.github\.io/einfach-geld-ordnen/'){ $hasUrl=$true }
  if($line -match ':\d+:\s'){ $hasHit=$true }
}

if(-not $hasHit){
  throw "PROOF-GATE: latest proof has no hit lines (file:line:match): $($latest.FullName)"
}

# live url is required if proof mentions LIVE_BUG=1 or if user flagged live issue
$needsUrl = $false
foreach($line in $txt){
  if($line -match '^LIVE_BUG=1\b'){ $needsUrl=$true }
}
if($needsUrl -and -not $hasUrl){
  throw "PROOF-GATE: LIVE_BUG=1 but no live url present in proof: $($latest.FullName)"
}

"PASS: PROOF-GATE ok -> $($latest.FullName)"