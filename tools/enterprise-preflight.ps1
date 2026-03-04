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
    throw ("STOP: gate failed: {0} (exit={1})" -f @($p, $ec))
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
# P0: tools ASCII-only gate (prevents mojibake glyph parser issues)
& (Join-Path (Join-Path $RepoRoot "_local\_scratch") "gate-tools-ascii-only.ps1") -RepoRoot $RepoRoot

# P0 Gate: no relative file IO in tools (prevents $HOME/CWD surprises)
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "gate-no-relative-file-io.ps1") -RepoRoot $RepoRoot
$ec = $LASTEXITCODE
if($ec -ne 0){ throw ("STOP: gate failed: {0} (exit={1})" -f @((Join-Path $PSScriptRoot "gate-no-relative-file-io.ps1"), $ec) })

# P0 Gate: Brain root must be fresh (visible heartbeat)
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "gate-brain-root-freshness.ps1") -RepoRoot $RepoRoot
$ec = $LASTEXITCODE
if($ec -ne 0){ throw ("STOP: gate failed: {0} (exit={1})" -f @((Join-Path $PSScriptRoot "gate-brain-root-freshness.ps1"), $ec) })

# P0_KNOWN_FAILURES_GATESET
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\gatesets\p0-known-failures.ps1")
