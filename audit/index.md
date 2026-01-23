---
layout: default
title: "Audit – Index"
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

---

## Grundprinzipien

1) **Append-only**
   - Check-Logs werden **nicht** still überschrieben.
   - Korrekturen erfolgen als neuer Eintrag („Amendment“).

2) **Evidence first**
   - Jeder Check hat: Live-URL, Commit-Hash(es), Scope, Ergebnis, Evidence.

3) **Regel-Snapshot**
   - Jeder Check nennt, welche Arbeitsanweisung/Leitlinie galt
   - Beispiel: `ARBEITSANWEISUNG_EINFACH_GELD_ORDNEN_v20.2.md` + Leitlinie „100%+ bezogen auf das realistisch Mögliche“.

4) **Keine Umsetzung ohne bestandenen Komplettcheck**
   - Wenn ein Check „nicht bestanden“ ist: keine Änderungen auf Verdacht.

---

## Dateien im Audit-Archiv

- **Checklog** (append-only)  
  👉 [audit/checklog]({{ site.baseurl }}/audit/checklog.html)

- **Evidence Register** (append-only)  
  👉 [audit/evidence-register]({{ site.baseurl }}/audit/evidence-register.html)

- **Rules Snapshot** (append-only)  
  👉 [audit/rules-snapshot]({{ site.baseurl }}/audit/rules-snapshot.html)

---

## Live-URL (Produktiv)

https://gluecklich-tools.github.io/einfach-geld-ordnen/

Hinweis: Audit-Seiten sind bewusst **nicht** im Hauptmenü verlinkt, aber live erreichbar.
