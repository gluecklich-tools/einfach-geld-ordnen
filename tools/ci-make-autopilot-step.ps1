param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$SourceStep = "tools/enterprise-autopilot-step.ps1"
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$src = Join-Path $RepoRoot $SourceStep
if(!(Test-Path -LiteralPath $src)){ throw "STOP: missing source step: $src" }

$scratch = Join-Path $RepoRoot "_local/_scratch"
New-Item -ItemType Directory -Path $scratch -Force | Out-Null

$dst = Join-Path $scratch "enterprise-autopilot-step.ps1"
Copy-Item -LiteralPath $src -Destination $dst -Force

"STEP_OUT: $dst"