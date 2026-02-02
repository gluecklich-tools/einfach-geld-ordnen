param([Parameter(Mandatory=$true)][string]$PublicRepo)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
function Ensure-CleanOrCommitPush {
  param([Parameter(Mandatory=$true)][string]$RepoPath, [Parameter(Mandatory=$true)][string]$MsgPrefix)
  $st = @(& git -C $RepoPath status --porcelain)
  if (-not $st -or $st.Count -eq 0) { return }
  & git -C $RepoPath add -A | Out-Null
  & git -C $RepoPath commit -m ($MsgPrefix + " " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) | Out-Null
  & git -C $RepoPath push | Out-Null
}
& git -C $PublicRepo rev-parse --is-inside-work-tree | Out-Null
Write-Host "=== SAFE: run LawRun ==="
$Law = Join-Path $PublicRepo 'tools\ego-law-run.ps1'
powershell -NoProfile -ExecutionPolicy Bypass -File $Law
Write-Host "=== SAFE: finalize (commit+push remaining changes) ==="
Ensure-CleanOrCommitPush -RepoPath $PublicRepo -MsgPrefix "LawRun: finalize (safe)"
$st2 = @(& git -C $PublicRepo status --porcelain)
if ($st2 -and $st2.Count -gt 0) {
  throw ("ABORT: PublicRepo still dirty. First line: " + $st2[0])
}
Write-Host "LAW_RUN_SAFE_OK"