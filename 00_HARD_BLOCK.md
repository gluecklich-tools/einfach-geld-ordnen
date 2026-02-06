---
layout: default
permalink: /00_HARD_BLOCK.html
published: false
sitemap: false
---
layout: default
permalink: /00_HARD_BLOCK.html
# 00 HARD BLOCK – Repo ist die Wahrheit (SSoT)

Ab jetzt gilt verbindlich:

##
1. Single Source of Truth (SSoT)
- **SSoT ist das GitHub-Repo** `gluecklich-tools/einfach-geld-ordnen`.
- Alles, was live ist oder live gehen soll, muss **im Repo** nachvollziehbar sein (Git-Historie).

##
2. Projektdateien-ZIPs / Basis-ZIPs
- Projektdateien-ZIPs (Basis/Archiv) sind **Backup/Referenz**.
- Sie sind **nicht** der Workflow fuer Repo-Updates.

##
3. Repo-Updates (Arbeitsworkflow)
- aenderungen an Repo-Dateien erfolgen **nur** als:
  - Datei oeffnen → Inhalt **1:1 Full-Swap** (Copy-Paste) → speichern (**UTF-8 ohne BOM**) → `git diff` → QA-Gate → Commit → Push → Actions gruen → Live-Check.

##
4. ZIPs sind NICHT verboten – aber sauber getrennt
- **Erlaubt/gewollt:** ZIP/ODS/XLSX als **Produkt-/Download-Assets** fuer Endnutzer.
- **Verboten als Arbeitsmethode:** Repo per „Austausch-ZIP“ ersetzen/patchen.

Ziel: Keine Verwechslung mehr zwischen **Repo-aenderung** und **Produkt-Download**.

## Weiter
- [50 30 20]({{ site.baseurl }}/pillar/50-30-20.html)
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Index]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}







