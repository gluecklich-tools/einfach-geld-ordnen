# P0: CLOSEOUT gate must hard-stop even inside gateset (absolute path, no $PSScriptRoot)
$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$GateCloseout = Join-Path $RepoRoot "tools\gate-closeout-after-commit.ps1"
& pwsh -NoProfile -ExecutionPolicy Bypass -File $GateCloseout
$ecCloseout = $LASTEXITCODE
if($ecCloseout -ne 0){ throw "STOP: gate-closeout-after-commit failed (exit=$ecCloseout)" }

