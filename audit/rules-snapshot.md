---
layout: default
title: Audit – Rules Snapshot
permalink: /audit/rules-snapshot.html
---

# Rules Snapshot (aktueller verbindlicher Stand)

**Stand:** Änderungen werden als neuen Abschnitt ergänzt (append-only).

---

## 1) Leitlinie „100%+ bezogen auf das realistisch Mögliche“

- Jeder Task startet mit einem **vollständigen Komplettcheck**.
- Keine Umsetzung / kein Weiterarbeiten / kein Fortschritt „auf Verdacht“ ohne bestandenen Komplettcheck.
- Ziel: maximale Qualität **innerhalb realer Grenzen** (Medium, Kontext, Marktstandard).

---

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

---

## 3) Output-Regel im Projekt (Arbeitsmodus)

- Änderungen werden als **vollständiger 1:1-Dateiinhalt** geliefert (Copy-Paste Full-Swap).
- Keine ZIP-Lieferung als Ergebnis (ZIP nur intern zur Analyse).

---

## 4) Master-Dokumente (Source of Truth)

- `ARBEITSANWEISUNG_EINFACH_GELD_ORDNEN_v20.2.md`
- `LEARNINGS.md`
- `seiten/qa-release-gate.md`
- `audit/checklog.md`
- `audit/evidence-register.md`

> Hinweis: Wenn sich Governance-Regeln ändern, muss der Regelstand im Checklog als Snapshot referenziert werden.

---

## 5) Stand 2026-01-23 – Ergänzungen aus Komplettcheck-Reset (append-only)

- **CI über Bundler:** GitHub Actions baut Jekyll über `bundle exec jekyll build`, damit Plugins/Dependencies reproduzierbar geladen werden.
- **Exclude-Pflicht für Build-Ordner:** Wenn `_config.yml` `exclude:` nutzt, müssen `vendor/`, `.bundle/`, `node_modules/` explizit ausgeschlossen sein (sonst scannt Jekyll fremde Templates).
- **Audit live bauen:** `audit/` darf nicht in `_config.yml: exclude` stehen, wenn Audit-Seiten live erreichbar sein sollen.
- **PowerShell Rename-Regel:** `Rename-Item -NewName` akzeptiert nur den Dateinamen, keinen Pfad (sonst PSArgumentException).
- **Git Rename Detection:** Nach Dateisystem-Umbenennung wird ein Rename oft erst nach `git add -A` sauber erkannt (sonst „deleted + untracked“).
- **.gitignore ohne BOM:** Ein UTF-8 BOM kann die erste Ignore-Regel stören; `.gitignore` immer UTF-8 ohne BOM.
- **Mojibake-Sweep:** Vor Release: Repo-Scan auf `Ã.` / `â.` / `Â` (Encoding-Schäden) und konsequent beheben.
- **Line Endings:** `.gitattributes` kann LF für Textdateien erzwingen, um CRLF-Warnungen/Diff-Rauschen zu reduzieren.
