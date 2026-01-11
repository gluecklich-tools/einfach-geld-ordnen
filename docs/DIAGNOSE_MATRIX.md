---
layout: default
title: "Diagnose‑Matrix – wenn etwas nicht klappt"
permalink: /docs/diagnose-matrix.html
---

# Diagnose‑Matrix (GitHub Pages / Jekyll)

| Symptom | Wahrscheinlichste Ursache | Fix (kurz) |
|---|---|---|
| Seite zeigt Raw‑Markdown | Front‑Matter fehlt oder falsches Layout/Permalink | Front‑Matter ergänzen, `layout: default`, sauberen `permalink` setzen |
| Link führt zu 404 (…`.md`) | Irgendwo wird `.md` verlinkt | Links auf `/seiten/<slug>.html` bzw. `/pillar/` umstellen, Quelltext‑Check `.md` = 0 |
| Download‑Link führt zu 404 | Baseurl fehlt oder Pfad/Dateiname stimmt nicht | Download immer via `{{ "/downloads/..." | relative_url }}` oder Include‑Button |
| Download‑Button fehlt | Include nicht eingebunden oder CSS fehlt | `{% include download-button.html ... %}` einfügen, `_includes/download-button.html` prüfen |
| Änderung lokal ok, online nicht | Cache / Actions noch nicht deployed | Actions‑Run checken, Inkognito + `Strg+F5` |
| Git commit sagt „nothing to commit“ | Du hast in falschem Ordner gearbeitet oder nichts geändert | `git status`, Pfad prüfen, ggf. Clone‑Replace nochmal durchführen |
