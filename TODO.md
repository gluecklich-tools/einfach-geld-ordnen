# TODO – Einfach Geld ordnen

Stand: 2026-01-24

## Premium-UX / Apple-Amazon DoD (Phase 0/1) — Pflicht vor Monetarisierung

[ ] Startseite: ruhiges Premium-Layout (Lesbarkeit, klare Abschnitte, keine Textwand)

[ ] Download-/Produktseite: in 30 Sekunden verstanden (Zielgruppe, Nutzen, Start)

[ ] „In 10 Minuten“-Onboarding-Seite: Schrittfolge + Beispielmonat getestet

[ ] FAQ/Troubleshooting: Top-10 Probleme + glasklare Loesungen (LibreOffice + Excel)

[ ] Template Dual-Format: ODS Master + XLSX Export (Versionierung sichtbar)

[ ] Smoke-Test: LibreOffice bestanden (Eingabe, Auswertung, typische aenderungen)

[ ] Smoke-Test: Excel bestanden (mind. Excel Web)

[ ] Self-serve Grenze ueberall konsistent (Website + FAQ + Newsletter-Footer)

[ ] QA-Gate aktualisiert und vollstaendig (keine abgebrochenen Zeilen, append-only)
## Angebot (ohne Newsletter) -- Pflicht vor Monetarisierung

[ ] Freebie ist fertig und prominent verlinkt (Downloads + Download-Hubs)
[ ] Vollversion: Button/CTA fuehrt zu Digistore24 (kein Login auf der Website)
[ ] Pro: Zusatz-Auswertungen + kleine Tools (Rechner/Checks) -- ebenfalls Digistore24
[ ] Onboarding-Seite existiert (10 Minuten Start) und verweist auf Freebie + Kauf-CTA
[ ] FAQ/Self-serve Grenze ist konsistent (keine Beratung, nur Anleitung)
[ ] Download-Hub-Index ist in 30 Sekunden verstanden (wo klicken, was bekomme ich)
## Release-Gate „Monetarisierung“ (Ergaenzung)

[ ] Monetarisierung erst aktivieren, wenn Newsletter-System-DoD erfuellt ist (siehe Block oben)
[ ] Monetarisierung erst aktivieren, wenn Apple/Amazon-DoD erfuellt ist (siehe Premium-Block oben)

## Weiter
- [50 30 20]({{ site.baseurl }}/pillar/50-30-20.html)
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Index]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}

<!-- INBOX_2026-02-19_SITEMAP_SEARCHCONSOLE_V1 -->
## Inbox 2026-02-19: Indexierung
- [ ] Google Search Console: Quota-Limit beachten; spaeter URL-Pruefung erneut.
- [ ] Bing Webmaster Tools: Site verifizieren + sitemap.xml einreichen.
- [ ] Nach 24-72h: Indexierungsstatus pruefen.
<!-- /INBOX_2026-02-19_SITEMAP_SEARCHCONSOLE_V1 -->

EGO_TODO_SITEMAP_REVIEW_PIPELINE_V1
- [2026-02-22] Review-Pipeline: Indexierbare Seiten immer aus sitemap.xml ableiten (SITEMAP_URL_COUNT==MAPPED_COUNT, MISSING==0).
- [2026-02-22] PS-Guardrail: Inline-if nicht als Ausdruck nutzen; Textblaecke nur als @' '@ (kein @" "@) wegen StrictMode.

EGO_TODO_REVIEW_CHECKLIST_AND_RECHECK_V1
## 2026-02-22 - Operative Review-Checkliste (Sitemap 98)

Arbeitsset:
- Nur sitemap.xml Seiten (98 URLs) = Bing/Google Set.

Pro Seite: Pflicht-Pruefpunkte (Herz-und-Nieren)
A) Frontmatter
- ab Zeile 1, ASCII --- / keine stray FM im Body
- permalink/title/description/nav_* nicht doppelt
- permalink .html, passt zum Dateinamen/Slug (ASCII-only Dateiname-Regel bleibt)
B) Interne Links
- nur {{ site.baseurl }} + .html
- keine trailing slashes / keine .md
- baseurl token spacing normalisieren (keine {{site.baseurl}})
- keine Tracking-Queries (?utm_...) in internen Links
C) Navigation
- "## Weiter" vorhanden, exakt 3 interne Links
- {% include no_sackgasse_footer.html %} vorhanden
- Leerzeile vor ## Weiter (Format-Hygiene)
D) Inhalt/Didaktik
- Linktext entspricht Ziel (keine falschen Labels wie "Ueberblick" wenn Ziel nicht Ueberblick)
- "Naechster Schritt" logisch (Funnel/Der Weg/Haushaltsbuch->Fixkosten usw.)
E) Sprache
- Rechtschreibung/Lesbarkeit
- konsistente Schreibweise (ue/ae/oe, keine Misch-Mojibake-Fallen)

Ergebnis je Seite:
- OK – so lassen
- oder Patch (klein, SSOT-konform) + Gates + Live

## Re-Check Plan
- Wenn Review der 98 sitemap-Seiten fertig ist:
  - Re-Check Seiten #1 bis #54 mit obiger Checkliste (zweiter Pass), um Altlasten zu catchen.

EGO_TODO_PS_REPLACE_GUARDRAIL_V1
- [2026-02-22] Guardrail: Bei allen Patches/Tools keine `-replace`-Konkatenation. Gruppen-Rewrites nur via `[regex]::Replace`.
