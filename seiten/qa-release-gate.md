---
layout: default
title: "QA Release Gate"
permalink: /seiten/qa-release-gate.html
---
# QA Release Gate

Diese Seite beschreibt die Grundregeln, damit nichts kaputt geht:

- Interne Links nutzen {{ site.baseurl }} und enden auf .html.
- Keine Sackgassen: Weiter-Block + Footer sind vorhanden.
- Live-Check immer mit Projekt-URL (nicht Root-Domain).

## Weiter

- [Naechster Schritt]({{ site.baseurl }}/seiten/start_in_15_minuten.html)
- [Vorlage/Download]({{ site.baseurl }}/seiten/haushaltsbuch-vorlage-kostenlos.html)
- [Uebersicht]({{ site.baseurl }}/seiten/index.html)


{% include no_sackgasse_footer.html %}

<!-- EGO_LAW_RUNNER_START -->
## Gesetz: Ein-Rutsch Ablauf (niemals abweichen)
APPLY -> GATES -> COMMIT/PUSH -> LIVE-HEAD-200
- APPLY: nur idempotente Apply-Skripte, UTF-8 ohne BOM, binaersicher, keine Side-Effects.
- GATES: mindestens .\tools\ego-run.ps1; weitere Runner nur wenn Datei existiert.
- COMMIT/PUSH: nur wenn git status --porcelain nicht leer. Sonst NO_COMMIT.
- LIVE: HEAD-200 Smoke auf Kern-URLs.
Wenn ein Task nicht in diesen Ablauf passt: zuerst so umbauen, dass er passt.
Kein Renegade.
<!-- EGO_LAW_RUNNER_END -->

<!-- EGO_RUNNER_PIN_START -->
> Gesetz (Repo): Ab jetzt wird nur noch so gearbeitet:
>
> **.\tools\ego-law-run.ps1**
>
> Flow ist immer: APPLY -> GATES -> COMMIT/PUSH -> LIVE-HEAD-200
>
> Debug (Ausnahme): nur mit klarer Absicht, danach wieder Runner.
<!-- EGO_RUNNER_PIN_END -->
