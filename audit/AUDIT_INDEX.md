---
layout: default
title: Audit – Index
permalink: /audit/index.html
---

# Audit-Archiv (Governance / QA / Learnings)

Dieses Verzeichnis dient der **auditfähigen** Dokumentation des Projekts „Einfach Geld ordnen“.

Ziel:
- Nachvollziehbarkeit der Entwicklung
- Beweisbare Entscheidungen (Governance)
- Reproduzierbare Checks (QA)
- Sichtbare Ursachen für Fehler/Regressionen
- Klare Trennung: **Prüfen** vs. **Umsetzen**

## Grundprinzipien

1) **Append-only**
   - Check-Logs werden **nicht** still überschrieben.
   - Korrekturen erfolgen als neuer Eintrag „Korrektur/Amendment“.

2) **Evidence first**
   - Jeder Check hat: Live-URL, Commit-Hash(es), Scope, Ergebnis, Evidence.

3) **Regel-Snapshot**
   - Jeder Check benennt, welche Arbeitsanweisung/Leitlinie galt.
   - Beispiel: `ARBEITSANWEISUNG_EINFACH_GELD_ORDNEN_v019.md` + Leitlinie „100%+ bezogen auf das realistisch Mögliche“.

4) **Keine Umsetzung ohne bestandenen Komplettcheck**
   - Wenn ein Check „nicht bestanden“ ist: keine Änderungen auf Verdacht.

## Dateien im Audit-Archiv

- `CHECKLOG.md`  
  Sammellog aller Checks (inkl. Retro-Protokolle „soweit möglich“)

- `EVIDENCE_REGISTER.md`  
  Register aller Belege (Live-URLs, Commits, Screenshots, Artefakte)

- `RULES_SNAPSHOT.md`  
  Kurzfassung der aktuell verbindlichen Regeln + Verweise auf die Master-Dokumente

## Live-URL

https://gluecklich-tools.github.io/einfach-geld-ordnen/
