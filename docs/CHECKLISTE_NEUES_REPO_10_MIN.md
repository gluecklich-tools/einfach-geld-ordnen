---
layout: default
title: "Neues Repo in 10 Minuten – Checkliste"
permalink: /docs/checkliste-neues-repo-10-min.html
---

# Neues Repo in 10 Minuten (GitHub Pages / Jekyll) – Clone‑Replace Standard

> Zweck: In **10 Minuten** ein neues Projekt‑Repo starten, ohne Link‑Chaos, ohne Raw‑Markdown, mit stabilen Downloads.

## Ziel (DoD)
- GitHub Actions / pages-build-deployment: **grün**
- Inhalte werden als HTML gerendert (kein Raw‑Markdown im Browser)
- **Keine `.md`‑Links** im gerenderten HTML (Quelltext‑Check = **0 Treffer**)
- Downloads sind sichtbar & klickbar (über Include‑Button)
- Änderungen erfolgen nur als **FULL‑SWAP / CLONE‑REPLACE** (Ordner komplett ersetzen)

---

## 0) Repo‑Start (einmalig)
1. Repo klonen
2. Lokal öffnen (Explorer + Editor)
3. Prüfen: Root enthält z. B. `seiten/`, `pillar/`, `downloads/`, `_layouts/`, `_includes/`, `assets/`

---

## 1) Clone‑Replace Regeln (verbindlich)
- **Nie einzelne Dateien patchen** → immer **ganzen Ordner ersetzen**
- Zielordner (Beispiele): `seiten/` oder `pillar/` oder `_layouts/` oder `_includes/` oder `assets/` oder `downloads/`
- Vorgehen:
  1) Zielordner im Repo löschen  
  2) Ordner aus ZIP/Template **neu einfügen**  
  3) `git status` prüfen  
  4) commit + push  

---

## 2) Link‑Regeln (verbindlich)
- Keine `.md`‑Links im gerenderten HTML
- Interne Links nur:
  - `/seiten/<slug>.html`
  - `/pillar/`
- Robust (empfohlen):
  - `{{ "/seiten/<slug>.html" | relative_url }}`
  - `{{ "/pillar/" | relative_url }}`

---

## 3) Downloads‑Regeln (verbindlich)
- Downloads liegen unter `downloads/` im Repo‑Root
- Links zeigen **immer** über Jekyll:
  - `{{ "/downloads/datei.ext" | relative_url }}`
- Button‑Standard:
  - `{% include download-button.html file="downloads/datei.ext" label="Download" %}`

---

## 4) Commit‑Standard (verbindlich)
Format:
- `Full replacement / Clone-Replace: <ordner> (A# v###)`

Beispiele:
- `Full replacement / Clone-Replace: seiten (A3.2 v001)`
- `Full replacement / Clone-Replace: pillar (A3.1 v001)`
- `Full replacement / Clone-Replace: docs (A3.3 v001)`

---

## 5) Nach jedem Push prüfen (verbindlich)

### A) GitHub Actions
- Repo → Actions → letzter Run: **grün**

### B) Frontend (Cache ausschließen)
- Inkognito öffnen
- Seite laden
- `Strg+F5`

### C) `.md`‑Check (Beweis)
- Rechtsklick → **Seitenquelltext anzeigen**
- `Strg+F` → suche nach `.md`
- Ergebnis muss sein: **0 Treffer**

---

## 6) Mini‑Workflow (Copy/Paste)
```bash
# FULL‑SWAP: seiten
git add seiten
git commit -m "Full replacement / Clone-Replace: seiten (A3.2 v001)"
git push

# Docs
git add docs
git commit -m "Full replacement / Clone-Replace: docs (A3.3 v001)"
git push
```
