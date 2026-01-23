---
layout: default
title: Audit – Checklog
permalink: /audit/checklog.html
---

# Checklog (append-only)

Dieses Log dokumentiert alle Checks.  
Korrekturen erfolgen als neue Einträge „Amendment“.

---

## CHECK TEMPLATE (für neue Checks)

**Check-ID:** CHECK-YYYY-MM-DD-XXX  
**Datum/Uhrzeit:**  
**Typ:** Komplettcheck / Teilcheck / Regression / Release-Gate  
**Regelstand:** (Arbeitsanweisung-Version + Leitlinie)  
**Scope:** (Repo / Live / Inhalte / Downloads / CI)  
**Input:** (Commit-Hash, Branch, Live-URL, Screenshots etc.)  
**Ergebnis:** BESTANDEN / NICHT BESTANDEN  
**Findings:** (kurz, faktisch)  
**Nächste Schritte:** (konkret)

---

## CHECK-RETRO-001 – baseurl + Permalink-Regel (Ausgangslage)

**Typ:** Retro-Teilcheck (Regeln)  
**Regelstand:** 100%+ Leitlinie + v019  
**Ergebnis:** BESTANDEN (Regeln festgehalten)  

---

## CHECK-RETRO-002 – Frontmatter-Sicherheitsregel (Ausgangslage)

**Typ:** Retro-Teilcheck (Frontmatter)  
**Regelstand:** 100%+ Leitlinie + v019  
**Ergebnis:** BESTANDEN (Regel aktiv)  

---

## CHECK-RETRO-003 – YAML/Liquid `_data` Regel (Ausgangslage)

**Typ:** Retro-Teilcheck (YAML)  
**Evidence (Beispiel):**
- `_data/*.yml`: Liquid nur als String in Anführungszeichen

**Ergebnis:** BESTANDEN (Regel aktiv)  

---

## CHECK-RETRO-004 – Dateinamen ASCII-only (Ausgangslage)

**Typ:** Retro-Teilcheck (Dateinamen)  
**Evidence (Beispiel):**
- keine Umlaute, keine Leerzeichen, Unterstrich `_` statt Leerzeichen

**Ergebnis:** BESTANDEN (Regel aktiv)  

---

## CHECK-RETRO-005 – Encoding/BOM als Switch-Blocker (soweit möglich)

**Typ:** Retro-Teilcheck (Encoding)  
**Evidence (Commits):**
- `6a96285` Fix: remove UTF-8 BOM from pages (Switch blocker)

**Ergebnis:** BESTANDEN (für die betroffenen Dateien)

---

## CHECK-RETRO-006 – Download-Sperre / Switch-Gate (aktuell relevant)

**Typ:** Komplettcheck-Blocker (noch offen bis Evidence)  
**Regelstand:** 100%+ Leitlinie + v019  
**Scope:** Downloads dürfen nicht erreichbar sein, solange nicht Switch-ready  
**Erwartetes Evidence:**  
- `/downloads/...` liefert 404 (oder wird technisch nicht gebaut)  
- keine aktiven Download-Links im Content/Includes  
- klare Hinweis-Kommunikation „Downloads deaktiviert“ ohne Umgehung

**Status:** in Arbeit / Evidence offen

---

## CHECK-2026-01-23-001 – Komplettcheck Reset (Repo+Live+CI) nach Regel-Update

**Typ:** Komplettcheck (Reset „Sekunde null“)  
**Datum:** 2026-01-23 (Europe/Berlin)  
**Regelstand:** ARBEITSANWEISUNG_EINFACH_GELD_ORDNEN_v20.2 + Leitlinie „100%+ bezogen auf das realistisch Mögliche“  
**Scope:** Repo-Struktur, Frontmatter/Permalinks, baseurl-Linkregeln, CI (GitHub Actions), Live-Stichprobe, Audit-Erreichbarkeit, Download-Gate

**Input / Ausgangslage:**
- Repo: `gluecklich-tools/einfach-geld-ordnen` (branch `main`)
- Live: https://gluecklich-tools.github.io/einfach-geld-ordnen/
- User-Evidence: Live-Screenshots (Start/Pillar/Praxis/Audit), Aussage „alle Links funktional“, Actions grün

**Evidence (Commits / Änderungen im Rahmen des Checks):**
- `744a053` Workflow-Fix + Audit-Rename (CI stabilisiert, Audit-Dateien auf Slugs)  
- `b255b73` `.gitignore` BOM-Fix + neue Pillar-Seite `pillar/spielraum-ruecklagen.html`  
- `709a778` Audit-Seiten wieder bauen (Entfernen von `audit` aus `_config.yml: exclude`)  
- (zusätzlicher Commit) Audit-Index Links aktualisiert (Hash im Chat nicht protokolliert)

**Ergebnis: BESTANDEN** (mit Restpunkten unten)

**Bestanden / ok:**
- Interne Links funktionieren live (User-Test)  
- baseurl wird konsistent genutzt (`/einfach-geld-ordnen/...`)  
- CI/Actions: grün (User bestätigt)  
- Vendor/Bundler-Problem im Workflow behoben (Jekyll baut reproduzierbar)  
- Audit-Seiten werden wieder generiert (nicht mehr excluded)  

**Offen / Restpunkte (nächste Schritte):**
- Dieses Checklog wurde im Rahmen des Checks erweitert (append-only)  
- Evidence Register um aktuelle Commits + Live-Checks ergänzen (append-only)  
- `pillar/index.md` prüfen/aktualisieren: neue Pillar-Seite aufnehmen (falls gewünscht)  
- `LEARNINGS.md` um Learnings aus diesem Durchgang ergänzen (PowerShell Rename-Item, vendor exclude, Bundler in CI)
