---
layout: default
title: Audit – Rules Snapshot
permalink: /audit/rules-snapshot.html
---

# Rules Snapshot (aktueller verbindlicher Stand)

**Stand:** bitte bei Änderungen als neuen Abschnitt ergänzen (append-only).

## 1) Leitlinie „100%+ bezogen auf das realistisch Mögliche“

- Jeder Task startet mit einem **vollständigen Komplettcheck**.
- Keine Umsetzung / kein Weiterarbeiten / kein Fortschritt „auf Verdacht“ ohne bestandenen Komplettcheck.
- Ziel: maximale Qualität **innerhalb realer Grenzen** (Medium, Kontext, Marktstandard).

## 2) Technische Projektregeln (GitHub Pages / Jekyll Project Site)

1) **Explizite .html-Permalinks**
   - Jede Seite hat `permalink: /pfad/name.html`
   - Links verweisen **exakt** auf diese `.html`-URLs.

2) **baseurl ist Pflicht**
   - Alle internen Links enthalten `{{ site.baseurl }}` (Project Site unter `/einfach-geld-ordnen/`).

3) **Dateiname = Permalink**
   - Dateiname passt exakt zum Permalink (ASCII-only).
   - Keine virtuellen/gedachten Seiten.

4) **ASCII-only Dateinamen**
   - Nur `a-z`, `0-9`, `-`, `_`
   - Keine Umlaute/Leerzeichen/Sonderzeichen.

5) **Frontmatter-Sicherheitsregel**
   - Frontmatter beginnt in Zeile 1 mit `---` (ASCII).
   - Ende ebenfalls `---`.
   - Frontmatter darf nicht im HTML sichtbar sein.

6) **YAML in `_data/*.yml`**
   - Liquid-Ausdrücke nur **gequotet** als Strings.

7) **Encoding**
   - UTF-8 ohne BOM für Textdateien.

## 3) Output-Regel im Projekt (Arbeitsmodus)

- Änderungen werden als **vollständiger 1:1-Dateiinhalt** geliefert (Copy-Paste Full-Swap).
- Keine ZIP-Lieferung als Ergebnis (ZIP nur intern zur Analyse).

## 4) Master-Dokumente (Source of Truth)

- `ARBEITSANWEISUNG_EINFACH_GELD_ORDNEN_v019.md`
- `LEARNINGS.md`
- `PROJECT_STATUS.md`
- `QA_RELEASE_GATE.md` (falls im Repo vorhanden, sonst Projektdateien)

> Hinweis: Wenn sich Governance-Regeln ändern, muss der Regelstand im Checklog als Snapshot referenziert werden.
