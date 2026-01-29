---
layout: default
permalink: /00_HARD_BLOCK.html
---
# 00 HARD BLOCK – Repo ist die Wahrheit (SSoT)

Ab jetzt gilt verbindlich:

##
1. Single Source of Truth (SSoT)
- **SSoT ist das GitHub-Repo** `gluecklich-tools/einfach-geld-ordnen`.
- Alles, was live ist oder live gehen soll, muss **im Repo** nachvollziehbar sein (Git-Historie).

##
2. Projektdateien-ZIPs / Basis-ZIPs
- Projektdateien-ZIPs (Basis/Archiv) sind **Backup/Referenz**.
- Sie sind **nicht** der Workflow für Repo-Updates.

##
3. Repo-Updates (Arbeitsworkflow)
- Änderungen an Repo-Dateien erfolgen **nur** als:
  - Datei öffnen → Inhalt **1:1 Full-Swap** (Copy-Paste) → speichern (**UTF-8 ohne BOM**) → `git diff` → QA-Gate → Commit → Push → Actions grün → Live-Check.

##
4. ZIPs sind NICHT verboten – aber sauber getrennt
- **Erlaubt/gewollt:** ZIP/ODS/XLSX als **Produkt-/Download-Assets** für Endnutzer.
- **Verboten als Arbeitsmethode:** Repo per „Austausch-ZIP“ ersetzen/patchen.

Ziel: Keine Verwechslung mehr zwischen **Repo-Änderung** und **Produkt-Download**.
