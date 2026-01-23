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
**Input:** (Commit-Hash, Branch, Repo-ZIP, Live-URL)  
**Evidence:** (Links, Screenshots, Logs)  
**Ergebnis:** BESTANDEN / NICHT BESTANDEN / TEILWEISE  
**Blocker:** (wenn nicht bestanden)  
**Risiken:**  
**Entscheidung (Team):**  
**Nächste Schritte:** (nur wenn bestanden / oder „Stop bis Fix“)  

---

# Retro-Protokoll (soweit möglich)

> Quelle für Retro: Commit-Historie (hash + message), vorhandene Governance-Dateien, sichtbare Live-Symptome aus Verlauf.
> Datumswerte sind teils unbekannt und müssen bei Bedarf aus Git/Actions ergänzt werden.

---

## CHECK-RETRO-000 – Projektanlage / Basiskonfiguration (soweit möglich)

**Typ:** Retro-Komplettcheck  
**Regelstand:** vor v019 (unbekannt)  
**Scope:** Repo-Grundstruktur, Jekyll Project Site, baseurl, Permalinks  
**Evidence (Commits):**
- `af0569f` Fix: use root-relative /assets/main.css for html-proofer compatibility
- `3be4051` Fix: remove baseurl from internal links for html-proofer
- `5d75b29` Fix: run html-proofer on baseurl root (_site/einfach-geld-ordnen)
- `21a380b` Fix: html-proofer baseurl handling for project site
- `c87cbc7` Fix: html-proofer ignore baseurl paths (correct option)

**Ergebnis:** TEILWEISE (auf dem Weg zur Stabilität)  
**Beobachtung:** Konflikt zwischen „html-proofer Erwartungen“ und „Project Site baseurl-Regel“ führte zu Iterationen.  
**Blocker damals:** Link/Asset-Pfade, baseurl-Inkonsistenzen.

---

## CHECK-RETRO-001 – Struktur & Inhalte Phase F (soweit möglich)

**Typ:** Retro-Teilcheck  
**Regelstand:** unbekannt (vor v019)  
**Evidence (Commits):**
- `be27ba0` Phase F abgeschlossen: Inhalte & Struktur vollständig korrigiert
- `11d77c9` Fix: add frontmatter to default layout (prevent frontmatter rendering)
- `b1bf7b3` Fix: Frontmatter, Titelabgleiche, UTF-8 ohne BOM (Pillar + Seiten konsistent)

**Ergebnis:** TEILWEISE  
**Beobachtung:** Frontmatter-Sichtbarkeit war ein harter Blocker und wurde gezielt adressiert.

---

## CHECK-RETRO-002 – Downloads/Links Stage 1–1b (soweit möglich)

**Typ:** Retro-Teilcheck  
**Regelstand:** Stage 1 / Stage 1b (aus Commit-Messages)  
**Evidence (Commits):**
- `0f56454` Add finished Excel & LibreOffice downloads
- `94a9815` Add initial downloads: guide, free version, full version
- `d5e9ff7` Add LibreOffice (.ods) versions for final downloads
- `46fce67` Fix: nav.yml baseurl-safe and standardized navigation titles (Stage 1)
- `61fd4b9` Fix: replace virtual link with real entry point on pillar basics (Stage 1)
- `9f95d1c` Fix: correct download links to existing Haushaltsbuch_Kostenlos files (Stage 1b)
- `a224699` Fix layout CSS binding, remove empty downloads, clean praxis index link

**Ergebnis:** TEILWEISE  
**Risiko:** Downloads wurden in Phasen „fertig“ geführt, obwohl sie später als nicht visionsgerecht eingestuft wurden (Switch-Gate notwendig).

---

## CHECK-RETRO-003 – UX Flow-Führung (soweit möglich)

**Typ:** Retro-Teilcheck  
**Evidence (Commits):**
- `325b1f8` Add systemische Flow-Führung (flow-footer) – UX-Fix

**Ergebnis:** TEILWEISE  
**Hinweis:** Flow-Führung ist zentral, muss aber gegen Kreisführung/Dead-Ends geprüft werden.

---

## CHECK-RETRO-004 – Governance v019 + QA Gate (soweit möglich)

**Typ:** Retro-Governancecheck  
**Regelstand:** v019  
**Evidence (Commits):**
- `b474677` Add governance + QA release gate (Publish & Freeze)
- `1c5cdf7` Governance: v019 + learnings (mode gate)

**Ergebnis:** BESTANDEN als Regel-Set (inhaltlich), Umsetzung folgt Check-Gates.

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
