# EGO_NERVENSYSTEM_V1
# Deterministic path resolver for Repo + SSOT/Internal.
# StrictMode safe. No side effects.

Set-StrictMode -Version Latest

function Get-EgoRepoRoot {
  $here=$PSScriptRoot
  if($here){
    $git = Join-Path (Resolve-Path (Join-Path $here '..')).Path '.git'
    if(Test-Path -LiteralPath $git){ return (Resolve-Path (Join-Path $here '..')).Path }
  }

  $cwd=(Get-Location).Path
  if(Test-Path -LiteralPath (Join-Path $cwd '.git')){ return (Resolve-Path $cwd).Path }

  $d=(Resolve-Path $cwd).Path
  while($true){
    if(Test-Path -LiteralPath (Join-Path $d '.git')){ return $d }
    $parent=Split-Path -Parent $d
    if($parent -eq $d){ break }
    $d=$parent
  }
  throw "EGO: RepoRoot not found (.git)."
}

function Get-EgoInternalRoot {
  $r=$env:EGO_INTERNAL_DIR
  if($r){
    if(Test-Path -LiteralPath $r){ return (Resolve-Path $r).Path }
    throw "EGO: EGO_INTERNAL_DIR is set but missing: $r"
  }

  $repo=Get-EgoRepoRoot
  $guess=Join-Path (Split-Path -Parent $repo) 'INTERN_REDACTED'
  if(Test-Path -LiteralPath $guess){ return (Resolve-Path $guess).Path }

  throw "EGO: InternalRoot not found. Set env:EGO_INTERNAL_DIR to the INTERN_REDACTED folder."
}

function Get-EgoLocalDir { Join-Path (Get-EgoRepoRoot) '_local' }
function Get-EgoLocalPatchBackupsDir { Join-Path (Get-EgoLocalDir) 'patch_backups' }

function Get-EgoSsotGovernanceRoot {
  $intern=Get-EgoInternalRoot
  $gov=Join-Path $intern 'governance'
  if(Test-Path -LiteralPath $gov){ return (Resolve-Path $gov).Path }
  throw "EGO: governance folder missing: $gov"
}

function Get-EgoSsotReportsDir {
  $d=Join-Path (Get-EgoSsotGovernanceRoot) '_reports'
  return $d
}

function Get-EgoSsotPatchBackupsDir {
  $d=Join-Path (Get-EgoSsotGovernanceRoot) '_patch_backups'
  return $d
}