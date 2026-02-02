---
layout: default
title: "Transparenz & Verantwortung"
permalink: /seiten/governance.html
flow_systemlinks: true
---
# Transparenz & Verantwortung

Diese Seite beschreibt nur die oeffentlich relevanten Grundsaetze dieses Projekts.

Wichtig:
- **Interne Arbeitsanweisungen, Prompts, Notizen oder persoenliche Daten sind nicht Bestandteil des oeffentlichen Repos.**
- Oeffentlich sind nur Inhalte, die fuer die Website notwendig sind (z.B. Inhalte, Navigation, rechtliche Seiten).

## Public-Gate (oberstes Prinzip)

- Keine internen Prompts/Arbeitsanweisungen/Masterprompts im oeffentlichen Repo.
- Keine persoenlichen oder sensiblen Daten (Gesundheit, Klarname, private Adressen, Chat-Transkripte).
- Oeffentlich nur: rechtlich Noetiges (Impressum/Datenschutz) + Projektinhalte.

## Support / Verantwortung

- Inhalte und Vorlagen sind auf **Self-Service** ausgelegt.
- Fuer rechtliche Fragen gilt: keine Rechtsberatung.

## Weiter
- [Start In 15 Minuten]({{ site.baseurl }}/seiten/start_in_15_minuten.html)
- [Haushaltsbuch Vorlage Kostenlos]({{ site.baseurl }}/seiten/haushaltsbuch-vorlage-kostenlos.html)
- [Index]({{ site.baseurl }}/seiten/index.html)
{% include no_sackgasse_footer.html %}

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

<!-- EGO_AUDIT_L2_HINT_START -->
## Audit L2 (Monatslauf)
- Audit-Seite: {{ site.baseurl }}/seiten/audit.html
- Evidence: assets/audit/YYYY-MM/
- Monatslauf laeuft per GitHub Actions (monthly-audit). Bei FAIL wird ein Issue erstellt.
<!-- EGO_AUDIT_L2_HINT_END -->
