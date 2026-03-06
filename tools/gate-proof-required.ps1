param(
  [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-LatestProofFile {
  param(
    [Parameter(Mandatory = $true)][string]$ProofDir
  )

  $dirInfo = [System.IO.DirectoryInfo]::new($ProofDir)
  if (-not $dirInfo.Exists) {
    return $null
  }

  $best = $null
  foreach($f in $dirInfo.EnumerateFiles('PROOF_*.txt', [System.IO.SearchOption]::TopDirectoryOnly)){
    if ($null -eq $best) {
      $best = $f
      continue
    }
    if ($f.LastWriteTimeUtc -gt $best.LastWriteTimeUtc) {
      $best = $f
      continue
    }
    if ($f.LastWriteTimeUtc -eq $best.LastWriteTimeUtc -and $f.Name -gt $best.Name) {
      $best = $f
    }
  }

  return $best
}

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

$latest = Get-LatestProofFile -ProofDir $proofDir

if(!$latest){
  throw "PROOF-GATE: no PROOF_*.txt found in $proofDir."
}

$txt = Get-Content -LiteralPath $latest.FullName -Encoding UTF8
$hasHit = $false
$hasUrl = $false

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
  if($line -match 'LIVE_BUG=1'){ $needsUrl = $true }
}
if($needsUrl -and -not $hasUrl){
  throw "PROOF-GATE: LIVE_BUG=1 but no live url present in proof: $($latest.FullName)"
}

"PASS: PROOF-GATE ok -> $($latest.FullName)"