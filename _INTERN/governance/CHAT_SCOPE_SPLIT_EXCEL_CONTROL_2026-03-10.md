# CHAT_SCOPE_SPLIT_EXCEL_CONTROL_2026-03-10

## Status
- PASS

## Zweck
- Builder-/Excel-Arbeit und Kontroll-/Governance-Arbeit dauerhaft trennen.
- Misch-Commits und Cross-Chat-Drift verhindern.

## Exklusiver Excel-/Builder-Block
- tools/build-start-xlsx.py
- tools/run-start-xlsx-builder.ps1

## Kontroll-Chat Aufgaben
- Scope-Kontrolle
- Commit-Schnitt-Prüfung
- Drift-Kontrolle
- Prioritätskontrolle
- Review von git status / git diff / Run-Outputs / Screenshots

## Harte Regeln
1. Nur der Excel-Chat bearbeitet:
   - tools/build-start-xlsx.py
   - tools/run-start-xlsx-builder.ps1

2. Der Kontroll-Chat bearbeitet diese beiden Dateien nicht.

3. Excel-/Builder-Änderungen werden nicht mit Governance-, LF-, Public-, Review-, Policy- oder Site-Dateien gemischt.

4. Vor Commit/Push des Excel-Blocks an den Kontroll-Chat liefern:
   - git status --short
   - git diff --cached --name-only
   - Commit-Message-Vorschlag
   - letzter Builder-Run
   - aktueller Screenshot

5. Verboten im falschen Chat:
   - repo-weites LF-Normalisieren
   - Hook-/step-run-/round-closeout-/ssot-sync-Eingriffe im Excel-Chat
   - Public-/Site-/Governance-Nebenfixes im Excel-Chat
   - lokaler Müll oder __pycache__ im Commit
   - Commit bei gemischtem Scope

## Bezug
- Gesicherter Builder-Zwischenstand: 2fe9518
- START / HAUSHALTSBUCH / MONAT builder-seitig gesichert
