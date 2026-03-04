# P0: CLOSEOUT gate must hard-stop even inside gateset
& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch '..\gate-closeout-after-commit.ps1')
$ecCloseout = $LASTEXITCODE
if($ecCloseout -ne 0){ throw "STOP: gate-closeout-after-commit failed (exit=$ecCloseout)" }