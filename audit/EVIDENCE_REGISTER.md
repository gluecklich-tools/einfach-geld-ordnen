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
