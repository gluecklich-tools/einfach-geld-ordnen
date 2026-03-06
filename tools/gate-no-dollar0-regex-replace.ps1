param(
  [string]$StepPath = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ENTERPRISE_LAW:
# - file-first / no inline ad-hoc edits
# - git-tracked-only target collection
# - NEVER self-flag this gate file

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$SelfPath = (Resolve-Path -LiteralPath $PSCommandPath).Path

$targets = New-Object System.Collections.Generic.List[string]

$trackedToolFiles = @(
  git -C $RepoRoot ls-files -- 'tools/*.ps1'
)

foreach($rel in $trackedToolFiles){
  if([string]::IsNullOrWhiteSpace($rel)){ continue }
  $full = Join-Path $RepoRoot $rel
  if(-not (Test-Path -LiteralPath $full)){ continue }
  $resolved = (Resolve-Path -LiteralPath $full).Path
  if($resolved -ieq $SelfPath){ continue }
  $targets.Add($resolved) | Out-Null
}

if(-not [string]::IsNullOrWhiteSpace($StepPath)){
  try {
    $resolvedStep = (Resolve-Path -LiteralPath $StepPath -ErrorAction Stop).Path
    if($resolvedStep -and $resolvedStep -ne $SelfPath){
      $targets.Add($resolvedStep) | Out-Null
    }
  } catch {}
}

$targets = @($targets | Sort-Object -Unique)

$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $raw = Get-Content -LiteralPath $f -Raw -Encoding UTF8
  if($raw -match '(?ms)\s-replace\s+["''][^"'']*\$0') {
    $bad.Add($f) | Out-Null
  }
}

if($bad.Count -gt 0){
  Write-Host 'FAIL: found regex -replace with $0 in:'
  $bad | ForEach-Object { Write-Host (' - ' + $_) }
  exit 1
}

Write-Host 'PASS: no regex -replace with $0 found'
exit 0