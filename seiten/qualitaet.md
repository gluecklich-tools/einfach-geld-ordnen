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
# Qualitaet & Prinzipien

Diese Seite beschreibt kurz, **woran du dich bei „Einfach Geld ordnen“ orientieren kannst** – ohne Fachchinesisch und ohne Marketing-uebertreibung.

## Was du hier bekommst
- **Klare Vorlagen** (Haushaltsbuch) zum Download
- **Einfache Schritt-fuer-Schritt-Anleitung**, damit du zuegig starten kannst
- **Datensparsame Nutzung**: Du arbeitest lokal in deiner Datei, nicht in einer Cloud-Zwangsloesung

> Ziel: Du sollst deine Finanzen **uebersichtlich ordnen** koennen – ohne dich durch 100 Menues zu kaempfen.

## Qualitaetsprinzipien
1. **Einfach vor komplex**  
   Lieber verstaendlich und robust als ueberladen.
2. **Fehlerarm vor fancy**  
   aenderungen werden so umgesetzt, dass sie reproduzierbar sind und nicht „zufaellig“ funktionieren.
3. **Datenschutz als Standard**  
   Keine Veroeffentlichung von sensiblen Finanzdaten, Nachweisen oder personenbezogenen Informationen.
4. **Kompatibilitaet pragmatisch**  
   Die Vorlagen sind so gebaut, dass sie in gaengigen Office-Umgebungen nutzbar bleiben (ohne Spezialtricks, die schnell brechen).
5. **Transparenz statt Versprechen**  
   Es gibt klare Grenzen, was das Produkt leisten kann – und was nicht.

## Wichtige Grenzen (ehrlich & klar)
- **Keine Steuerberatung, keine Rechtsberatung.**
- **Keine Garantie**, dass jede individuelle Konstellation (z. B. Sonderfaelle, exotische Systeme, sehr alte Software) ohne Anpassung laeuft.
- **Self-serve**: Das Produkt ist so aufgebaut, dass du es selbststaendig nutzen kannst. Es gibt keinen zugesicherten 1:1-Rueckfragen.

## Datenschutz 
- Deine Daten bleiben grundsaetzlich **bei dir**.
- oeffentliche Projektdateien enthalten **keine** Kontoauszuege, Auszahlungsnachweise, Behoerdenkommunikation oder aehnliche Dokumente.

Mehr dazu: [Datenschutz]({{site.baseurl}}/seiten/datenschutz.html)  
Impressum: [Impressum]({{site.baseurl}}/seiten/impressum.html)
## Weiter
- [Ueberblick]({{ site.baseurl }}/pillar/einfach-geld-ordnen.html)
- [Rechner]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
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
- Audit-Seite: {{site.baseurl}}/seiten/audit.html
- Evidence: assets/audit/YYYY-MM/
- Monatslauf laeuft per GitHub Actions (monthly-audit). Bei FAIL wird ein Issue erstellt.
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
