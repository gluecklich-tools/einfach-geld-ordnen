param(
  [string]$RepoRoot = (Get-Location).Path,
  [switch]$AllowDirtyRepo
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Invoke-Gate([string]$p){
  if(!(Test-Path -LiteralPath $p)){ throw "Missing gate: $p" }
  & $p -RepoRoot $RepoRoot
  $ec = (Test-Path variable:global:LASTEXITCODE) ? [int]$global:LASTEXITCODE : 0
  if($ec -ne 0){
    throw ("STOP: gate failed: {0} (exit={1})" -f $p, $ec)
  }
}

$tools = Join-Path $RepoRoot "tools"

# --- HARD LAW: NO_INLINE_STEP_EXECUTION ---
if(-not $AllowDirtyRepo){
  Invoke-Gate (Join-Path $tools "gate-no-inline-dirty-changes.ps1")
}
# --- /HARD LAW ---

# --- HANDSHAKE GATES (Brain <-> Nervensystem) ---
Invoke-Gate (Join-Path $tools "gate-brain-sync-freshness.ps1")
Invoke-Gate (Join-Path $tools "gate-ssot-loadorder-present.ps1")
Invoke-Gate (Join-Path $tools "gate-inventory-present.ps1")
# --- /HANDSHAKE GATES ---

Invoke-Gate (Join-Path $tools "gate-no-regex-patch-v1.ps1")
Invoke-Gate (Join-Path $tools "gate-ps-parser-all-tools.ps1")
Invoke-Gate (Join-Path $tools "gate-joinpath-argcount.ps1")
Invoke-Gate (Join-Path $tools "gate-no-absolute-paths-in-tools.ps1")
Invoke-Gate (Join-Path $tools "gate-actions-trigger-policy.ps1")
Invoke-Gate (Join-Path $tools "gate-actions-smoke-policy.ps1")
Invoke-Gate (Join-Path $tools "gate-actions-autopilot-policy.ps1")
Invoke-Gate (Join-Path $tools "gate-no-inner-single-quotes-in-command.ps1")
Invoke-Gate (Join-Path $tools "gate-no-console-transcripts.ps1")
Invoke-Gate (Join-Path $tools "gate-no-format-brace-traps.ps1")
Invoke-Gate (Join-Path $tools "gate-param-must-be-first.ps1")
Invoke-Gate (Join-Path $tools "gate-reports-no-errors.ps1")
Invoke-Gate (Join-Path $tools "gate-repo-sanity-scan.ps1")

"PASS: ENTERPRISE_PREFLIGHT"
exit 0