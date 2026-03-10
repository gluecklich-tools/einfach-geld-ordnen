# TODO – Einfach Geld ordnen

## Dual-KPI Active-Core vs Non-Core

- Active-Core ist die operative KPI fuer Orphan-Ref-Befunde.
- Non-Core ist eine getrennte Beobachtungs-KPI und darf operative Priorisierung nicht verfaelschen.
- P0-Handlungsdruck entsteht nur aus Active-Core-Befunden oder klaren Governance-/Tooling-Defekten.

### Learning und QA-Folgerung

- Hohe Repo-Treffer koennen vollstaendig aus Non-Core-Bereichen stammen.
- QA- und Scan-Auswertungen muessen Active-Core und Non-Core getrennt berichten.

### Status und Folgeaufgaben

- Status: Active-Core Orphan-Refs = 0 bei 214 gescannten Dateien.
- Non-Core bleibt separate Beobachtungsspur.
- Tooling und Governance sollen die Dual-KPI-Sicht dauerhaft abbilden.

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

EGO_TODO_DIGISTORE_PRO_LINK_V1
- [2026-02-22] Wenn Pro bei Digistore24 live ist: korrekten Pro-Digistore-Link eintragen (Pro-Seite, Downloads, Pricing-Tabelle, ggf. _data/offer.yml).

EGO_TODO_PRICES_AND_LINKS_V1
- [2026-02-22] Preise SSOT: Vollversion = 14,99 € | Pro = 24,99 € (ueberall identisch: seiten/, _includes/, _data/).
- [2026-02-22] pricing-table.html: Freebie = 0 €, Vollversion = 14,99 €, Pro = 24,99 €; keine kaputten HTML-Fragmente im Preis (z.B. "</p>").
- [2026-02-22] downloads.md: Vollversion/Pro mit Preisen anzeigen; Digistore24-Linktexte neutral ("Link folgt, sobald gesetzt").
- [2026-02-22] offer.yml (falls genutzt): Preise/Labels konsistent zu 14,99/24,99.
- [2026-02-22] Wenn Pro bei Digistore24 live ist: korrekten Pro-Link eintragen (Pro-Seite, Downloads, Pricing-Tabelle, offer.yml).
- [2026-02-22] Nach allen Preisfixes: price_mismatch_report neu erstellen und offene Preisstellen gezielt abarbeiten (keine Blind-Replaces).

## Claude / Modellsteuerung

- [P1] Claude-Endprofil 2026-03-10 in Brain, Learnings und reale Claude-Governance synchronisiert
- [P1] Aktive Claude-Prompts später gegen Endprofil prüfen (enge Rolle, Scope, Ausgabeformat, Ausschlüsse)
- [P1] Bei zukünftigen Claude-Einsätzen Mehrfachziele in einer Nachricht vermeiden
- [P1] Beispiel-basierte Steuerung gegenüber reinen Verbotslisten bevorzugen

- [P1] Claude-Audit-Regeln 2026-03-10 in reale Claude-Governance-Dateien nachgezogen
- [P1] Offene Qualitätsverben in Claude-Produktprompts nur noch mit harter Scope-Bremse zulassen
- [P1] Zwillingsfall-, Grenzfall- und Differenztest als Standardmodus für Claude-Audits festhalten
- [P1] Defaultisierung, Rahmung und wesentliche Annahmen bei Claude-Outputs aktiv prüfen

- [P1] Claude-Audit-Learnings 2026-03-10 in Prompt-Vorlagen / Governance / QA systematisch nachziehen
- [P1] Offene Qualitätsverben in Claude-Produktprompts nur noch mit harter Scope-Bremse zulassen
- [P1] Zwillingsfall- und Differenztest als Standardmodus für zukünftige Claude-Audits festhalten

- [ ] Governance: Chat-Scope-Split fuer Excel-/Builder-Block dauerhaft pruefen und vor jedem Builder-Commit Kontroll-Chat-Pruefung erzwingen.
