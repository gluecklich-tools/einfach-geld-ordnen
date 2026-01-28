---
layout: page
title: "Transparenz & Verantwortung"
permalink: {{ site.baseurl }}/seiten/governance.html
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

- [Start]({{ site.baseurl }}/index.html)
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Rechner]({{ site.baseurl }}/seiten/rechner-index.html)

{% include no_sackgasse_footer.html %}

<!-- TOOLS_READONLY_GUARD_v1 -->

## QA-Sicherheitsregel: Tools sind read-only (TOOLS_READONLY_GUARD_v1)

**Ziel:** Kein Script darf "aus Versehen" Repo-Dateien aendern (Frontmatter/Permalinks/Links). Tools duerfen nur Reports erzeugen.

### Regeln
- **Tools in ./tools sind read-only** bezogen auf Repo-Inhalte.
- Erlaubt sind **nur Report-Dateien** unter ./tools/ (z.B. link-scan-report.txt).
- **Verboten:** automatisches Umschreiben von .md/.yml/.yaml/.html durch "Scan"-Tools.
- **Scan und Fix strikt trennen:** Ein Fix (falls je noetig) ist ein separates Script und braucht ein explizites -Fix Flag.
- **Keine dynamische Tool-Auswahl** (verboten: Select-Object -First 1 auf Script-Namen und dann ausfuehren). Immer exakt benennen.
- **Ausfuehren nur ueber Read-Only-Wrapper:** Vorher/Nachher git status --porcelain muss leer sein.
- Wenn ein Tool doch schreibt: **sofort** git restore . und git clean -fd (Notbremse), Diff sichern.

### Pflicht-Wrapper (lokal)
- Jede Tool-Ausfuehrung laeuft ueber einen Wrapper, der nach dem Run abbricht, wenn das Repo nicht mehr clean ist.
