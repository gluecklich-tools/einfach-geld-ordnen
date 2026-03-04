# P0: tools must parse before any other gate
$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "tools\gate-tools-parse.ps1")
$ecToolsParse = $LASTEXITCODE
if($ecToolsParse -ne 0){ throw "STOP: gate-tools-parse failed (exit=$ecToolsParse)" }
# P0: CLOSEOUT gate must hard-stop even inside gateset (absolute path, no $PSScriptRoot)
$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$GateCloseout = Join-Path $RepoRoot "tools\gate-closeout-after-commit.ps1"
& pwsh -NoProfile -ExecutionPolicy Bypass -File $GateCloseout
$ecCloseout = $LASTEXITCODE
if($ecCloseout -ne 0){ throw "STOP: gate-closeout-after-commit failed (exit=$ecCloseout)" }


# P0: prevent known PowerShell binder traps (format comma args, @($x).Count)
pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path (Join-Path $PSScriptRoot '..') 'gate-no-binder-traps.ps1') | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'STOP: gate-no-binder-traps failed' }
