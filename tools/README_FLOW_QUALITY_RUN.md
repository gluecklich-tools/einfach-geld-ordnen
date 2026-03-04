# Flow Quality Run

Dieses Tool erzeugt **immer** einen Run-Ordner unter `_local/flow_quality/run_YYYYMMDD_HHMMSS/` und schreibt:

- `flow_quality_gate.log` (kompletter Gate-Output)
- `flow_warns_v2.csv` (Header immer; Warns als Zeilen)
- `run_meta.json`

## Nutzung

pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\flow-quality-run.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\flow-quality-run.ps1 -ReportOnly

Ziel: Run-Emission auch bei WARNS=0 (keine Short-Circuits).