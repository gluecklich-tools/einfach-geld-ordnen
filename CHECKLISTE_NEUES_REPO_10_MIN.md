# Neues Repo in 10 Minuten (GitHub Pages / Jekyll) — Clone-Replace Standard

## Ziel (DoD)
- GitHub Actions / pages-build-deployment: ✅ grün
- Inhalte werden als HTML gerendert (kein Raw-Markdown im Browser)
- 0× `.md` im gerenderten HTML (Seitenquelltext)
- Downloads sichtbar & klickbar aus `/downloads/`
- Änderungen nur per FULL-SWAP / CLONE-REPLACE (Ordner komplett ersetzen)

---

## 0) Repo-Start (einmalig)
1. Repo klonen
2. Lokalen Ordner öffnen (Explorer + Editor)
3. Prüfen: Root enthält z. B. `seiten/`, `pillar/`, `downloads/`, `_layouts/`, `_includes/`, `assets/`

---

## 1) Clone-Replace Regeln (verbindlich)
- **Nie** einzelne Dateien „patchen“
- Immer **ganzen Ordner ersetzen**:
  - `seiten/` oder `pillar/` oder `_layouts/` oder `_includes/` oder `assets/` oder `downloads/`
- Vorgehen:
  1) Zielordner im Repo **löschen**
  2) Ordner aus ZIP/Template **neu einfügen**
  3) `git status` prüfen
  4) commit + push

---

## 2) Link-Regeln (verbindlich)
- Keine `.md`-Links im gerenderten HTML
- Interne Links nur:
  - explizit `.html`
  - oder `/pillar/`
- Empfehlung (robust):
  - `{{ "/seiten/<slug>.html" | relative_url }}`
  - `{{ "/pillar/" | relative_url }}`

---

## 3) Downloads-Regeln (verbindlich)
- Downloads liegen **nur** in `/downloads/` im Repo-Root
- Links zeigen **nur** auf `/downloads/<datei>`
- Dateien sind case-sensitive (GitHub): Name muss exakt stimmen

Optional (Standard-UI):
- `{% include download-button.html file="..." label="..." hint="..." %}`

---

## 4) Commit-Standard (verbindlich)
Format:
`Full replacement / Clone-Replace: <ordner> (A# v###)`

Beispiele:
- `Full replacement / Clone-Replace: seiten+pillardateien (A1 v001)`
- `Full replacement / Clone-Replace: layouts+includes+assets (A2 v001)`
- `Full replacement / Clone-Replace: pillar (A3.1 v001)`
- `Full replacement / Clone-Replace: seiten (A3.2 v001)`

---

## 5) Nach jedem Push prüfen (verbindlich)
### A) GitHub Actions
- Repo → Actions → letzter Run **grün**

### B) Frontend (Cache ausschließen)
- Inkognito öffnen
- Seite laden
- `Strg+F5`

### C) `.md`-Check (Beweis)
- Rechtsklick → **Seitenquelltext anzeigen**
- `Strg+F` → Suche nach `.md`
- Ergebnis muss sein: **0 Treffer**

---

## 6) Mini-Workflow (Copy/Paste)
### FULL-SWAP: seiten
```bash
git add seiten
git commit -m "Full replacement / Clone-Replace: seiten (A# v###)"
git push
