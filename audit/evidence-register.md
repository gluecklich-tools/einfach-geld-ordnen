---
layout: default
title: Audit – Evidence Register
permalink: /audit/evidence-register.html
---

# Evidence Register (append-only)

## Live-URL
https://gluecklich-tools.github.io/einfach-geld-ordnen/

## Standard-Test-URLs (für jeden Check)
- Start: `/`
- Pillar Übersicht: `/pillar/index.html`
- Praxis Übersicht: `/seiten/index.html`

## Download-Gate Test (muss bei „Downloads deaktiviert“ 404 sein)
- `/downloads/Haushaltsbuch_Kostenlos.xlsx`
- `/downloads/Haushaltsbuch_Kostenlos.ods`
- `/downloads/Haushaltsbuch_Vollversion.xlsx`
- `/downloads/Haushaltsbuch_Vollversion.ods`

## Commit-Evidence (aus `git log` – Beispiele)
- `6a96285` BOM entfernt (Switch-Blocker)
- `1c5cdf7` Governance v019 + learnings
- `b474677` QA release gate hinzugefügt
- `325b1f8` Flow-Führung eingeführt

## Screenshot-Standard (Benennung)
- `EVID_YYYY-MM-DD_001_start.png`
- `EVID_YYYY-MM-DD_002_pillar.png`
- `EVID_YYYY-MM-DD_003_praxis.png`
- `EVID_YYYY-MM-DD_004_download_gate_404.png`

> Screenshots werden idealerweise im Repo in `audit/evidence/` abgelegt (oder extern gespeichert und hier referenziert).

---

## EVID-2026-01-23-001 – Komplettcheck Reset (Repo+Live+CI)

**Ziel:** Evidence für den Komplettcheck-Reset „Sekunde null“ (Regelstand v20.2, 100%+).

### CI / Build Evidence
- GitHub Actions: **grün** (User bestätigt)
- Relevante Commits im Durchgang:
  - `744a053` Workflow-Fix + Audit-Rename (CI stabilisiert / Audit-Dateien auf Slugs)
  - `b255b73` `.gitignore` BOM-Fix + neue Pillar-Seite `pillar/spielraum-ruecklagen.html`
  - `709a778` Audit-Seiten werden wieder gebaut (audit aus `_config.yml: exclude` entfernt)

### Live-URL Evidence (Stichprobe – muss 200 OK liefern)
- Start: `https://gluecklich-tools.github.io/einfach-geld-ordnen/`
- Pillar Index: `https://gluecklich-tools.github.io/einfach-geld-ordnen/pillar/index.html`
- Praxis Index: `https://gluecklich-tools.github.io/einfach-geld-ordnen/seiten/index.html`

### Audit-URL Evidence (Stichprobe – muss 200 OK liefern)
- Audit Index: `https://gluecklich-tools.github.io/einfach-geld-ordnen/audit/index.html`
- Checklog: `https://gluecklich-tools.github.io/einfach-geld-ordnen/audit/checklog.html`
- Evidence Register: `https://gluecklich-tools.github.io/einfach-geld-ordnen/audit/evidence-register.html`
- Rules Snapshot: `https://gluecklich-tools.github.io/einfach-geld-ordnen/audit/rules-snapshot.html`

### Download-Gate Evidence (bewusst OFF)
Erwartung: Solange Downloads deaktiviert sind, müssen typische Download-Pfade **404** liefern.
- `https://gluecklich-tools.github.io/einfach-geld-ordnen/downloads/Haushaltsbuch_Kostenlos.xlsx`
- `https://gluecklich-tools.github.io/einfach-geld-ordnen/downloads/Haushaltsbuch_Kostenlos.ods`
- `https://gluecklich-tools.github.io/einfach-geld-ordnen/downloads/Haushaltsbuch_Vollversion.xlsx`
- `https://gluecklich-tools.github.io/einfach-geld-ordnen/downloads/Haushaltsbuch_Vollversion.ods`

### Screenshot Evidence (externe Ablage ok)
- 2026-01-23: Live-Screenshots (Start/Pillar/Praxis/Audit) wurden im Chat dokumentiert (Serie aus mehreren Screenshots, User bestätigt: „alle Links funktional“).
- Optional für Repo: `audit/evidence/EVID_2026-01-23_001_start.png` usw.
