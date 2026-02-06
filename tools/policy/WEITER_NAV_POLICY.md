# Weiter-Navigation Policy (SSOT im Repo, verbindlich)

Ziel: Wohlfuehlerlebnis ohne Sackgassen. Jede Seite hat im Block "## Weiter" exakt 3 sinnvolle naechste Schritte.

## Harte Regeln
- Genau 3 Links im Weiter-Block (Markdown-Liste).
- Kein Linktext "Weiter" (keine Platzhalter).
- Keine doppelten Ziele.
- Kein Self-Link.
- Direkt nach dem Weiter-Block steht `{% include no_sackgasse_footer.html %}`.

## Globale Anker (duerfen ueberall vorkommen)
- Start in 15 Minuten: {{ site.baseurl }}/seiten/start_in_15_minuten.html
- Downloads: {{ site.baseurl }}/seiten/downloads.html
- Rechner: uebersicht: {{ site.baseurl }}/seiten/rechner-uebersicht.html
- Projekt-ueberblick: {{ site.baseurl }}/pillar/index.html

## Core-Seiten: exakte Weiter-Targets (Reihenfolge ist Teil der Policy)
1) pillar/index.md
   1. Start in 15 Minuten
   2. Rechner: uebersicht
   3. Downloads

2) seiten/start_in_15_minuten.md
   1. Haushaltsbuch – ueberblick
   2. Downloads
   3. Rechner: uebersicht

3) seiten/der-weg.md
   1. Haushaltsbuch – ueberblick
   2. Downloads
   3. Projekt-ueberblick

4) seiten/haushaltsbuch.md
   1. Downloads
   2. Der Weg
   3. Rechner: uebersicht

5) seiten/rechner-uebersicht.md
   1. Start in 15 Minuten
   2. Downloads
   3. Projekt-ueberblick

6) seiten/downloads.html (und alle seiten/download*.html)
   1. Start in 15 Minuten
   2. Rechner: uebersicht
   3. Projekt-ueberblick

## Seitentypen (Default-Regel)
- Pillar-Seiten (pillar/*.md ausser index): Rechner → Downloads → Start15
- Rechner-Einzelseiten (*rechner*): Downloads → Start15 → Projekt-ueberblick
- Meta/Legal/Info (impressum/datenschutz/qualitaet/faq/changelog/self_service/projektbeschreibung): Projekt-ueberblick → Start15 → Downloads

## Thema-Pfade (Wohlfuehl-Fluss, konzeptionell)
Start15 → Haushaltsbuch → Pillar-Thema → Rechner-Thema → Download-Hub → Downloads → Projekt-ueberblick






