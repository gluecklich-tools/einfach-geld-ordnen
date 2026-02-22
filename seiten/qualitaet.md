---
permalink: /seiten/qualitaet.html
layout: default
title: "Qualitaet & Prinzipien"
permalink: /seiten/qualitaet.html
nav_group: meta
nav_order: 920
flow_systemlinks: true
description: "Qualitaet & Prinzipien – kurze Einordnung + klare nächste Schritte. Haushaltsbuch, Fixkosten, Rücklagen, Schulden: einfach ohne App."
---
# Qualität & Prinzipien

Diese Seite beschreibt kurz, **woran du dich bei „Einfach Geld ordnen“ orientieren kannst** – ohne Fachchinesisch und ohne Marketing-übertreibung.

## Was du hier bekommst
- **Klare Vorlagen** (Haushaltsbuch) zum Download
- **Einfache Schritt-für-Schritt-Anleitung**, damit du zügig starten kannst
- **Datensparsame Nutzung**: Du arbeitest lokal in deiner Datei, nicht in einer Cloud-Zwangslösung

> Ziel: Du sollst deine Finanzen **übersichtlich ordnen** können – ohne dich durch 100 Menüs zu kämpfen.

## Qualitätsprinzipien
1. **Einfach vor komplex**  
   Lieber verständlich und robust als überladen.
2. **Fehlerarm vor fancy**  
   änderungen werden so umgesetzt, daß sie reproduzierbar sind und nicht „zufällig“ funktionieren.
3. **Datenschutz als Standard**  
   Keine Veröffentlichung von sensiblen Finanzdaten, Nachweisen oder personenbezogenen Informationen.
4. **Kompatibilität pragmatisch**  
   Die Vorlagen sind so gebaut, daß sie in gängigen Office-Umgebungen nutzbar bleiben (ohne Spezialtricks, die schnell brechen).
5. **Transparenz statt Versprechen**  
   Es gibt klare Grenzen, was das Produkt leisten kann – und was nicht.

## Wichtige Grenzen (ehrlich & klar)
- **Keine Steürberatung, keine Rechtsberatung.**
- **Keine Garantie**, daß jede individülle Konstellation (z. B. Sonderfälle, exotische Systeme, sehr alte Software) ohne Anpassung läuft.
- **Self-serve**: Das Produkt ist so aufgebaut, daß du es selbstständig nutzen kannst. Es gibt keinen zugesicherten 1:1-Rückfragen.

## Datenschutz 
- Deine Daten bleiben grundsätzlich **bei dir**.
- öffentliche Projektdateien enthalten **keine** Kontoauszüge, Auszahlungsnachweise, Behördenkommunikation oder ähnliche Dokumente.

Mehr dazu: [Datenschutz]({{site.baseurl}}/seiten/datenschutz.html)  
Impressum: [Impressum]({{site.baseurl}}/seiten/impressum.html)
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

<!-- EGO_ORPHAN_LINKFIX_V2 -->
## Für Nerds (Transparenz)

- [Audit]({{ site.baseurl }}/seiten/audit.html)
- [Changelog]({{ site.baseurl }}/seiten/changelog.html)
- [Governance]({{ site.baseurl }}/seiten/governance.html)
- [QA Release Gate]({{ site.baseurl }}/seiten/qa-release-gate.html)
- [Proof: Rechner]({{ site.baseurl }}/seiten/proof-rechner.html)
- [Proof: Themen-Seite]({{ site.baseurl }}/seiten/proof-themen-seite.html)
