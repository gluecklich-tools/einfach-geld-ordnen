#requires -Version 7.0
param(
  [ValidateSet("run","klaus","preflight","ssot","gates","findings")]
  [string]$Mode = "run",
  [string]$RepoRoot = (Get-Location).Path
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here "lib\ego.core.ps1")
$RepoRoot = Resolve-EgoRepoRoot $RepoRoot
Write-EgoLog ("EGO: Mode={0}" -f $Mode)
Write-EgoLog ("RepoRoot: {0}" -f $RepoRoot)
switch($Mode){
  "preflight" {
    # Placeholder: later uses gatesets\preflight.json
    Invoke-EgoToolFile -RepoRoot $RepoRoot -ToolPath "tools\enterprise-preflight.ps1"
  }
  "ssot" {
    Invoke-EgoToolFile -RepoRoot $RepoRoot -ToolPath "tools\gate-ssot-proxy.ps1"
    Invoke-EgoToolFile -RepoRoot $RepoRoot -ToolPath "tools\ssot-refresh-proxy.ps1"
  }
  "gates" {
    Invoke-EgoToolFile -RepoRoot $RepoRoot -ToolPath "tools\ego-flow-gates.ps1"
  }
  "findings" {
    # Placeholder: fill after we see literal targets & SSOT tooling
    Write-EgoLog "findings: TODO (placeholder)"
  }
  "run" {
    & $PSCommandPath -Mode preflight -RepoRoot $RepoRoot
    & $PSCommandPath -Mode ssot     -RepoRoot $RepoRoot
    & $PSCommandPath -Mode gates    -RepoRoot $RepoRoot
    & $PSCommandPath -Mode findings -RepoRoot $RepoRoot
  }
  "klaus" {
    & $PSCommandPath -Mode run -RepoRoot $RepoRoot
    # Extras (placeholder): live-checklist, daily-autosave, release readiness
    Write-EgoLog "klaus: TODO extras (placeholder)"
  }
  default {
    throw "STOP: unsupported mode: $Mode"
  }
}
Write-EgoLog "OK"
exit 0