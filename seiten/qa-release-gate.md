---
layout: page
title: "QA Release Gate"
permalink: {{ site.baseurl }}/seiten/qualitaet.html
---

# QA Release Gate

Diese Seite beschreibt die Grundregeln, damit nichts kaputt geht:

- Interne Links nutzen {{ site.baseurl }} und enden auf .html.
- Keine Sackgassen: Weiter-Block + Footer sind vorhanden.
- Live-Check immer mit Projekt-URL (nicht Root-Domain).

## Weiter

- Rechner: [Rechner-Uebersicht]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- Downloads (Freebie): [Kostenlose Vorlage]({{ site.baseurl }}/seiten/haushaltsbuch-vorlage-kostenlos.html)
- Vollversion: [Haushaltsbuch Vollversion]({{ site.baseurl }}/seiten/haushaltsbuch-vollversion.html)

{% include no_sackgasse_footer.html %}

{% include disclaimer_finanzinfo.html %}

<!-- TOOLS_READONLY_GUARD_v1 -->

## Gate: Tools-ReadOnly (TOOLS_READONLY_GUARD_v1)

**Vor jedem Commit:**
- git status ist **clean**.

**Wenn ein Tool gelaufen ist (alles unter ./tools):**
- git status --porcelain ist **leer** (Repo blieb unveraendert).
- Wenn nicht leer: **Commit ist geblockt**. Sofort Notbremse:
  - git restore .
  - git clean -fd
  - Danach Ursache finden (Tool ist nicht read-only) und Regelverstoesse entfernen.
