---
layout: default
title: "Transparenz & Verantwortung"
permalink: /seiten/governance.html
nav_group: seiten
flow_systemlinks: true
description: "Transparenz & Verantwortung - kurze Einordnung + klare naechste Schritte. Haushaltsbuch, Fixkosten, Ruecklagen, Schulden: einfach ohne App."
---
Diese Seite beschreibt nur die öffentlich relevanten Grundsätze dieses Projekts.

Wichtig:
- **Interne Arbeitsanweisungen, Prompts, Notizen oder persönliche Daten sind nicht Bestandteil des öffentlichen Repos.**
- öffentlich sind nur Inhalte, die für die Website notwendig sind (z.B. Inhalte, Navigation, rechtliche Seiten).

## Public-Gate (oberstes Prinzip)

- Keine internen Prompts/Arbeitsanweisungen/Masterprompts im öffentlichen Repo.
- Keine persönlichen oder sensiblen Daten (Gesundheit, Klarname, private Adressen, Chat-Transkripte).
- öffentlich nur: rechtlich Nötiges (Impressum/Datenschutz) + Projektinhalte.

## Self-Serve und Verantwortung

- Inhalte und Vorlagen sind auf **Self-Serve** ausgelegt.
- Für rechtliche Fragen gilt: keine Rechtsberatung.
## Weiter
- [überblick]({{ site.baseurl }}/pillar/einfach-geld-ordnen.html)
- [Rechner]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
{% include no_sackgasse_footer.html %}


## Gesetz: Ein-Rutsch Ablauf (niemals abweichen)
APPLY -> GATES -> COMMIT/PUSH -> LIVE-HEAD-200
- APPLY: nur idempotente Apply-Skripte, UTF-8 ohne BOM, binärsicher, keine Side-Effects.
- GATES: mindestens .\tools\ego-run.ps1; weitere Runner nur wenn Datei existiert.
- COMMIT/PUSH: nur wenn git status --porcelain nicht leer. Sonst NO_COMMIT.
- LIVE: HEAD-200 Smoke auf Kern-URLs.
Wenn ein Task nicht in diesen Ablauf passt: zürst so umbaün, daß er passt.
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

<!-- EGO_AUDIT_L2_HINT_START -->
## Audit L2 (Monatslauf)
- Audit-Seite: {{site.baseurl}}/seiten/audit.html
- Evidence: assets/audit/YYYY-MM/
- Monatslauf läuft per GitHub Actions (monthly-audit). Bei FAIL wird ein Issü erstellt.
<!-- EGO_AUDIT_L2_HINT_END -->

{% include no_sackgasse_footer.html %}
