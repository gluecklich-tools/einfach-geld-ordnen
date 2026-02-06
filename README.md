layout: default
permalink: /README.html
# einfach-geld-ordnen

Einfaches Haushaltsbuch & Geld ordnen – **statische Inhalte** (GitHub Pages / Jekyll)

**Stand:** 2026-01-24 (Europe/Berlin)

Willkommen beim Projekt **„Einfach Geld ordnen“**.  
Ziel ist eine **klare, ruhige Finanz-Ordnung** mit **Vorlagen + Schritt-fuer-Schritt-Anleitungen**, die auch mit wenig Energie nutzbar sind.
## Inhalte

- Schritt-fuer-Schritt-Anleitungen zum Haushaltsbuch
- Vorlagen (LibreOffice/Excel) fuer Einnahmen, Ausgaben, Fixkosten, variable Kosten
- Tipps fuer Ordnung im Haushalt & Finanzplanung
- Strukturierte „Pillar“-Seiten fuer langfristige Nutzung
## Ziel

Das Projekt hilft dir dabei, **Einnahmen und Ausgaben klar zu erfassen**, Fixkosten zu ueberblicken und deine Finanzen langfristig zu ordnen – **ohne unnoetigen Aufwand** und ohne komplizierte Regeln.
## Nutzung (kurz)

1. **Vorlage herunterladen (Dual-Format**: **ODS Master + XLSX Export**)
2. Tabellen mit eigenen Daten fuellen
3. Schritt-fuer-Schritt-Anleitungen nutzen
4. ueberblick behalten (Fixkosten, variable Ausgaben, Ruecklagen)
## Datenschutz (wichtig)

Finanz- und Nachweisunterlagen liegen **nicht im oeffentlichen Repo**.  
Im Repo existiert nur `FINANZEN_README.md` als Hinweistext.
## Verbindliche technische Leitplanken (Kurzfassung)

- **Zero-Assumption / 100%+ realistisch moeglich:** Nichts annehmen, maximal gruendlich + Extra-QA.
- **Komplettcheck-Neustart:** Wenn neue Regeln dazukommen oder Unsicherheit besteht → kompletter Neu-Check.
- **UTF-8 ohne BOM** fuer Textdateien.
- Dateinamen: **ASCII-only** (`a-z0-9-_`), keine Umlaute, keine Leerzeichen.
- Jekyll Pages: explizite **`.html`-Permalinks**, **Permalink = Dateiname**.
- Interne Links: konsequent mit `{{ site.baseurl }}` (Project Site), keine Links ohne baseurl.

## Weiter
- [50 30 20]({{ site.baseurl }}/pillar/50-30-20.html)
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Index]({{ site.baseurl }}/index.html)
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







