<!-- EGO_MANAGED_BLOCK:FULL_PROJECT_AUDIT_RECONCILIATION_V1:START -->
## ROADMAP LOCK AFTER MONAT RESTBLOCK CLOSEOUT - 2026-03-26

- Der Source-Contract-/Workbook-Identity-Reconcile-Strang bleibt gruen geschlossen.
- Der MONAT-Restblock-Strang ist jetzt ebenfalls gruen geschlossen.
- ROWS 26:37 und ROWS 38:59 sind deterministisch realisiert; finaler Scope-Scan meldet NO_NEXT_OPEN_SCOPE=PASS.
- Aktiver Gesamtpfad bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- _INTERN bundle_release_zips bleibt explizit gesperrt und non-canonical bis zu spaeterer Identitaetsfreigabe, spaeterem Rebuild oder spaeterer Hash-belegter Freigabe.
- Verbindliche Reihenfolge ab jetzt:
  1) governance sync des grueneren MONAT-Closeouts abgeschlossen
  2) WORKBOOKWIDE_CHAIN_GENERAL_SCAN ausserhalb MONAT
  3) danach erst weiterer exakter workbookweiter Leaf-Apply unter verified-stage only
  4) spaeter erst Release-/Bundle-/Funnel-/Sitemap-/Bing-/GSC-/Paid-Repriorisierung in neuem Scope
- Dieser Lock behauptet keine Bundle-Freigabe, keinen Bundle-Rebuild und keine Paid-Freigabe.
<!-- EGO_MANAGED_BLOCK:FULL_PROJECT_AUDIT_RECONCILIATION_V1:END -->

<!-- EGO_MANAGED_BLOCK:ENTERPRISE_MASTERPLAN_PRIORITY_LOCK_V1:START -->
## ROADMAP NOTE - AFTER BUDGETS CLOSEOUT - 20260328

- MONAT-Strang bleibt gruener Closeout-Stand.
- PLANUNG-Strang bleibt gruener Closeout-Stand.
- JAHR-Strang bleibt gruener Closeout-Stand.
- BUDGETS-Strang ist jetzt ebenfalls gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-work-under-verified-stage-only-after-budgets-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_BUDGETS_CLOSEOUT
- Kein Rueckfall in BUDGETS ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ENTERPRISE_MASTERPLAN_PRIORITY_LOCK_V1:END -->

<!-- EGO_MANAGED_BLOCK:DOC_PDF_BACKEND_CONTRACT_V1:START -->
## ROADMAP NOTE - DOC PDF BACKEND CONTRACT - 20260323

- Die Kette fuer README-/Anleitung-PDF bleibt kanonisch definiert und gruen abgeschlossen.
- Dieser Strang ist aktuell nicht das aktive Thema.
- Der operative Folgepfad wurde auf den Recovery-Closeout-Reconcile umgelegt.
<!-- EGO_MANAGED_BLOCK:DOC_PDF_BACKEND_CONTRACT_V1:END -->

<!-- EGO_MANAGED_BLOCK:ALWAYS_SYNC_EVERY_RUN_HARDLAW_V1:START -->
## ROADMAP HARDENING NOTE - 20260317_173141

- Globales Laufgesetz verankern: jeder fachliche RUN ist Sync-RUN.
- Schrittweise Folgearbeit: Runner/Parser/Emit-Standards so haerten, dass bekannte Failure-Klassen gar nicht mehr erzeugt werden.
- Nach gruener Verankerung dieser Invariante geht das Projekt wieder in artefaktbasierte Fachpriorisierung.
<!-- EGO_MANAGED_BLOCK:ALWAYS_SYNC_EVERY_RUN_HARDLAW_V1:END -->

<!-- SSOT HEADER (autogen by ssot-refresh.ps1) -->
Datum: 2026-02-27
Rolle: ROADMAP
Archiv: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\_ARCHIVE\20260227_210302_847_6343\ROADMAP_INTERNAL.md
Archiv-SHA256: b8fc3e99bbfa6d9d6cdbc1ad3104799124816039ce974da054db11fefb6844ce

Gesetz: Diese Datei ist Teil der SSOT. Nach jeder Aenderung muss ssot-refresh.ps1 laufen.
Siehe: SSOT_SYSTEM_MAP_INTERNAL.md

---

<!-- EGO_ENTERPRISE_SYNC_BEGIN -->

## Enterprise Sync (SSOT)

Dieser Block ist der gemeinsame "Brain-Stamm": er vernetzt die wichtigsten Enterprise-Regeln, Learnings und den aktuellen Stand.

### P0 Gates (verbindlich)

- SCAN → PLAN → APPLY → VERIFY → REPORT (Report immer, auch bei STOP)
- WIP-Limit: max 1 Item unter ## WIP in TODO.md (Stop-the-line)
- Exclude-Policy: _patch_backups/_reports/_local/_TRASH/.git/node_modules
- Wahrheit = lokales Dateisystem (Reports/Backups/Inventar). Chat ist nur UI.

### Runner Preflight (P0, aktiv)

- Preflight erzwingt: SSOT Doc Guard + PS Parser Lint vor Runner.
- Fix/Hardening: Preflight nutzt $PSCommandPath fuer Pfade (nicht $MyInvocation-Interpolation / Backslash-Fallen).
- Guard-Verhalten: Baseline-Write → STOP bei Aenderung → zweiter Run OK (keine Acknowledge-Parameter).

### Parser-Lint (P0)

- ps-parser-lint-run.ps1 muss gruen sein, bevor Runner/Autopilot zaehlt.

### Funnel-Scan (Quelle der Wahrheit: Sitemap)

- seiten/*.md Count kann kleiner sein als "oeffentlich".
- Live/Index-relevant ist sitemap.xml (Google/Bing): aktuell TOTAL_URLS=98.
- Mechanik-Finding: Batch out-of-range vermeiden (Skip >= TOTAL -> leere Reports).

### Enterprise Live-Safety (neben Sitemap notwendig)

- robots.txt korrekt (Sitemap-URL, keine ungewollten Disallows).
- Canonical/noindex sauber (keine Duplicate/Trailing-Slash Chaos, keine internen Seiten im Index).
- Jede Sitemap-URL live: HTTP 200 (keine 404/500, keine Redirect-Chains).
- Interne Link-Integritaet: mindestens Weiter + next/prev/hub Targets existieren.
- Build/Smoke: Jekyll/GitHub Pages Build ohne Errors; minimale Smoke-Checks auf robots/sitemap/top pages.
- Monitoring light: Analytics + (optional) taeglicher HEAD-Sanity-Check.

### Scan v2 (naechste Ausbaustufe, geplant)

- title missing als Finding (z.B. einfach-geld-ordnen-haushaltsbuch.md hatte leeres title-Feld im Extract).
- nav_group/nav_order Konsistenz (mit klarer Ausnahmen-Liste).
- Link-Target-Existenz (Weiter-Links + Flow-Links) + Mismatch-Policy als Standard.

### Referenz-Reports (zuletzt)

- funnel_scan_summary_20260225_094821.md
- sitemap_inventory_20260225_094945.md

<!-- EGO_ENTERPRISE_SYNC_END -->
<!-- EGO_PWSH_ONLY_V1:START -->
## PWSh-only Gesetz (verbindlich)

- **Es wird projektweit ausschließlich PowerShell 7+ verwendet:** pwsh (Standard: pwsh -NoProfile).
- **Keine Beispiele/Anweisungen mehr mit** powershell.exe / Windows PowerShell 5.1.
- Alle Runner/Gates/Tools/Anleitungen sind **pwsh-first** und enthalten Session-Gates.
- Wenn ausnahmsweise historische PS5.1-Fallen dokumentiert sind, dann **nur als „historisch“** (kein Nutzer-Workflow).

<!-- EGO_PWSH_ONLY_V1:END -->
# ROADMAP_INTERNAL.md

<!-- ENTERPRISE_LAW_V1 -->

## Enterprise-Gesetz (verbindlich)

Ab jetzt gilt ohne Ausnahme:

1) **Enterprise-Niveau ist Maß der Dinge. Punkt.**  
   Formulierungen wie „optional / kann / vielleicht / wäre schön“ sind **nicht zulässig** in Plan/Anweisungen, wenn ein sauberer Enterprise-Weg existiert.

2) **Standard-Ablauf ist verpflichtend:** **SCAN → PLAN → APPLY → VERIFY → REPORT**  
   *REPORT immer*, auch bei STOP.

3) **Risiko-Minimierung ist Pflicht.**  
   Keine Monster-„Inline-Blöcke“/Copy-Paste-Ketten, wenn dadurch Parser-/Scope-Schäden wahrscheinlich werden.  
   Stattdessen: **Tools/Runner als Dateien**, Schritt-für-Schritt, mit harten Anchors und Idempotenz-Guards.  
   (Fallstudie: StrictMode/Here-String/Scope-Bruch → Variablen „not set“, Step-Funktion weg).  

4) **Backups sind Pflicht bei jeder Änderung (APPLY).**  
   `_patch_backups\...` immer, niemals „schnell mal so“.

5) **Clone-/Expansion-Kompatibilität ist Pflicht.**  
   Tools/Runner müssen **RepoRoot + InternalRoot (env:EGO_INTERNAL_DIR)** als Parameter akzeptieren, keine Hardpaths.

Einzige erlaubte Ausnahme:  
Wenn der Enterprise-Weg **kostenlos technisch nicht möglich** ist, wird **die beste sichere Variante** gewählt, die **das Projekt nicht gefährdet**.  
Diese Ausnahme muss im PLAN explizit begründet werden.

<!-- /ENTERPRISE_LAW_V1 -->

## Nächste Meilensteine:
- **MVP02 Content-Rollout**: Implementierung von Themen-Seiten und Rechnern.
- **Automatisierung optimieren**: Weitere Automatisierungen und Integration von Tools zur Qualitätssicherung.
- **Phase 2 - Content-Ausbau**:
  - Themen-Seiten-Cluster (Top 5 zuerst)
  - Rechner (statische JS Mini-Rechner) nach Priorität
- **Phase 3 - Distribution**:
  - SEO Interlinking, saubere Hubs, keine Sackgassen
  - Analytics Events optional (privacy-friendly), erst nach Content-Basis

<!-- KLAUS_CONVERSION_FIRST_V1 -->
# Conversion-First Architektur (V1)

## Zielbild
EGO ist kein Wiki. EGO ist ein Conversion-System (Self-Serve, ohne Support).

## Rendite-Kette (verbindlich)
Verstehen -> Tun (Rechner/Schnellstart) -> Mitnehmen (Download) -> Upgrade (Voll/Premium)

## Startseiten-Gesetz (Top-3)
Above-the-fold nur 3 Primaeraktionen:
1) Schnellstart (15 Minuten)
2) Schuldenfrei
3) Fixkosten senken

Alles andere ist sekundaer und wird nach unten/auf Hubs verschoben.

## Navigations-SSOT-Gesetz
Ein Ziel (URL) hat genau einen offiziellen Namen.
Ein Name darf nur genau ein Ziel haben.
Keine Synonyme in Navigation/Weiter/Startseiten-Listen.

## Weiter-Block-Gesetz (3 feste Bedeutungen)
Jede Content-Seite hat unter "## Weiter" exakt 3 Links:
1) Zum Rechner: <Name>
2) Zum Download: <Name>
3) Weiter im Thema: <Name>

Keine generischen Linktexte wie "Naechster Schritt".

## Dopplungs-Verbot (Startseite / Header / Listen)
- Gleiche URL mit unterschiedlichen Labels: verboten.
- Gleicher Labeltext mit unterschiedlichen URLs: verboten.
- "Seiten-Uebersicht" darf nicht auf Schnellstart zeigen.

## Umsetzungsvorgabe
Aenderungen sind repo-weit konsistent auszurollen:
GOVERNANCE -> QA_GATE -> LEARNINGS -> ROADMAP -> dann Content/Navigation.

## Roadmap-Update (V1, Reihenfolge)
1) Blocker: Frontmatter sichtbar -> repo-weit fixen
2) Startseite: Top-3 + sekundaer Bereiche, Dopplungen raus
3) NAV-SSOT: URL->Name festlegen (Kernziele)
4) Weiter-Bloecke: 3 feste Bedeutungen + deskriptive Texte
5) Header/Nav: minimal, SSOT-konform
6) Thema-Seiten: Funnel-Layout (Problem->Rechner->Download->Upgrade)

<!-- INBOX_2026-02-19_SITEMAP_SEARCHCONSOLE_V1 -->
## Inbox 2026-02-19: Roadmap-Update (Indexierung)
- (A) Google Search Console: Property bestaetigen, Sitemap (sitemap.xml) eingereicht lassen, spaeter URL-Pruefung wiederholen falls Quota-Limit.
- (B) Bing Webmaster Tools: Site hinzufuegen/verifizieren, Sitemap (sitemap.xml) einreichen.
- (C) Nach 24-72h: Indexierungsstatus checken; nur bei echten Fehlermeldungen handeln.
<!-- /INBOX_2026-02-19_SITEMAP_SEARCHCONSOLE_V1 -->

<!-- SSOT_PS_HERESTRING_GUARD_V1 -->
### PowerShell: Here-String Guard (SSOT Pflichtregel) [2026-02-23]

**Problemklasse (wiederkehrend):** SSOT-/Report-Text enthält Beispiele wie `$items`, `$tsvFiles`, etc.  
Wenn ein Textblock versehentlich als **expandierender** Here-String (`@" ... "@`) gebaut wird, versucht PowerShell Variablen zu expandieren → Abbruch: *"The variable '$items' cannot be retrieved because it has not been set."*

**SSOT-Regel (hart):**
- Für alle SSOT-Textblöcke/Markdown-Blöcke in Tools/Runnern/Apply-Scripts gilt:
  - **Nur** `@' ... '@` verwenden (single-quoted here-string).
  - **Nie** `@" ... "@` verwenden, wenn der Inhalt `$...` oder Backticks enthält.
- Wenn dynamische Teile nötig sind (Datum/Version): **nachträglich ersetzen**, z.B. `.Replace('2026-02-23', $stamp)`.

**Beispiel (korrekt):**
- `$txt = @'
  Beispiel: `$items = @(Get-ChildItem ...)`
  '@`

**Beispiel (verboten):**
- `$txt = @"
  Beispiel: `$items = @(Get-ChildItem ...)`
  "@`

<!-- SSOT_TSV_HEADERLESS_GUARD_V1 -->
### TSV: Headerless-Guard (Inventory/Queues) [2026-02-23]

**Problemklasse (wiederkehrend):** TSV-Datei ohne Header (erste Zeile ist direkt `1<TAB>https://...`)  
Wenn ein Tool das per `Import-Csv` lädt, wird die erste Zeile als Header interpretiert → **IDX 1 fehlt** → Fehler wie `STOP: idx not found: 1`.

**SSOT-Regel (hart):**
- Wenn TSV **headerless** sein kann, darf es **nicht** blind per `Import-Csv` geladen werden.
- Loader MUSS robust sein:
  - Erkennung: erste Zeile matcht `^\s*\d+\t` ⇒ **headerless** ⇒ manuell splitten: `IDX, URL, PERMALINK, SOURCE`
  - sonst: **Header-TSV** ⇒ `Import-Csv -Delimiter "`t"`
- Optional (empfohlen): Inventory-TSV mit Header pflegen: `IDX<TAB>URL<TAB>PERMALINK<TAB>SOURCE`

**Fix-Pattern (PowerShell):**
- `if($lines[0] -match '^\s*\d+\t'){ ...split "`t",4... } else { Import-Csv -Delimiter "`t" }`

<!-- SSOT_PS_NO_MONSTER_REGEX_V1 -->
### PowerShell: No “Monster-Regex” (RegexTimeout-Guard) [2026-02-23]

**Problemklasse (wiederkehrend):** Große `(?s)...*?`-Regex über ganze Dateien kann in PowerShell an `RegexMatchTimeoutException` scheitern oder sehr langsam werden (z.B. Patchen von `param(...)` mit `.*?`).

**SSOT-Regel (hart):**
- Keine “Monster-Regex” über komplette Dateien für strukturelle Patches (param-block, frontmatter, includes).
- Stattdessen deterministische Strategien verwenden:
  1) **Klammerzählung** (z.B. `param(...)` Ende finden),
  2) **Line-based** Patches (gezielte Zeilen ersetzen),
  3) **AST/Parser** (wenn sinnvoll),
  4) **kleine Regex** nur für *lokale* Matches (kurze Zeilen/Abschnitte).

**Patch-Standard:**
- Wenn Struktur bekannt ist (z.B. `param(` … `)`): per Index + Depth-Count.
- Wenn Erkennung nötig ist: erst **SCAN** mit line-based “grep” (z.B. `Select-String`) → dann exakt patchen.

**Optional (nur wenn unvermeidbar):**
- Regex-MatchTimeout explizit setzen und Pattern verkleinern (aber Standard bleibt: vermeiden).

<!-- SSOT_PS_QUOTE_ESCAPING_GUARD_V1 -->
### PowerShell: Quote-/Escaping-Guard (ParserError Prävention) [2026-02-23]

**Problemklasse (wiederkehrend):** ParserErrors durch ungünstige Escapes in Strings, v.a. `\"` in doppelten Anführungszeichen oder gemischtes Escaping in `throw`-Meldungen.

**SSOT-Regel (hart):**
- In PowerShell **keine** `\"`-Sequenzen in normalen String-Literalen verwenden.
- Für Text/Fehlermeldungen/Marker:
  - bevorzugt **Single Quotes**: `'...'` (keine Interpolation, kein Escaping nötig)
  - oder `("... {0} ..." -f $var)` / `("{0}" -f ...)` für sichere Formatierung
- In SSOT-Textblöcken weiterhin: **nur** `@' ... '@` (keine Interpolation).
- Wenn ein String tatsächlich `"` enthalten muss: entweder Single Quotes außen verwenden oder `""` innerhalb eines double-quoted Strings (PowerShell-Standard), aber **kein** Backslash-Escaping.

**Beispiele (korrekt):**
- `throw 'STOP: srcFile init line $srcFile = "" not found'`
- `throw ("STOP: missing file: {0}" -f $p)`

**Beispiele (verboten):**
- `throw "STOP: $srcFile=\"\" not found"`  (führt regelmäßig zu ParserError)

<!-- SSOT_RUNNER_POLICYBLOCKS_GATING_V1 -->
### Runner-Regel: policy_blocks Gating + Leak-Check (Rendered) [2026-02-23]

**Ziel:** Runner muss Live-Wahrheit abbilden, ohne False-Positives.

**Gating-Regel:**
- `policy_blocks: show` (Frontmatter):
  - Pflicht: Hinweis(wichtig) + Aktualität/Audit + KI-Hinweis müssen gerendert sein.
  - Checks dürfen **robust** sein (Textvarianten tolerieren).
- Default / hide:
  - Die Policy-Blöcke dürfen **nicht** gerendert sein.
  - Leak-Checks müssen **strikt** sein (nur block-spezifische Marker), sonst False-Positives.

**Empfohlene Marker:**
- Require (robust):
  - Hinweis: `(Hinweis|Wichtig)`
  - Audit/Aktualität: `Aktualit(aet|[aä]t)\s+und\s+Audit`
  - KI: `\bKI\b|Künstliche Intelligenz|Kuenstliche Intelligenz`
- Leak (strikt):
  - Hinweis: `Hinweis\s*\(wichtig\)`
  - Audit: `Aktualit(aet|[aä]t)\s+und\s+Audit[-– ]Hinweis`
  - KI: `KI[- ]Hinweis`

**StrictMode-Safety (Pflicht):**
- Temporäre Flags (z.B. `$hasHint/$hasKi/$hasAudit`) IMMER vor Nutzung initialisieren (`$false`), damit StrictMode nie “not set” wirft.

**Beispiel-Outcome:**
- Index (show) → NO_* nur wenn echte Pflichtteile fehlen.
- Abo-Manager (hide) → PASS, solange keine strikten Leak-Marker vorhanden sind.

<!-- SSOT_FLOW_AUDIT_GATE_V1 -->
### Flow/Link-Graph: SSOT + Gate (110% wasserdicht) [2026-02-23]

**Ziel:** Jede Seite hat eine definierte Rolle, ein Ziel und eine kontrollierte Link-Führung. Alle Links werden automatisiert geprüft: keine Sackgassen, keine unerwünschten Loops, sinnvolle nächste Schritte.

#### 1) FLOWMAP als Single Source of Truth
Neue SSOT-Datei: `FLOWMAP_INTERNAL.md` (optional später YAML/JSON). Pro Seite festhalten:
- `url` (live), `source` (md), `role` (entry | pillar | step | hub | legal)
- `goal` (1 Satz)
- `primary_next` (genau 1 Flow-Link; `none` nur bei hub/legal/definierten Endpunkten)
- `weiter_links` (genau 3; orientierend, aber sinnvoll)
- `allowed_related` (z.B. Rechner/Downloads)
- `exceptions` (explizit dokumentiert; Default: keine)

#### 2) Harte Regeln (Trennung Navigation vs Flow)
- **Flow-Link** (`primary_next`): muss **acyclic** sein (keine Zyklen), keine Sackgassen (außer definierte Endpunkte).
- **Weiter-Block**: bleibt 3 Links, aber:
  - **2er-Ping-Pong** (A ↔ B) ist **FAIL**, außer SSOT-Ausnahme.
  - Leaks/Loops nur, wenn sie gegen SSOT verstoßen.
- **Body-Links**: sparsam, zielgerichtet, keine Linkflut.
- **Global Nav/Footer**: nicht als Flow werten.

#### 3) Neues Tool/Gate: `tools/ego-flow-audit.ps1`
Repo-weiter Scan:
- extrahiert Links, normalisiert (site.baseurl, absolute URLs -> Pfade)
- klassifiziert Kanten: `next` (primary_next), `weiter`, `body`, `nav`
- Checks:
  - broken targets (Ziel existiert nicht im Inventory)
  - orphan pages (niemand verlinkt hin, außer definierte Rollen)
  - dead ends (keine ausgehenden Links, außer legal/hub/end)
  - **2-cycles in Weiter** (FAIL)
  - **cycles in next-graph** (FAIL)
  - mismatch (role -> unpassende Ziele / Next widerspricht Flowmap)
- Output: `_local/flow/flow_report.md` + Edge-TSV.

#### 4) CI/Klaus Integration
- `ego-run` bekommt FLOW_GATE (blockiert Apply/Push bei FAIL).
- Report muss reproduzierbar sein (SSOT-first; keine manuellen Ausnahmen ohne SSOT-Eintrag).

#### 5) Wiederkehrende Robustheitsregeln (Tooling)
- Arrays: `@()` vor `.Count` (0/1/n).
- Keine Monster-Regex; deterministic parsing (line-based / Klammerzählung).
- SSOT-Textblöcke: nur `@' ... '@` (keine Interpolation).
- Keine `\"`-Escapes in Strings; Single Quotes oder `-f` Format.
- StrictMode-Safety: temporäre Flags vor Nutzung initialisieren (`$false`).

<!--SSOT_FLOW_AUDIT_GUARDS_V1_BEGIN-->
## Guards: pwsh StrictMode, Replace, RepoRoot, Collections, Backups, Prompt-Safety, Join-Path (V1)

**Warum:** Reale Fehler unter StrictMode / Collections / Copy-Paste / Path-Handling, ausgelöst durch:
- Start per `pwsh -File` außerhalb Repo → `git rev-parse` kann `$null` liefern.
- Replace in double-quoted Strings → PowerShell expandiert `$Var` *vor* dem Replace (StrictMode knallt).
- `$enc` wird benutzt, bevor es gesetzt ist.
- Stack/Graph-DFS: `.RemoveAt()` auf Array (`@()`) → **Collection was of a fixed size.**
- Copy/Paste: PS Continuation Prompt `>>` wurde mitkopiert → Parser/Chaos.
- `Join-Path` bekam `object[]` als AdditionalChildPath → **Cannot convert System.Object[] to System.String**.

### 1) RepoRoot immer resilient (git optional)
**Verboten:**
- `(git rev-parse --show-toplevel 2>$null).Trim()` ohne Null-Guard

**Pflicht:**
- RepoRoot-Resolver mit Fallback über `$PSScriptRoot`:
  - Erst `git rev-parse --show-toplevel` (wenn vorhanden, `.Trim()` nur wenn nicht `$null`)
  - Sonst: `(Resolve-Path (Join-Path $PSScriptRoot '..')).Path`

### 2) StrictMode + `-replace` / Regex-Patches (keine `$Var`-Expansion)
**Pflicht:**
- Replace-Pattern & Replacement **immer single-quoted** ODER `<!-- SSOT HEADER (autogen by ssot-refresh.ps1) -->
Datum: 2026-02-23
Rolle: ROADMAP
Archiv: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\_ARCHIVE\20260223_152727\ROADMAP_INTERNAL.md
Archiv-SHA256: 2c2f7c62a2f21d3e7162089fc3eb47220cba8608b3bf96aebe2c9aeb21c2b6ce

Gesetz: Diese Datei ist Teil der SSOT. Nach jeder Aenderung muss ssot-refresh.ps1 laufen.
Siehe: SSOT_SYSTEM_MAP_INTERNAL.md

---

<!-- EGO_PWSH_ONLY_V1:START -->
## PWSh-only Gesetz (verbindlich)

- **Es wird projektweit ausschließlich PowerShell 7+ verwendet:** pwsh (Standard: pwsh -NoProfile).
- **Keine Beispiele/Anweisungen mehr mit** powershell.exe / Windows PowerShell 5.1.
- Alle Runner/Gates/Tools/Anleitungen sind **pwsh-first** und enthalten Session-Gates.
- Wenn ausnahmsweise historische PS5.1-Fallen dokumentiert sind, dann **nur als „historisch“** (kein Nutzer-Workflow).

<!-- EGO_PWSH_ONLY_V1:END -->
# ROADMAP_INTERNAL.md

## Nächste Meilensteine:
- **MVP02 Content-Rollout**: Implementierung von Themen-Seiten und Rechnern.
- **Automatisierung optimieren**: Weitere Automatisierungen und Integration von Tools zur Qualitätssicherung.
- **Phase 2 - Content-Ausbau**:
  - Themen-Seiten-Cluster (Top 5 zuerst)
  - Rechner (statische JS Mini-Rechner) nach Priorität
- **Phase 3 - Distribution**:
  - SEO Interlinking, saubere Hubs, keine Sackgassen
  - Analytics Events optional (privacy-friendly), erst nach Content-Basis

<!-- KLAUS_CONVERSION_FIRST_V1 -->
# Conversion-First Architektur (V1)

## Zielbild
EGO ist kein Wiki. EGO ist ein Conversion-System (Self-Serve, ohne Support).

## Rendite-Kette (verbindlich)
Verstehen -> Tun (Rechner/Schnellstart) -> Mitnehmen (Download) -> Upgrade (Voll/Premium)

## Startseiten-Gesetz (Top-3)
Above-the-fold nur 3 Primaeraktionen:
1) Schnellstart (15 Minuten)
2) Schuldenfrei
3) Fixkosten senken

Alles andere ist sekundaer und wird nach unten/auf Hubs verschoben.

## Navigations-SSOT-Gesetz
Ein Ziel (URL) hat genau einen offiziellen Namen.
Ein Name darf nur genau ein Ziel haben.
Keine Synonyme in Navigation/Weiter/Startseiten-Listen.

## Weiter-Block-Gesetz (3 feste Bedeutungen)
Jede Content-Seite hat unter "## Weiter" exakt 3 Links:
1) Zum Rechner: <Name>
2) Zum Download: <Name>
3) Weiter im Thema: <Name>

Keine generischen Linktexte wie "Naechster Schritt".

## Dopplungs-Verbot (Startseite / Header / Listen)
- Gleiche URL mit unterschiedlichen Labels: verboten.
- Gleicher Labeltext mit unterschiedlichen URLs: verboten.
- "Seiten-Uebersicht" darf nicht auf Schnellstart zeigen.

## Umsetzungsvorgabe
Aenderungen sind repo-weit konsistent auszurollen:
GOVERNANCE -> QA_GATE -> LEARNINGS -> ROADMAP -> dann Content/Navigation.

## Roadmap-Update (V1, Reihenfolge)
1) Blocker: Frontmatter sichtbar -> repo-weit fixen
2) Startseite: Top-3 + sekundaer Bereiche, Dopplungen raus
3) NAV-SSOT: URL->Name festlegen (Kernziele)
4) Weiter-Bloecke: 3 feste Bedeutungen + deskriptive Texte
5) Header/Nav: minimal, SSOT-konform
6) Thema-Seiten: Funnel-Layout (Problem->Rechner->Download->Upgrade)

<!-- INBOX_2026-02-19_SITEMAP_SEARCHCONSOLE_V1 -->
## Inbox 2026-02-19: Roadmap-Update (Indexierung)
- (A) Google Search Console: Property bestaetigen, Sitemap (sitemap.xml) eingereicht lassen, spaeter URL-Pruefung wiederholen falls Quota-Limit.
- (B) Bing Webmaster Tools: Site hinzufuegen/verifizieren, Sitemap (sitemap.xml) einreichen.
- (C) Nach 24-72h: Indexierungsstatus checken; nur bei echten Fehlermeldungen handeln.
<!-- /INBOX_2026-02-19_SITEMAP_SEARCHCONSOLE_V1 -->

<!-- SSOT_PS_HERESTRING_GUARD_V1 -->
### PowerShell: Here-String Guard (SSOT Pflichtregel) [2026-02-23]

**Problemklasse (wiederkehrend):** SSOT-/Report-Text enthält Beispiele wie `$items`, `$tsvFiles`, etc.  
Wenn ein Textblock versehentlich als **expandierender** Here-String (`@" ... "@`) gebaut wird, versucht PowerShell Variablen zu expandieren → Abbruch: *"The variable '$items' cannot be retrieved because it has not been set."*

**SSOT-Regel (hart):**
- Für alle SSOT-Textblöcke/Markdown-Blöcke in Tools/Runnern/Apply-Scripts gilt:
  - **Nur** `@' ... '@` verwenden (single-quoted here-string).
  - **Nie** `@" ... "@` verwenden, wenn der Inhalt `$...` oder Backticks enthält.
- Wenn dynamische Teile nötig sind (Datum/Version): **nachträglich ersetzen**, z.B. `.Replace('2026-02-23', $stamp)`.

**Beispiel (korrekt):**
- `$txt = @'
  Beispiel: `$items = @(Get-ChildItem ...)`
  '@`

**Beispiel (verboten):**
- `$txt = @"
  Beispiel: `$items = @(Get-ChildItem ...)`
  "@`

<!-- SSOT_TSV_HEADERLESS_GUARD_V1 -->
### TSV: Headerless-Guard (Inventory/Queues) [2026-02-23]

**Problemklasse (wiederkehrend):** TSV-Datei ohne Header (erste Zeile ist direkt `1<TAB>https://...`)  
Wenn ein Tool das per `Import-Csv` lädt, wird die erste Zeile als Header interpretiert → **IDX 1 fehlt** → Fehler wie `STOP: idx not found: 1`.

**SSOT-Regel (hart):**
- Wenn TSV **headerless** sein kann, darf es **nicht** blind per `Import-Csv` geladen werden.
- Loader MUSS robust sein:
  - Erkennung: erste Zeile matcht `^\s*\d+\t` ⇒ **headerless** ⇒ manuell splitten: `IDX, URL, PERMALINK, SOURCE`
  - sonst: **Header-TSV** ⇒ `Import-Csv -Delimiter "`t"`
- Optional (empfohlen): Inventory-TSV mit Header pflegen: `IDX<TAB>URL<TAB>PERMALINK<TAB>SOURCE`

**Fix-Pattern (PowerShell):**
- `if($lines[0] -match '^\s*\d+\t'){ ...split "`t",4... } else { Import-Csv -Delimiter "`t" }`

<!-- SSOT_PS_NO_MONSTER_REGEX_V1 -->
### PowerShell: No “Monster-Regex” (RegexTimeout-Guard) [2026-02-23]

**Problemklasse (wiederkehrend):** Große `(?s)...*?`-Regex über ganze Dateien kann in PowerShell an `RegexMatchTimeoutException` scheitern oder sehr langsam werden (z.B. Patchen von `param(...)` mit `.*?`).

**SSOT-Regel (hart):**
- Keine “Monster-Regex” über komplette Dateien für strukturelle Patches (param-block, frontmatter, includes).
- Stattdessen deterministische Strategien verwenden:
  1) **Klammerzählung** (z.B. `param(...)` Ende finden),
  2) **Line-based** Patches (gezielte Zeilen ersetzen),
  3) **AST/Parser** (wenn sinnvoll),
  4) **kleine Regex** nur für *lokale* Matches (kurze Zeilen/Abschnitte).

**Patch-Standard:**
- Wenn Struktur bekannt ist (z.B. `param(` … `)`): per Index + Depth-Count.
- Wenn Erkennung nötig ist: erst **SCAN** mit line-based “grep” (z.B. `Select-String`) → dann exakt patchen.

**Optional (nur wenn unvermeidbar):**
- Regex-MatchTimeout explizit setzen und Pattern verkleinern (aber Standard bleibt: vermeiden).

<!-- SSOT_PS_QUOTE_ESCAPING_GUARD_V1 -->
### PowerShell: Quote-/Escaping-Guard (ParserError Prävention) [2026-02-23]

**Problemklasse (wiederkehrend):** ParserErrors durch ungünstige Escapes in Strings, v.a. `\"` in doppelten Anführungszeichen oder gemischtes Escaping in `throw`-Meldungen.

**SSOT-Regel (hart):**
- In PowerShell **keine** `\"`-Sequenzen in normalen String-Literalen verwenden.
- Für Text/Fehlermeldungen/Marker:
  - bevorzugt **Single Quotes**: `'...'` (keine Interpolation, kein Escaping nötig)
  - oder `("... {0} ..." -f $var)` / `("{0}" -f ...)` für sichere Formatierung
- In SSOT-Textblöcken weiterhin: **nur** `@' ... '@` (keine Interpolation).
- Wenn ein String tatsächlich `"` enthalten muss: entweder Single Quotes außen verwenden oder `""` innerhalb eines double-quoted Strings (PowerShell-Standard), aber **kein** Backslash-Escaping.

**Beispiele (korrekt):**
- `throw 'STOP: srcFile init line $srcFile = "" not found'`
- `throw ("STOP: missing file: {0}" -f $p)`

**Beispiele (verboten):**
- `throw "STOP: $srcFile=\"\" not found"`  (führt regelmäßig zu ParserError)

<!-- SSOT_RUNNER_POLICYBLOCKS_GATING_V1 -->
### Runner-Regel: policy_blocks Gating + Leak-Check (Rendered) [2026-02-23]

**Ziel:** Runner muss Live-Wahrheit abbilden, ohne False-Positives.

**Gating-Regel:**
- `policy_blocks: show` (Frontmatter):
  - Pflicht: Hinweis(wichtig) + Aktualität/Audit + KI-Hinweis müssen gerendert sein.
  - Checks dürfen **robust** sein (Textvarianten tolerieren).
- Default / hide:
  - Die Policy-Blöcke dürfen **nicht** gerendert sein.
  - Leak-Checks müssen **strikt** sein (nur block-spezifische Marker), sonst False-Positives.

**Empfohlene Marker:**
- Require (robust):
  - Hinweis: `(Hinweis|Wichtig)`
  - Audit/Aktualität: `Aktualit(aet|[aä]t)\s+und\s+Audit`
  - KI: `\bKI\b|Künstliche Intelligenz|Kuenstliche Intelligenz`
- Leak (strikt):
  - Hinweis: `Hinweis\s*\(wichtig\)`
  - Audit: `Aktualit(aet|[aä]t)\s+und\s+Audit[-– ]Hinweis`
  - KI: `KI[- ]Hinweis`

**StrictMode-Safety (Pflicht):**
- Temporäre Flags (z.B. `$hasHint/$hasKi/$hasAudit`) IMMER vor Nutzung initialisieren (`$false`), damit StrictMode nie “not set” wirft.

**Beispiel-Outcome:**
- Index (show) → NO_* nur wenn echte Pflichtteile fehlen.
- Abo-Manager (hide) → PASS, solange keine strikten Leak-Marker vorhanden sind.

<!-- SSOT_FLOW_AUDIT_GATE_V1 -->
### Flow/Link-Graph: SSOT + Gate (110% wasserdicht) [2026-02-23]

**Ziel:** Jede Seite hat eine definierte Rolle, ein Ziel und eine kontrollierte Link-Führung. Alle Links werden automatisiert geprüft: keine Sackgassen, keine unerwünschten Loops, sinnvolle nächste Schritte.

#### 1) FLOWMAP als Single Source of Truth
Neue SSOT-Datei: `FLOWMAP_INTERNAL.md` (optional später YAML/JSON). Pro Seite festhalten:
- `url` (live), `source` (md), `role` (entry | pillar | step | hub | legal)
- `goal` (1 Satz)
- `primary_next` (genau 1 Flow-Link; `none` nur bei hub/legal/definierten Endpunkten)
- `weiter_links` (genau 3; orientierend, aber sinnvoll)
- `allowed_related` (z.B. Rechner/Downloads)
- `exceptions` (explizit dokumentiert; Default: keine)

#### 2) Harte Regeln (Trennung Navigation vs Flow)
- **Flow-Link** (`primary_next`): muss **acyclic** sein (keine Zyklen), keine Sackgassen (außer definierte Endpunkte).
- **Weiter-Block**: bleibt 3 Links, aber:
  - **2er-Ping-Pong** (A ↔ B) ist **FAIL**, außer SSOT-Ausnahme.
  - Leaks/Loops nur, wenn sie gegen SSOT verstoßen.
- **Body-Links**: sparsam, zielgerichtet, keine Linkflut.
- **Global Nav/Footer**: nicht als Flow werten.

#### 3) Neues Tool/Gate: `tools/ego-flow-audit.ps1`
Repo-weiter Scan:
- extrahiert Links, normalisiert (site.baseurl, absolute URLs -> Pfade)
- klassifiziert Kanten: `next` (primary_next), `weiter`, `body`, `nav`
- Checks:
  - broken targets (Ziel existiert nicht im Inventory)
  - orphan pages (niemand verlinkt hin, außer definierte Rollen)
  - dead ends (keine ausgehenden Links, außer legal/hub/end)
  - **2-cycles in Weiter** (FAIL)
  - **cycles in next-graph** (FAIL)
  - mismatch (role -> unpassende Ziele / Next widerspricht Flowmap)
- Output: `_local/flow/flow_report.md` + Edge-TSV.

#### 4) CI/Klaus Integration
- `ego-run` bekommt FLOW_GATE (blockiert Apply/Push bei FAIL).
- Report muss reproduzierbar sein (SSOT-first; keine manuellen Ausnahmen ohne SSOT-Eintrag).

#### 5) Wiederkehrende Robustheitsregeln (Tooling)
- Arrays: `@()` vor `.Count` (0/1/n).
- Keine Monster-Regex; deterministic parsing (line-based / Klammerzählung).
- SSOT-Textblöcke: nur `@' ... '@` (keine Interpolation).
- Keine `\"`-Escapes in Strings; Single Quotes oder `-f` Format.
- StrictMode-Safety: temporäre Flags vor Nutzung initialisieren (`$false`).

 escapen.
- Keine double-quoted Strings, die `$RepoRoot`, `$enc`, `$s` usw. enthalten, wenn StrictMode aktiv ist.

Beispiel (safe):
- `$pattern = '(?m)^...$RepoRoot...'`
- `[regex]::Replace($text, $pattern, '...')`

### 3) `$enc` muss garantiert vor Nutzung gesetzt sein
**Pflicht:**
- Direkt nach `Set-StrictMode -Version Latest`:
  - `$enc=[Text.UTF8Encoding]::new($false)`

### 4) Collections-Guard (Stacks/Queues/DFS): nie `.RemoveAt()` auf `@()`
**Fakt:**
- `@()` ist ein Array → fixed-size → `.RemoveAt()` geht nicht.

**Pflicht:**
- Für mutable Stacks/Queues immer:
  - `[System.Collections.Generic.List[string]]::new()` + `.Add()` / `.RemoveAt()`
  - oder `[System.Collections.ArrayList]::new()`

### 5) Prompt-Safety: `>>` niemals copy/paste
**Pflicht:**
- Nur Code kopieren (ohne `PS C:\...>` und ohne `>>`).
- Wenn Chaos passiert: PSReadLine entfernen + frische `pwsh -NoProfile -Command { ... }` Session.

### 6) Join-Path Guard: niemals Arrays in AdditionalChildPath
**Fakt:**
- `Join-Path $repo 'a','b'` kann als `object[]` in `AdditionalChildPath` landen → Fehler.

**Pflicht:**
- Pfade einzeln bauen:
  - `$p1 = Join-Path $repo 'a'`
  - `$p2 = Join-Path $repo 'b'`
- Oder loop:
  - `foreach($x in @('a','b')){ $p = Join-Path $repo $x }`

### 7) Backup-Policy (immer)
**Pflicht:**
- Vor jedem Patch **Backup** in `_patch_backups\...` (SSOT) oder `_local\patch_backups\...` (Repo).
- Jede APPLY-Änderung muss `BACKUP:` Pfad ausgeben.
<!--SSOT_FLOW_AUDIT_GUARDS_V1_END-->

**PS_IF_EXPRESSION_GUARD_V1**

* PowerShell: `if (...) {}` ist ein **Statement**, keine Expression.
  * In String-Concats niemals `'...' + (if(...){...} else {...})`.
  * Stattdessen: **vorher Variable setzen** oder `$((if(...){...} else {...}))`.
* Verify-Snippets müssen **self-contained** sein:
  * jede Variable (z.B. `$flowmap`) muss im Snippet definiert sein, sonst droht `Test-Path: Value cannot be null`.

**APPLY_TEMPLATE_POLICY_V1**

* Jede „APPLY“-Antwort (Patch/Writer/Generator) muss **deterministisch** sein und mindestens enthalten:
  * **Backup-Policy**: vor Änderungen Backup in `_patch_backups\...` (SSOT) bzw. `_local\patch_backups\...` (Repo).
  * **Idempotenz**: Re-run darf keine doppelten Blöcke erzeugen (Marker/Needle + Guard).
  * **Explizite Outputs**: `APPLY_OK`, `BACKUP_DIR`, `PATCHED/WROTE`, optional `CHANGED_ANY`.
  * **SSOT Refresh**: wenn SSOT-Dokus betroffen sind, **danach** `ssot-refresh-proxy.ps1` laufen lassen.
  * **VERIFY**: danach immer einen kurzen Verify-Command liefern (Select-String/Head/Gate).
* „Unten ist ein APPLY …“ ist kein Fließtext, sondern **Policy**: APPLY muss genau diese Eigenschaften erfüllen.
**PS_STRING_PARSER_DESYNC_GUARD_V1**

* Wenn PowerShell `ParserError: Unexpected token ...` meldet, ist fast immer der Code **vorher** syntaktisch zerlegt (Quote/Klammer offen).
* In so einem Fall: **nicht weiter mit Regex patchen**, sondern Script **deterministisch neu schreiben** (Writer), mit Backup.
* Besonders riskant: `-replace` mit Backslash/Quotes in Replacement → bevorzugt `DirectorySeparatorChar` oder vorab Variable.
**FLOWMAP_DRAFT_SCHEMA_GUARD_V2**

* `FLOWMAP_DRAFT.tsv` darf Header enthalten (z.B. `idx<TAB>url<TAB>role<TAB>intended_next<TAB>notes`).
* Gate muss Header-Zeile **skippen** (sonst `MISSING_PAGE_FILE: idx`).
* Draft kann **URL statt rel_path** enthalten → Gate muss `url` auf `rel_path` mappen:
  * BaseUrl entfernen, Query/Fragment droppen.
  * `/` → `index.md`
  * `*.html` → `*.md`
* Doku und Gate dürfen sich nicht widersprechen (wenn Doku „headerless“ sagt, muss Draft auch headerless sein – oder Gate unterstützt beide).
**ATOMIC_WRITE_GUARD_V1**

* Writer/Rewriter dürfen nie „halb“ schreiben. Policy:
  * Immer **atomisch**: erst `file.tmp` schreiben, dann `Move-Item -Force` auf Ziel.
  * Kein `Ctrl+C` während Writer läuft (sonst ParserError/Unexpected token).
  * Wenn ein Rewrite abgebrochen wurde: Zielscript **neu schreiben** (nicht weiter patchen).

**PS_COUNT_GUARD_V1**

* StrictMode: Pipeline-Ergebnisse sind nicht garantiert Arrays (kann `string` oder `$null` sein).
* Niemals `.Count` auf ein evtl. skalares Ergebnis.
* Regel: Vor `.Count` immer normalisieren:
  * `$hits = @( ...pipeline... )`
  * dann ist `$hits.Count` deterministisch.
* Alternative: `@($x).Count` oder `($x | Measure-Object).Count` (langsamer).

**PS_REGEX_REPLACE_GUARD_V1**

* **Nie** `Regex::Escape()` auf **Replacement** anwenden.
  * Das erzeugt „escaped Müll“ im Zieltext (z.B. `\{\{\ site\.baseurl\ }}` / `haushaltsbuch\.html`).
* Regel:
  * **Pattern** escapen: `[Regex]::Escape($patternLiteral)` oder bewusstes Regex-Pattern.
  * **Replacement** als **Literal** verwenden (keine Escape-Transformation).
* Sichere Beispiele:
  * `-replace [Regex]::Escape($from), $to`  (from wird escaped, to bleibt literal)
  * `[Regex]::Replace($text, [Regex]::Escape($from), [MatchEvaluator]{ param($m) $to }, 1)`
* Wenn du „ganze Zeile ersetzen“ willst: besser Zeilenregex matchen und **Hard-Set** schreiben statt fragile Sub-Replaces.

**DOCS_UPDATE_ON_BUGFIX_POLICY_V1**

* Wenn ein Bug „klassischer PS-Fall“ ist (ParserError / RegexReplace / StrictMode Count etc.):
  * **immer** im selben Batch die passende Guard-Regel in SSOT-Doks ergänzen (Backup + ssot-refresh-proxy).

### PS_REGEX_SPLIT_OVERLOAD_GUARD_V1

**Problem:** `[regex]::Split()` hat in PowerShell/.NET **keinen** Overload mit *limit=-1*.  
Wenn man `-1` als drittes Argument übergibt, wird es als `RegexOptions` interpretiert → Exception.

**Fix (TSV robust):**
- Verwende: `[System.Text.RegularExpressions.Regex]::Split($line,"`t")`
- Das erhält in der Praxis auch **trailing empty Columns** (wichtig bei TSV mit leeren Feldern am Ende).

**Anti-Pattern (nicht verwenden):**
- `[regex]::Split($line,"`t",-1)`

### PS_HERESTRING_INTERPOLATION_GUARD_V1

**Problem:** Double-quoted Here-Strings `@" ... "@` interpolieren Variablen wie `$line`.  
Unter `Set-StrictMode -Version Latest` führt ein nicht gesetztes `$line` in Doku-Blöcken sofort zu Exceptions.

**Fix (Doku-Blöcke immer safe):**
- Für Dokumentations-Text immer **single-quoted** Here-Strings nutzen: `@' ... '@`
- Alternativ: `$` im Text explizit escapen (z.B. `` `$line ``), aber Standard ist: **single-quoted**.

**Anti-Pattern (nicht verwenden in Patch-Skripten):**
- `$block=@" ... $line ... "@`

### SMOKE_TEST_FINDING_V1

**Titel:** Smoke-Test: Auto-Finding Tool

**Tags:** 'smoke','automation'

**Problem:** Testeintrag zur Verifikation des ssot-finding-add.ps1 Tools.

**Fix:** Wenn dieser Eintrag in allen 5 SSOT-Doks auftaucht, ist die Pipeline ok.

**Anti-Pattern:**
- Kein Anti-Pattern (Test)


### SMOKE_TEST_FINDING_V2

**Titel:** Smoke-Test: Tags Binding Fix

**Tags:** smoke

**Problem:** Verifiziert, dass -Tags smoke automation als RemainingArguments gebunden wird.

**Fix:** Wenn PATCHED_FILES erscheint, ist das Binding-Fix aktiv.

**Anti-Pattern:**
- automation


### PS_TAGS_BINDING_SCRIPT_PARAM_GUARD_V1

**Titel:** Script-Param-Binding: -Tags braucht CSV/Quoted-String

**Tags:** powershell, binding, ssot, automation

**Problem:** Bei Scriptfiles scheitert -Tags powershell binding ...: nur 1. Wert wird gebunden, Rest wird positional → Error. Zusätzlich dürfen Normalize-Blöcke kein param() in Scriptblocks enthalten.

**Fix:** Tool nimmt Tags als EIN String: -Tags "a,b,c" oder -Tags "a b c". Normalisierung via -split + Trim (ohne param() Scriptblocks).

**Anti-Pattern:**
- -Tags powershell binding ssot automation (unquoted) und/oder ForEach-Object { param(...) } im Normalize-Block.


### PS_GOLDEN_RESET_OVER_REGEX_PATCH_GUARD_V1

**Titel:** Wenn Tool kaputt gepatcht ist: Golden-Reset statt weiterer Regex-Patches

**Tags:** powershell, tooling, governance, ssot

**Problem:** Regex-Patches auf bereits fragilen Tool-Text stapeln sich und lassen kaputte Fragmente stehen (z.B. param() in Pipeline-Scriptblock blieb trotz PATCHED=True). Dadurch entstehen Parser/Binding-Kollisionen und Folgefehler.

**Fix:** Bei Tooling-Drift/Parserfehlern: das Skript deterministisch auf eine geprüfte Golden-Version überschreiben (Backup + Atomic Write). Erst danach weitere kleine Verbesserungen.

**Anti-Pattern:**
- Mehrere Regex-Edits auf ein bereits inkonsistentes Tool anwenden, statt einmal sauber zu resetten.


### PS_TAGS_NORMALIZE_NO_PARAM_SCRIPTBLOCK_GUARD_V1

**Titel:** Keine param()-Blöcke in Pipeline-Scriptblocks (Normalize/ForEach-Object)

**Tags:** powershell, parser, binding, guard

**Problem:** ForEach-Object { param(...) } kann in Scriptfiles Parser/Binding-Kollisionen auslösen ("attribute cannot be added ... Id").

**Fix:** Normalize minimal halten: Split/Trim/Filter ohne param() innerhalb von Scriptblocks.

**Anti-Pattern:**
- ForEach-Object { param($x) ... } in Tool-Normalize


### PS_CONTINUATION_PROMPT_COPY_GUARD_V1

**Titel:** PS-Continuation-Prompt (>>) niemals mitkopieren

**Tags:** powershell, workflow, guard

**Problem:** Wenn >>-Prompts in Commands landen, entstehen kaputte Blöcke/Parsing-Fehler und schwer reproduzierbares Verhalten.

**Fix:** Immer nur den reinen pwsh-Block kopieren (ohne PS C:\...> und ohne >>). Bei Chaos: Ctrl+C, Remove-Module PSReadLine, neu.

**Anti-Pattern:**
- Copy/Paste inkl. >> Zeilen


### PS_IF_EXPRESSION_GUARD_V1

**Titel:** if ist Statement: nicht als Expression in String/Concat verwenden

**Tags:** powershell, syntax, guard

**Problem:** if ist kein Expression-Value; in Concats/Interpolationen führt das zu ParserErrors/Logikfehlern.

**Fix:** Wert vorher in Variable setzen oder $() nur für echte Expressions nutzen.

**Anti-Pattern:**
- "x=" + (if($cond){...}else{...})


### PS_RESTORE_THEN_AST_PATCH_SOP_V1

**Titel:** Bei ParserError nach Patch: sofort Restore, dann AST-sicher neu patchen

**Tags:** powershell, sop, governance, guard

**Problem:** Wenn ein Patch ParserError erzeugt, ist weiteres “Rumprobieren” riskant. Es muss zuerst der lauffähige Zustand wiederhergestellt werden.

**Fix:** SOP: 1) Restore aus Backup. 2) Verify (Script läuft). 3) Patch neu als AST-Insert mit Pre/Post-Parse-Check. 4) Verify. 5) SSOT Finding dokumentieren.

**Anti-Pattern:**
- Weiterpatchen auf einem bereits syntaktisch kaputten Script.


### PS_PARAMBLOCK_REGEX_INSERT_PARSERERROR_GUARD_V1

**Titel:** Nie per Regex in/nahe param() injizieren: AST-Insert + Parse-Check erzwingen

**Tags:** powershell, ast, parser, guard, ssot

**Problem:** Regex-Inserts können in den param-Header rutschen und die schließende Klammer zerstören. Folge: ParserError "Missing closing )". Restore wird nötig. Beispiel: flow-quality-gate.ps1 nach Trap-Injection.

**Fix:** Patch AST-sicher: Parser.ParseInput, Insert-Position über $ast.ParamBlock.Extent.EndOffset, danach Pre+Post Parse-Check. Erst dann Atomic Write. Immer Backup+Restore-Plan.

**Anti-Pattern:**
- Regex-Replace/Insert anhand von Zeilenmustern rund um param() ohne AST-Check.


### PS_SINGLE_QUOTE_ESCAPE_GUARD_V1

**Titel:** PowerShell Strings: Backslash ist kein Escape für Anführungszeichen

**Tags:** powershell, parser, quoting, guard

**Problem:** In single-quoted Strings escapt \ nichts. Sequenzen wie \' erzeugen keine gültigen Escapes und können Parserfehler triggern (z.B. Unexpected token )).

**Fix:** In single-quoted Strings: Apostroph immer als ' schreiben. Keine Backslash-Pseudoescapes verwenden. Alternativ Here-Strings nutzen.

**Anti-Pattern:**
- Text mit \' oder \") in PowerShell-Strings erwarten.


### AUTO_EGO_RUN_EXCEPTION_2c5f2f66ee38

**Titel:** ego-run: Exception Auto-Finding

**Tags:** powershell, auto, finding, ego-run

**Problem:** Type: System.Management.Automation.RuntimeException
Message: RELEASE_GATE_0 FAIL - see report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\reports\RELEASE_GATE_0_2026-02-23_17-18-57.txt

**Fix:** Fehler beheben; wenn wiederkehrend: Guard/Policy ergänzen. Dieser Eintrag wurde automatisch erzeugt.

**Anti-Pattern:**
- Exception ignorieren oder nur lokal fixen ohne SSOT-Update.


### PS_TOOL_INVENTORY_MISSING_SCRIPT_GUARD_V1

**Titel:** Auto-Rollout: vor Patch/Hook immer Tool-Inventory prüfen (Datei kann fehlen)

**Tags:** powershell, tooling, inventory, guard, ssot

**Problem:** Rollout/Hook-Install scheitert, wenn erwartete Scripts nicht existieren (z.B. klaus-run.ps1 fehlt im Pfad) → STOP: missing ...

**Fix:** Vor jedem Rollout: Test-Path über die Ziel-Skripte, Inventory ausgeben, dann nur vorhandene patchen. Fehlende Tools als eigenes Finding dokumentieren.

**Anti-Pattern:**
- Blind patchen ohne Test-Path/Inventory (führt zu STOP: missing).


### FLOW_GATE_AST_TRAP_LIVE_STATUS_V1

**Titel:** flow-quality-gate: AST-TRAP live, Gate läuft, Warns bleiben separater Track

**Tags:** flow-quality-gate, ast, automation, warns, ssot

**Problem:** Regex-Injection kaputt → Restore + AST Patch war nötig. Jetzt läuft Gate stabil (ERRORS=0), aber WARNS=80 sind Content/Flow-Work und sollen nicht mit Tooling vermischt werden.

**Fix:** Status festhalten: AST-TRAP aktiv, Gate stabil. WARNS (NO_INTENDED_NEXT, ROLE_NEXT_SUSPECT) als eigener "Soft Findings/Content Flow" Track behandeln (Threshold/Hash/Noise-Filter).

**Anti-Pattern:**
- Tooling-Fix und Content-Warn-Flut vermischen; kein Noise-Filter bei Soft-Findings.


### PS_DOLLAR_VAR_COLON_STRING_GUARD_V1

**Titel:** PowerShell Strings: $var: ist gefährlich (Drive-Scope), immer ${var} nutzen

**Tags:** powershell, quoting, parser, guard

**Problem:** In double-quoted Strings wird $name: als Drive-Scope interpretiert. Beispiel: "$baseName: ..." führt zu "Variable reference is not valid".

**Fix:** Wenn direkt nach einer Variablen ein Doppelpunkt kommt: immer ${baseName}: verwenden oder per Concat bauen.

**Anti-Pattern:**
- "$baseName: Text"

<!--EGO_FINDING_PRELUDE_INJECTION-->
## Finding: Inline-Prelude-Injection kann Param-Blöcke kaputtmachen (Wrapper-only Regel)

### Kontext
Wir haben versucht, bei Runner-Skripten das SSOT-Prelude technisch zu erzwingen, indem wir **nach param(...)** einen Inject-Block einfügen (# BEGIN_EGO_PRELUDE_ENFORCE ...).

### Befund (kritisch)
Bei komplexen Param-Blöcken (mehrzeilige Attribute/ValidateSet/Typ-Literale) kann eine naive Regex das param(...) **zu früh** abschneiden.  
Dann landet die Injection **mitten im Param-Block** → **Syntaxfehler** (Parse Errors) und das Script ist unbrauchbar.

### Konkreter Vorfall
- go-run.ps1 wurde nach Inline-Injection **syntaktisch kaputt** (Parser-Fehler).
- Restore aus Backup war nötig (PARSE_ERRORS: 0 nach Restore).

### Konsequenz (harte Regel)
- **Inline-Enforcement ist nur für "einfache" Scripts erlaubt** (z.B. low-quality-gate.ps1), bei denen param(...) sicher und eindeutig ist.
- **Komplexe Runner dürfen niemals inline gepatcht werden.**  
  Stattdessen: **Wrapper-only**.
  - Beispiel: go-runx.ps1 (Wrapper ruft zuerst go-run-prelude.ps1, dann go-run.ps1 mit Args).
- Zusätzlich: Enforcer-Denylist muss go-run.ps1 enthalten (nie wieder Inline-Injection).

### Ziel
SSOT-Refresh bleibt technisch zwingend, **ohne** Risiko, Runner-Skripte zu zerstören.
<!--EGO_FINDING_PRELUDE_INJECTION-->

<!-- EGO_FLOW_NO_INTENDED_NEXT_PLAN_V2_20260223 -->
## Flow-Quality: Batch 2 (NO_INTENDED_NEXT) – PLAN v2 Policy (2026-02-23)

**Fakten (letzter Run):**
- NO_INTENDED_NEXT = 71
- Top Reasons (Auszug): fallback -> Überblick (45), rechner-page -> Rechner-Übersicht (8), Haushaltsbuch -> Fixkosten (6), Fixkosten -> Spielraum/Ruecklagen (5), Notgroschen -> Schulden optional (4), Spielraum/Ruecklagen -> Notgroschen (2), index.md -> Start (1)

**Kritisches Finding (Matcher/Regex):**
- Item in low_warns_v2.csv ist repo-relativ wie seiten/der-weg.md (ohne führendes /).
- Regeln, die auf "/seiten/..." matchen, greifen dann nicht. Das ist konkret passiert:
  - seiten/der-weg.md wurde nicht als "der-weg" erkannt (fiel auf fallback).
  - seiten/download-hub-*.md und seiten/downloads_alias.md wurden nicht als Download-Cluster erkannt (fielen auf fallback).
- **Policy:** Alle Matcher müssen beide Formen akzeptieren: (^|/)seiten/... **und** (^|/)\/seiten/... (Leading Slash optional).

**PLAN-v2 Cluster-Ziele (intended next):**
- Start: /seiten/haushaltsbuch.html
- Überblick/Hub: /seiten/ueberblick.html
- Downloads Hub: /seiten/downloads.html
- Rechner Hub: /seiten/rechner-uebersicht.html
- Der-Weg-Kette: Haushaltsbuch → Fixkosten → Spielraum/Ruecklagen → Notgroschen → Schulden optional (/pillar/schuldenfrei.html)

**Status:**
- Das ist **PLAN** (kein APPLY). APPLY erfolgt batchweise (Backup → Patch → Gates → Report).
<!-- /EGO_FLOW_NO_INTENDED_NEXT_PLAN_V2_20260223 -->

<!-- EGO_SHARED:POWERSHELL_HERESTRING_EXPANSION_STRICTMODE -->
## PowerShell Here-String Expansion: StrictMode-Falle (2026-02-23)


Finding: @"..."@ expandiert $Variablen sofort; unter StrictMode führt das bei unset Vars zu STOP (z.B. $SSOTRoot). Policy: Tool-Templates und Script-Generatoren nur @'...'@ (single-quoted here-string) oder $ konsequent escapen (``$), niemals @"..."@ für Script-Inhalte. Zusätzlich: Defaults/Guards für Pflichtpfade in param(...) oder vor Binding erzwingen.
<!-- /EGO_SHARED:POWERSHELL_HERESTRING_EXPANSION_STRICTMODE -->

<!-- EGO_SHARED:POWERSHELL_CODEGEN_HARD_RAIL -->

### POWERSHELL_CODEGEN_HARD_RAIL

Ziel: Codegen/Copy-Paste-Deja-vu technisch verhindern.

- Kein Generator baut Generator: keine PowerShell-Code-Strings mit eingebetteten Quotes/Backticks als 'Code' generieren.
- Keine Markdown-Fences in PowerShell-Strings (keine ` als String-Literal). Nutze statt dessen BEGIN/END-Separatoren oder Single-Quotes.
- Kein Backslash-Quote (Backslash ist kein Escape in PowerShell).
- Here-Strings: bevorzugt Single-Quoted @' ... '@ (keine Expansion).
- Auto-Variablen nicht überschreiben: \System.Collections.Hashtable nicht als normale Variable verwenden.
- Join-Path arraysafe: keine Trailing-Commas/Object[] in AdditionalChildPath.
- Große Änderungen: file-first (ps1) + Run via pwsh -File; Clipboard nur über KRUN (persist + Report).

#### Zusatz: Backtick-Fences + Gate-Noise

- Markdown-Fences niemals in doppelt-quotierten PowerShell-Strings (auch nicht in Tool-Kommentaren). Nutze single quotes: '```' / '```text'.
- Gates scannen nie eigene Outputs: _reports, _ARCHIVE, _patch_backups, _local, _generated sind ausgeschlossen.
- File-first + Parser-Lint (ParseFile) vor Ausfuehrung ist Pflicht, sonst STOP + Report.
<!-- /EGO_SHARED:POWERSHELL_CODEGEN_HARD_RAIL -->

<!-- EGO_SHARED:POWERSHELL_SINGLE_ITEM_NO_COUNT_ARRAY_CAST -->
## PowerShell: Single-Item Pipeline -> .Count fehlt (Array-Cast Policy)


Finding: Get-ChildItem kann bei 1 Treffer ein einzelnes Objekt liefern; dann existiert .Count nicht → StrictMode/Robustness-Fehler (z.B. "The property Count cannot be found"). Policy: Ergebnisse, die später .Count nutzen, immer als Array erzwingen: $files = @(Get-ChildItem ...). Danach ausschließlich $files.Count prüfen, z.B. if($files.Count -eq 0){...}. Keine Checks mit (!$files -or $files.Count -eq 0) ohne vorherigen Array-Cast.
<!-- /EGO_SHARED:POWERSHELL_SINGLE_ITEM_NO_COUNT_ARRAY_CAST -->

<!-- EGO_SHARED:DEIN_NEUER_BLOCKNAME -->
## Titel...


Text...
<!-- /EGO_SHARED:DEIN_NEUER_BLOCKNAME -->

<!-- EGO_SHARED:PRECOMMIT_HOOK_HERESTRING_NO_EXPANSION -->
## Git pre-commit Hook: Here-String Expansion vermeiden (StrictMode)


Finding: Wenn Hook-Inhalt in PowerShell als expandierender Here-String @"..."@ gebaut wird, werden $-Variablen (z.B. $rc) bereits beim String-Build evaluiert → StrictMode STOP ("variable cannot be retrieved"). Policy: Hook-/Script-Text, der $ enthält (bash/sh), immer als single-quoted here-string @'...'@ oder $ escapen. Für pre-commit Hook gilt: rc=$?; if [ $rc -ne 0 ]; then ... ; fi. Dadurch wird $rc nur im Shell-Kontext ausgewertet, nicht in PowerShell.
<!-- /EGO_SHARED:PRECOMMIT_HOOK_HERESTRING_NO_EXPANSION -->

<!-- EGO_FINDINGS_FLOWPLAN_TSV_V1 BEGIN -->

## Findings/Learnings (Stand 2026-02-23)

- Pseudo-TSV: Dateien enthielten das Zeichenpaar Backtick plus t statt echter Tab-Zeichen. Folge: Parser liefert 0 Zeilen.
- Normalizer: Wandelt Backtick-plus-t in echte Tabs um, danach ist TSV wieder standard-parsebar.
- Writer-Regel: TSV-Zeilen immer per Join mit Tab als Separator erzeugen (robuster als zusammengesetzte Formatstrings).
- PS-Falle: Count nie direkt auf Where-Object Ergebnis; immer array-sicher zaehlen (Array-Klammern).
- PS-Falle: Join-Path ohne Arrays und ohne trailing Komma; sonst System.Object[] Fehler.
- PS-Falle: wörtliches Dollar-p-Doppelpunkt darf nicht in double quotes stehen; sonst ParserError. In Texten Single Quotes nutzen oder Dollar escapen.
- PS-Falle: Here-Strings sind extrem strikt; fuer Tool-Generatoren besser ohne Here-Strings arbeiten (Zeilenliste plus Join).
- Prozess-Regel: Findings-Update muss automatisch im Standard-Runner laufen (nach Apply, vor Done) plus Marker-Gate.

<!-- EGO_FINDINGS_FLOWPLAN_TSV_V1 END -->

<!-- EGO_FINDING_PWSH_DOLLAR_HERESTR_V1 BEGIN -->
## PowerShell Tooling: $-Interpolation & Here-String Regeln (NIE WIEDER)

- Regex-Pattern/Replacement mit `$...` **niemals** in double quotes schreiben.
  - Immer single quotes **oder** `$` explizit escapen/doppeln.
- Here-Strings:
  - `@" ... "@` ist **expandierend** → wenn `$` im Text vorkommen kann: **immer** `@' ... '@` oder Token-Replace.
- Generator/Patcher:
  - **nie** nested Here-Strings (Here-String in Here-String).
  - statt dessen: **Zeilenliste + Join** oder **Template-Datei + Token-Replace**.
- Technische Absicherung:
  - Gate: `tools\gate-pwsh-dollar-hazards.ps1` muss in Runnern laufen (repo + _INTERN).

<!-- EGO_FINDING_PWSH_DOLLAR_HERESTR_V1 END -->

<!-- EGO_SHARED_BLOCK POST_APPLY_MUST_RUN_V1 BEGIN -->
## Pflicht nach jeder Änderung (kein "optional")

- Wenn SSOT gepatcht wurde: **immer** `ssot-refresh-proxy.ps1` ausführen.
- Wenn Tools/Gates gepatcht wurden: **immer** relevante Gate(s) + Runner-Standardgates ausführen.
- "Optional" nur, wenn ausdrücklich **"lass aus"** gesagt wurde.

<!-- EGO_SHARED_BLOCK POST_APPLY_MUST_RUN_V1 END -->

<!-- EGO_SHARED_BLOCK TOOL_PATCH_STRATEGY_V1 BEGIN -->
## Tool-Patching Strategie (NIE WIEDER kaputtpatchen)

- Wenn ein Tool Inhalte **nicht** als Here-String baut (z.B. String-Emitter/Array + später Regex-Replace):
  - keine “in-place” Patch-Annäherungen mit falschen Ankern.
  - stattdessen: **deterministisch neu schreiben** (Rewrite) mit Backup + Verify.
- Generator-Templates:
  - Backticks in Template-Text vermeiden (Parser-Fallen).
  - Newline: `[Environment]::NewLine` statt ``"`r`n"``.
  - Split: `"\r?\n"` statt backtick-Varianten.

- Pflicht danach:
  - SSOT gepatcht → `ssot-refresh-proxy.ps1`
  - Tools gepatcht → Gate(s) + Runner-Standardgates

<!-- EGO_SHARED_BLOCK TOOL_PATCH_STRATEGY_V1 END -->

<!-- CHG:PM_ENTERPRISE_BEGIN -->
## Projektmanagement (Enterprise) – Anti-Tool-Verrennen

### Ziel
Verhindern, dass wir von Baustelle zu Baustelle springen. Fokus auf **eine** Lieferung pro Change-Batch.

### WIP-Limit (Stop-the-line)
- **WIP=1**: Unter ## WIP in TODO.md darf maximal **1** Item stehen.
- Wenn WIP > 1: **Gate ROT** → keine neuen Arbeiten, erst Triage + Reduktion.

### Intake-Regel (Ideen-Parkplatz)
- Alles, was „nebenbei“ auffällt, wird **nur** in ## Parking Lot erfasst.
- Umsetzung erst nach Triage (P0–P3) und nur, wenn es in WIP gezogen wurde.

### Change Management (Minimal, verbindlich)
Jeder Batch hat:
- **CHG-ID**: CHG_YYYYMMDD_HHMMSS_slug
- **Scope**: betroffene Dateien/Ordner
- **Backout**: Backup-Ordner Pflicht
- **DoD**: welche Gates/Checks grün sein müssen
- **Report**: Ergebnisdatei (Scan/Apply/Verify)

### DoR / DoD
**Definition of Ready (DoR)** für WIP:
- Scope klar, DoD klar, Risiko ok, Backout vorhanden.

**Definition of Done (DoD)**:
- APPLY abgeschlossen
- VERIFY (Gates) grün
- Report abgelegt
- Commit-Cluster passend zum CHG-ID

### Instanzen/Rollen (klein, aber eindeutig)
- PM/Scope Owner
- Tooling Owner
- Flow/Content Owner
- QA Gate Owner
- Legal/Privacy Owner (Checkliste/Review)

### Fehlermuster (Lessons)
- Session-Abhängigkeiten (Variablen fehlen) → One-Block-Regel erzwingen
- Platzhalter-Kommandos (...) → verboten
- „Ad-hoc“-Patches ohne Backup → verboten

<!-- CHG:PM_ENTERPRISE_END -->

### GLOBAL Pitfall Gate: Here-Strings + StrictMode

**Problem (global):** Unter `Set-StrictMode -Version Latest` crasht ein double-quoted Here-String, sobald er `$`-Tokens enthält (Expansion/„variable not set“/Parser-Noise durch Copy-Paste).

**Regel (hart):**
- In Tools/Docs **keine** `@" ... "@` verwenden, wenn im Block `$...` vorkommt.
- Standard für Snippets/Textblöcke: **immer** `@' ... '@` (keine Expansion).

**Stop-the-line Gate:**
- `_INTERN\tools\gate-here-strings.ps1 -Roots <paths>` muss **PASS** sein, sonst **ExitCode 3**.

**Zusatz-Learning (aus Crash-Transcript):**
- In PowerShell-Strings keine „Pseudo-Beispiele“ wie `@" ... "@`/`...` mit eingebetteten Backticks in **double quotes** in Report-Zeilen verwenden.
- Für Report-/Log-Texte: bevorzugt **single quotes** + Konkatenation (robust gegen Parser/Copy-Paste/Chat-Transform).

### Nervensystem: Dateianalyse, Inventar, Change Management
**Ziel:** Keine Annahmen. Jede Änderung ist nachvollziehbar, reproduzierbar und auditierbar – auch wenn Teile nicht öffentlich sind.
**Prinzipien:**
- **Dateianalyse zuerst:** Jede Maßnahme startet mit Scan/Inventar (Dateien, Verzeichnisse, Patterns, Risiken).
- **Verzeichnis ist Teil der Wahrheit:** Struktur ist dokumentiert (Root-Folders, Purpose, Ownership, Constraints).
- **Change Management:** Jede Änderung hat *Reason → Scope → Patch → Verify → Report* inkl. Backup.
- **Single Source of Truth:** Alle Regeln/Gates/Tools verweisen auf SSOT-Dokumente; keine „Neben-Notizen“.
**Artifacts (Pflicht):**
- `_reports\...` pro Run (Report.md, ggf. CSV/Inventory)
- `_patch_backups\...` pro Apply
- Tool-Scripts unter `_INTERN\tools` (kein Mega-One-Liner)
- SSOT Refresh am Ende, damit Index/Querverweise stimmen
**Standard-Runbook:**
SCAN → PLAN → APPLY → VERIFY → REPORT (Stop-the-line bei Gate-Fail)

### Annex: Eingefügter Text

Quelle: 
Timestamp: 20260224_151840

#### Klassifizierung (GLOBAL/MODUL)

#### Volltext (Beleg)
```text
```


<!-- EGO_FINDINGS_ANNEX_START -->
## Annex: Eingefügter Text

Quelle: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\Eingefügter Text.txt
Timestamp: 20260224_182216

[BEGIN_TEXT]
Eingefügter Text (rekonstruiert aus Chat-Transcript)

STOP/Findings:
- Source missing: C:\Users\carst\Downloads\Eingefügter Text.txt  (Input war nur Konsolen-Ausgabe und ist volatil)
- Gate Script geschrieben: _INTERN\tools\gate-here-strings.ps1
- Docs-Update-Block stoppt ohne REPORT/Next-Step (kein try/catch/finally -> kein Always-Report)

Enterprise-Regeln:
- Wahrheit = lokales Dateisystem (Inbox/Reports/Inventar); Chat ist nur UI.
- KISS: mehrere kurze Tools statt Mega-One-Liner/BigBlock.
- Change Mgmt Pflicht: Reason -> Scope -> Patch -> Verify -> Report + Backup.
- STOP-the-line Pflicht: STOP immer Report + Next-Step.
- Cleanup Pflicht: Dateisystem nicht aufblasen; Müll konsequent entsorgen/verschieben.
[END_TEXT]
<!-- EGO_FINDINGS_ANNEX_END -->

### AUTO_SSOT_AUTOPILOT_RUN_EXCEPTION_92f41b1c0b04

**Titel:** ssot-autopilot-run: Exception Auto-Finding

**Tags:** powershell, auto, finding, ssot-autopilot-run

**Problem:** Type: System.Management.Automation.CommandNotFoundException
Message: The term 'ReadUtf8NoBom' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

**Fix:** Fehler beheben; wenn wiederkehrend: Guard/Policy ergänzen. Dieser Eintrag wurde automatisch erzeugt.

**Anti-Pattern:**
- Exception ignorieren oder nur lokal fixen ohne SSOT-Update.


### AUTO_SSOT_AUTOPILOT_RUN_EXCEPTION_3ef335d40dcd

**Titel:** ssot-autopilot-run: Exception Auto-Finding

**Tags:** powershell, auto, finding, ssot-autopilot-run

**Problem:** Type: System.Management.Automation.PropertyNotFoundException
Message: The property 'Count' cannot be found on this object. Verify that the property exists.

**Fix:** Fehler beheben; wenn wiederkehrend: Guard/Policy ergänzen. Dieser Eintrag wurde automatisch erzeugt.

**Anti-Pattern:**
- Exception ignorieren oder nur lokal fixen ohne SSOT-Update.

<!-- TOOLING_PARSER_FINDINGS_V2 BEGIN -->
## Tooling/Parser Findings (V2)

Ziel: Parser-/Copy-Paste-Schäden früh erkennen (vor Runner), reproduzierbar reporten, STOP-the-line sauber.

### Kernregel
- Jedes Tool, das Code generiert oder Patches schreibt: zuerst Parser-Check auf betroffene *.ps1.
- Keine fragilen Escapes in Console-Blöcken (\" / Backticks in Strings). Rewrite-first als Tool-Datei.

### Minimaler Parser-Check (PowerShell)
- API: [System.Management.Automation.Language.Parser]::ParseFile(<path>, [ref]$null, [ref]$null)
- Ergebnis: bei ParseErrors => STOP-the-line + Report + Backup.

### Exclude-Policy (Scanner/Lint)
Ignoriere konsequent:
- _patch_backups / _reports / _local / _TRASH / .git / node_modules

### Standard-Workflow bei ParserError
SCAN (Zeile/Spalte) -> PLAN (Rewrite als Tool-Datei) -> APPLY (Backup) -> VERIFY (Parser=0) -> REPORT.
<!-- TOOLING_PARSER_FINDINGS_V2 END -->

<!-- BEGIN:CHAT_UPSERT_20260225_ENTERPRISE_OPS -->

## Roadmap-Update (Chat 2026-02-25)

### Phase: Autopilot-Haerte (laufend)
1) SSOT Guard verbindlich vor Runner
2) Parser-Lint Gate vor Runner (P0 abschliessen: FAIL_COUNT=0)
3) Maintenance-Task laeuft woechentlich (SSOT immer frisch)
4) Danach: Funnel-Scan ueber alle Seiten + Link-Mismatch/Weiter-Policy konsequent

<!-- END:CHAT_UPSERT_20260225_ENTERPRISE_OPS -->

<!-- EGO_AUTO_PATCH__EVERGREEN_ROADMAP_BLOCK_20260225 : BEGIN -->
## Evergreen Roadmap (Master-Template -> Netzwerk)

Canon:
- EGO ist Master-Template.
- Wir bauen danach Evergreen-Projekte als Netzwerk mit gleichem Governance-Geruest, gleichen Gates und gleicher Funnel-Mechanik.
- Wir machen weiter, solange objektiv Kandidaten >= Build-Schwelle existieren.

Siehe:
- EVERGREEN_PIPELINE_INTERNAL.md
- EVERGREEN_CANDIDATES_INTERNAL.tsv
- Tool: _INTERN/tools/evergreen-pipeline-run.ps1
<!-- EGO_AUTO_PATCH__EVERGREEN_ROADMAP_BLOCK_20260225 : END -->

### AUTO_EGO_RUN_EXCEPTION_e2c3dc2503e8

**Titel:** ego-run: Exception Auto-Finding

**Tags:** powershell, auto, finding, ego-run

**Problem:** Type: System.Management.Automation.RuntimeException
Message: STOP: SSOT docs changed vs baseline. Re-run after acknowledging baseline update.

**Fix:** Fehler beheben; wenn wiederkehrend: Guard/Policy ergänzen. Dieser Eintrag wurde automatisch erzeugt.

**Anti-Pattern:**
- Exception ignorieren oder nur lokal fixen ohne SSOT-Update.

<!-- EGO_SHARED:SSOT_INBOX_EMPTY_IS_OK -->
### SSOT_INBOX_EMPTY_IS_OK
 
Normalzustand: Inbox kann leer sein.
 
- `IMPORT_SHARED_BLOCKS: No inbox files -> nothing to do.` ist **OK** und kein Fehler.
- Shared-Blocks sind Canon in den SSOT-Dokumenten und werden via `PROPAGATE` verteilt.
- Inbox ist nur ein optionaler Import-Kanal (z.B. temporaere Einmal-Inputs), kein Muss.
 
<!-- /EGO_SHARED:SSOT_INBOX_EMPTY_IS_OK -->

<!-- EGO_SHARED:QA_NAMED_GATE_SUITES -->
### QA_NAMED_GATE_SUITES
 
Ziel: Wiederkehrende Pruefpakete eindeutig benennen, damit Reports/TODOs nicht schwammig werden.
 
Begriffe (Namen sind Canon):
 
- `MVP02`: Content-Rollout Gate-Suite (Seiten/Cluster/Rechner-Index/Weiter-Block/Footers/Links)
- `NO_MURX`: Hygiene-Suite (ASCII filenames, UTF-8 no BOM, No-Emoji, Permalinks, baseurl+.html, keine Sackgassen)
- `LEGAL_HINTS`: Rechtliches/Kommunikation (Impressum/Datenschutz/Disclaimer konsistent, keine falschen Versprechen, Download-Hinweise korrekt)
 
Regel:
- Namen duerfen in Reports/TODO/Findings verwendet werden **nur**, wenn die jeweilige Suite im QA-Dokument beschrieben ist.
- Wenn eine Suite noch nicht vollstaendig definiert ist: Report muss `SUITE_DEFINED: False` markieren.
 
<!-- /EGO_SHARED:QA_NAMED_GATE_SUITES -->

## 2026-03-03 – P0 Enterprise Update (All Docs Check)

Grundregel (P0):
- Wenn irgendein SSOT-Dokument ein Update bekommt, wird immer ALLES geprueft und alles, was sinnvoll/moeglich ist, upgedatet.
- Danach muss ssot-refresh.ps1 (via ssot-refresh-proxy) laufen.

Proaktive Regeln aus der Schlacht:
- Fullswap statt Flick bei parserkritischen Steps.
- Keine Markdown-Codefences/Backticks in Steps, die Markdown schreiben (nur Plain-Text).
- Verbot in Steps: Ellipsis-Platzhalter. Stattdessen "<PATHS>" oder "[PLACEHOLDER]".
- "code -g <datei>" nur, wenn du diese Datei aktiv editieren sollst.
- Parse-Verify nur fuer PowerShell-Dateien (.ps1/.psm1/.psd1).
- ConvertFrom-Json liefert PSObject: wenn Key-Indexing gebraucht wird, nach Load-State zu Hashtable normalisieren.
- Tool-Scope-Awareness: Detektor-Strings in tools/* sind erlaubt und duerfen nicht als Finding gelten.

<!-- EGO_FILEFIRST_TOOL_LAWS_START -->
## EGO File-First und Tool-Inventar (hart)

- Stand: 20260306_155341

### Betriebsgesetze

- file-first ist P0.
- OPEN nur, wenn danach wirklich FULLSWAP folgt.
- Ablauf strikt: OPEN -> FULLSWAP -> VERIFY -> RUN -> Output.
- Keine Inline-FULLSWAPs im Chat.
- Keine Konsolexperimente als Edit-Ersatz.
- Bei Step-/Parser-/Dateidefekten gilt Fullswap statt Partial-Patch.
- Vor jedem Tool-Einsatz muss klar sein: Zweck, Wirkung, Ort, Risiko, Keep/Fix/Delete-Entscheidung.

### Kanonische Tool-Orte

- `_INTERN\tools`: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools
- `repo\tools`: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\tools
- `_INTERN\governance\tools`: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\tools

### Tool-Inventar Snapshot

| Tool | Ort | Zweck | Parse | Klasse | Aktion | Hash |
|---|---|---|---:|---|---|---|
| apply-visibility-cleanup.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 44744203 |
| audit-l2-pack.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 32ca7f6f |
| brain-core-docs-apply.ps1 | GOV_TOOLS | Core-Docs in Brain anwenden/spiegeln | 1 | SINGLE_OK | KEEP | 16560b3c |
| brain-docs-upsert.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 372b23f0 |
| brain-sync-required.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 4acd34ed |
| brain-sync-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f396176e |
| bundle-apply.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 243a39aa |
| check-download-hubs-live.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | b4d94e48 |
| check-ps-parser-file.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 9b037c26 |
| ci-make-autopilot-step.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 48f49ae1 |
| closeout-status.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f29929a5 |
| cmd-file.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f59bf390 |
| cmd.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 993baf3f |
| daily-autosave.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 7425574b |
| ego-audit-pack.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | eeee4742 |
| ego-bundle-audit.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 326c269e |
| ego-checksums.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | a684f2e2 |
| ego-env.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 3dac58d3 |
| ego-findings-upsert.ps1 | INTERN_TOOLS | Findings upsert / Annex in Governance | 1 | SINGLE_OK | KEEP | 7a36c019 |
| ego-flow-audit-v2.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | d93a43b7 |
| ego-flow-audit.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 94a9b015 |
| ego-flow-gates.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | d12dfa67 |
| ego-fullswap-file.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | d899190f |
| ego-law-run-safe.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | d1960bfc |
| ego-law-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 0027bb88 |
| ego-nervensystem.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 0cc2d90d |
| ego-ods-hide-sheets.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | edbd053f |
| ego-pagecard.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 7ebfe1c1 |
| ego-rereview-analyze.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 6c32df69 |
| ego-rereview-fix.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 0494142a |
| ego-rereview-lib.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | b8fd65fb |
| ego-rereview-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | e8716340 |
| ego-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 896e618f |
| ego-smoke-core.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | e0b2b615 |
| ego-step.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 643d4226 |
| ego-super-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 997a6e46 |
| ego.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 6411c14b |
| enterprise-autopilot-step.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 077ac528 |
| enterprise-preflight-step.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | bb883cc1 |
| enterprise-preflight.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | e6927464 |
| enterprise-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 8f088a36 |
| eol-normalize.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 43bf1fa1 |
| finish-one.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | e7280485 |
| flow-audit.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | e65eb1e0 |
| flow-quality-forensics.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | cb8c586e |
| flow-quality-gate.ps1 | INTERN_TOOLS | Flow-Warnungen und Gate-Report | 1 | SINGLE_OK | KEEP | 82063fed |
| flow-quality-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 74e98e8d |
| frontmatter-leading-fix.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | a86ae285 |
| gate_download_hubs_strict.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1852e264 |
| gate_no_local_links.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | dd2652ee |
| gate_tools_no_local_markers.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 475dac1e |
| gate-actions-autopilot-policy.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f2c59255 |
| gate-actions-smoke-policy.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 069206f3 |
| gate-actions-trigger-policy.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 62c15f47 |
| gate-brain-root-freshness.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1acc5913 |
| gate-brain-sync-freshness.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 5856a2c9 |
| gate-bundle-release.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | e8855e8b |
| gate-closeout-after-commit.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | b197f591 |
| gate-contentfile-must-exist.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 01ba4719 |
| gate-enterprise-laws-v1.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 3d4037cc |
| gate-enterprise-laws-v2.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | efbfd23c |
| gate-file-first-step-only.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 273177aa |
| gate-frontmatter-nav.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 70d08da4 |
| gate-inventory-present.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 7e52c36c |
| gate-joinpath-argcount.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 7b671203 |
| gate-learning-coverage.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 550a25c8 |
| gate-no-absolute-paths-in-tools.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 4f03cc8f |
| gate-no-big-paste.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | bc9809d9 |
| gate-no-binder-traps.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 01ae03f1 |
| gate-no-command-glue.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 5d345a62 |
| gate-no-console-transcripts.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f7fb012d |
| gate-no-dollar-underscore-in-dq.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | a02ee2b6 |
| gate-no-dollar0-regex-replace.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 8377e331 |
| gate-no-dq-regex-with-dollar.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | d353e5d4 |
| gate-no-emoji.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 598bf588 |
| gate-no-exit-in-steps.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | b5ae11b8 |
| gate-no-fake-ok.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | b597f2d1 |
| gate-no-format-brace-traps.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 38b733f9 |
| gate-no-heresting-nesting.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1f82604c |
| gate-no-inline-dirty-changes.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | d0981071 |
| gate-no-inner-single-quotes-in-command.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | dc6237b0 |
| gate-no-invalid-var-colon.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 8c386a97 |
| gate-no-literal-n-newlines.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 82d4ece2 |
| gate-no-missing-stepfiles.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 893948ea |
| gate-no-missing-workflow-script.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 5d76e7d0 |
| gate-no-placeholder-regex-in-gates.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | c7698aa0 |
| gate-no-prompt-paste.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1b755d71 |
| gate-no-regex-patch-v1.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 01fef56d |
| gate-no-regex-path-filters.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 5e15ca96 |
| gate-no-relative-file-io.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 37ae5e2b |
| gate-no-two-line-file-in-yaml.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f5b56b8b |
| gate-no-unsafe-heredoc.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 31157b09 |
| gate-page-basics-v1.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 4944f4d0 |
| gate-param-must-be-first.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 3e727994 |
| gate-proof-required.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 552d04a7 |
| gate-ps-parser-all-tools.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 7dd93ca4 |
| gate-public-leaks.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 05f53f7a |
| gate-pwsh-dollar-hazards.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 9aa65702 |
| gate-repo-sanity-scan.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | fcf99405 |
| gate-reports-no-errors.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 93c0fefc |
| gate-research-proof-required.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 930e3067 |
| gate-ssot-loadorder-present.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | cead518e |
| gate-ssot-proxy.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 65a696d6 |
| gate-step-fullswap-contract.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 7a0b8fbb |
| gate-step-joinpath-arraysafe.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 2fe41dac |
| gate-step-no-invalid-var-colon.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 69a35af9 |
| gate-step-reporoot-absolute.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 451c9e1a |
| gate-step-write-allowlist.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | d9d07183 |
| gate-stepfile-required.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | a2972777 |
| gate-thema-alias-map.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 83968f65 |
| gate-tools-ascii-only.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 16204783 |
| gate-tools-parse.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | e6084490 |
| gate-weiter-ux-policy.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 213d2430 |
| gen-sitemap.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | cd4583cf |
| gen-themen-pfade-map.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 4c93c6cb |
| hygiene-minimum.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 73232fd5 |
| klaus-go.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 5fd027d6 |
| klaus-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | b4c1552f |
| legal-hints-gate.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | ee771d63 |
| legal-minimum-warn.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | ef717d4a |
| link-scan.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 612e3e61 |
| live-checklist-explainer.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | ea1522fa |
| live-checklist-manual.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 36c01a87 |
| live-checklist-open.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | a19cdcf6 |
| live-checklist.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 83e985de |
| live-probe.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 7b1a47d9 |
| mvp02-batch.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f6939e25 |
| mvp02-fix-broken-liquid-links.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 72bf6682 |
| mvp02-fix-minirechner-links.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 75cec85b |
| mvp02-fix-weiterlinks.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 074baedd |
| mvp02-gate.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1f9cfa0d |
| nav-visibility-audit.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 94e89104 |
| nav-visibility-fix.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | fa2f55fc |
| new-step.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 64aba94c |
| no-murx-gate.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | c56d7e1e |
| permalink-strip-baseurl.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | cf083bb2 |
| policy-blocks-minimal-apply.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 8402f617 |
| post-step-live.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | cd566c1a |
| project-chat-hygiene.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 363e272c |
| project-classify.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1eecc8bb |
| project-inventory.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f8e27dc6 |
| project-keep-scan.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 30e338f1 |
| project-move.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 549e0e39 |
| project-purge.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | d37b78bf |
| push-one.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 71c396ff |
| release-readiness-minicheck.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 0968d4b2 |
| repo-scan.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 0dbdcc0e |
| round-closeout.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | cfe01f51 |
| run-latest-step.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 4f300748 |
| safe-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1bad9b0c |
| save-step-from-clipboard.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1770265b |
| scan-download-hubs-cta.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | fbb24d20 |
| scan-weiter-links-download-hubs.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 1694bb8e |
| show-latest-run-errors.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 0a256517 |
| show-latest-run-log.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | a0bf7e20 |
| smoke-http.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 7e78f0ef |
| ssot-brain-sync-run.ps1 | GOV_TOOLS | SSOT/Brain Sync Runner | 1 | SINGLE_OK | KEEP | fd3e1a0f |
| ssot-refresh-proxy.ps1 | INTERN_TOOLS | SSOT-Refresh Runner/Proxy | 1 | MIRRORED_OK | KEEP | 95015309 |
| ssot-refresh-proxy.ps1 | REPO_TOOLS | SSOT-Refresh Runner/Proxy | 1 | MIRRORED_OK | KEEP | 95015309 |
| ssot-refresh-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | f396176e |
| ssot-refresh.ps1 | INTERN_TOOLS | SSOT-Refresh Core | 1 | SINGLE_OK | KEEP | 4059eb5e |
| ssot-sync.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 5777096d |
| ssot-tools-registry.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | aa8304f6 |
| step-new-open.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 4c7d27cd |
| step-new.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | de00c503 |
| step-open-latest.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | c56c9f8c |
| step-open-run-latest.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 3e629b27 |
| step-run-latest.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | db77f911 |
| step-run.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 8c0a0072 |
| todo-inventar.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 76bc352a |
| tools-readonly-wrapper.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 99a6f98a |
| update-desktop-bootstrap.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 233d1be2 |
| weiter-fix.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 0a4c7b89 |
| weiter-gate.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 8e5ed4eb |
| weiter-patcher.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 65415c06 |
| write-step.ps1 | REPO_TOOLS | UNKNOWN_REVIEW_REQUIRED | 1 | UNKNOWN_TOOL | REVIEW_KEEP_OR_DELETE | 72cecec8 |

### Verbindliche Folgeregel

- UNKNOWN_TOOL oder DEFECT_PARSER werden nicht blind benutzt.
- KEEP/FIX/DELETE erfolgt nur ueber separaten Apply-Batch mit Verify und Report.
- Tool-Wissen muss in SSOT und Brain gespiegelt sein, nicht nur implizit im Chat.
<!-- EGO_FILEFIRST_TOOL_LAWS_END -->

<!-- EGO_OPENAI_REGRESS_ROADMAP_V1:START -->
## EGO_OPENAI_REGRESS_ROADMAP_V1

### Neuer Strang
Betriebsstabilitaet / OpenAI-Service-Reliability

### Ziele
1. OpenAI_Logs als feste Evidenzquelle an EGO andocken
2. Incident-Rollup automatisieren (JSONL -> SSOT/Brain/QA/TODO)
3. Preflight fuer dateibasierte ChatGPT-Arbeitslaeufe einfuehren
4. Regress-/Refund-Dossier aus Logs + Status + Screenshots standardisieren
<!-- EGO_OPENAI_REGRESS_ROADMAP_V1:END -->

<!-- EGO_PROJECTWIDE_FULLTEXTSWAP_ONLY_NO_FRAGMENT_REPLACEMENT_V1_BEGIN -->
## P0: FULLTEXTSWAP_ONLY_NO_FRAGMENT_REPLACEMENT (hart)

- Projektweit werden Dateiaenderungen nur noch als FULLTEXTSWAP des kompletten Dateiinhalt ausgefuehrt.
- Keine Textfragmente, keine Teilblock-Ersetzungen, keine Zeilenpatches, keine Snippet-Fixes, keine "ersetze nur diese 2 Zeilen"-Anweisungen.
- File-first bleibt zwingend: OPEN -> FULLSWAP -> VERIFY -> RUN -> REPORT.
- Vor jedem Apply-, Pfad- oder Strukturbezug bleibt echter Real-/Faktenscan Pflicht.
- Diese Invariante gilt bindend fuer Bootstrap, Governance, SSOT, QA, Learnings, TODO, Brain und alle Folge-Tasks projektweit.
- Der zulaessige Bearbeitungsmodus fuer Dateien ist ab jetzt ausschliesslich kompletter Dateiinhalt per FULLSWAP.
<!-- EGO_PROJECTWIDE_FULLTEXTSWAP_ONLY_NO_FRAGMENT_REPLACEMENT_V1_END -->

<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_FIXKOSTEN_CLOSEOUT_20260328:START -->
## ROADMAP NOTE - AFTER FIXKOSTEN CLOSEOUT - 20260328

- MONAT-Strang bleibt gruener Closeout-Stand.
- PLANUNG-Strang bleibt gruener Closeout-Stand.
- JAHR-Strang bleibt gruener Closeout-Stand.
- BUDGETS-Strang bleibt gruener Closeout-Stand.
- FIXKOSTEN-Strang ist jetzt ebenfalls gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-work-under-verified-stage-only-after-fixkosten-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_FIXKOSTEN_CLOSEOUT
- Kein Rueckfall in FIXKOSTEN ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_FIXKOSTEN_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_NOTGROSCHEN_CLOSEOUT_20260328:START -->
## ROADMAP NOTE - AFTER NOTGROSCHEN CLOSEOUT - 20260328

- MONAT-Strang bleibt gruener Closeout-Stand.
- PLANUNG-Strang bleibt gruener Closeout-Stand.
- JAHR-Strang bleibt gruener Closeout-Stand.
- BUDGETS-Strang bleibt gruener Closeout-Stand.
- FIXKOSTEN-Strang bleibt gruener Closeout-Stand.
- NOTGROSCHEN-Strang ist jetzt ebenfalls gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-work-under-verified-stage-only-after-notgroschen-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_NOTGROSCHEN_CLOSEOUT
- Kein Rueckfall in NOTGROSCHEN ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_NOTGROSCHEN_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_SCHULDEN_CLOSEOUT_20260328:START -->
## ROADMAP NOTE - AFTER SCHULDEN CLOSEOUT - 20260328

- MONAT-Strang bleibt gruener Closeout-Stand.
- PLANUNG-Strang bleibt gruener Closeout-Stand.
- JAHR-Strang bleibt gruener Closeout-Stand.
- BUDGETS-Strang bleibt gruener Closeout-Stand.
- FIXKOSTEN-Strang bleibt gruener Closeout-Stand.
- NOTGROSCHEN-Strang bleibt gruener Closeout-Stand.
- SCHULDEN-Strang ist jetzt ebenfalls gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-work-under-verified-stage-only-after-schulden-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_SCHULDEN_CLOSEOUT
- Kein Rueckfall in SCHULDEN ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_SCHULDEN_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_MONATSABSCHLUSS_CLOSEOUT_20260328:START -->
## ROADMAP NOTE - AFTER MONATSABSCHLUSS CLOSEOUT - 20260328

- MONAT-Strang bleibt gruener Closeout-Stand.
- PLANUNG-Strang bleibt gruener Closeout-Stand.
- JAHR-Strang bleibt gruener Closeout-Stand.
- BUDGETS-Strang bleibt gruener Closeout-Stand.
- FIXKOSTEN-Strang bleibt gruener Closeout-Stand.
- NOTGROSCHEN-Strang bleibt gruener Closeout-Stand.
- SCHULDEN-Strang bleibt gruener Closeout-Stand.
- MONATSABSCHLUSS-Strang ist jetzt ebenfalls gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-work-under-verified-stage-only-after-monatsabschluss-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_MONATSABSCHLUSS_CLOSEOUT
- Kein Rueckfall in MONATSABSCHLUSS ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_MONATSABSCHLUSS_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_STEUER_CLOSEOUT_20260328:START -->
## ROADMAP NOTE - AFTER STEUER CLOSEOUT - 20260328

- MONAT-Strang bleibt gruener Closeout-Stand.
- PLANUNG-Strang bleibt gruener Closeout-Stand.
- JAHR-Strang bleibt gruener Closeout-Stand.
- BUDGETS-Strang bleibt gruener Closeout-Stand.
- FIXKOSTEN-Strang bleibt gruener Closeout-Stand.
- NOTGROSCHEN-Strang bleibt gruener Closeout-Stand.
- SCHULDEN-Strang bleibt gruener Closeout-Stand.
- MONATSABSCHLUSS-Strang bleibt gruener Closeout-Stand.
- STEUER-Strang ist jetzt ebenfalls gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-work-under-verified-stage-only-after-steuer-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_STEUER_CLOSEOUT
- Kein Rueckfall in STEUER ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_STEUER_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_SPARZIELE_CLOSEOUT_20260328:START -->
## ROADMAP NOTE - AFTER SPARZIELE CLOSEOUT - 20260328

- MONAT-Strang bleibt gruener Closeout-Stand.
- PLANUNG-Strang bleibt gruener Closeout-Stand.
- JAHR-Strang bleibt gruener Closeout-Stand.
- BUDGETS-Strang bleibt gruener Closeout-Stand.
- FIXKOSTEN-Strang bleibt gruener Closeout-Stand.
- NOTGROSCHEN-Strang bleibt gruener Closeout-Stand.
- SCHULDEN-Strang bleibt gruener Closeout-Stand.
- MONATSABSCHLUSS-Strang bleibt gruener Closeout-Stand.
- STEUER-Strang bleibt gruener Closeout-Stand.
- SPARZIELE-Strang ist jetzt ebenfalls gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-work-under-verified-stage-only-after-sparziele-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_SPARZIELE_CLOSEOUT
- Kein Rueckfall in SPARZIELE ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_SPARZIELE_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_START_CLOSEOUT_20260328:START -->
## ROADMAP NOTE - AFTER START CLOSEOUT - 20260328

- MONAT-Strang bleibt gruener Closeout-Stand.
- PLANUNG-Strang bleibt gruener Closeout-Stand.
- JAHR-Strang bleibt gruener Closeout-Stand.
- BUDGETS-Strang bleibt gruener Closeout-Stand.
- FIXKOSTEN-Strang bleibt gruener Closeout-Stand.
- NOTGROSCHEN-Strang bleibt gruener Closeout-Stand.
- SCHULDEN-Strang bleibt gruener Closeout-Stand.
- MONATSABSCHLUSS-Strang bleibt gruener Closeout-Stand.
- STEUER-Strang bleibt gruener Closeout-Stand.
- SPARZIELE-Strang bleibt gruener Closeout-Stand.
- START-Strang ist jetzt ebenfalls gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-work-under-verified-stage-only-after-start-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_START_CLOSEOUT
- Kein Rueckfall in START ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_START_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_STABILITY_FREEZE_AND_DEFER_SURFACE_HARMONIZATION_20260330:START -->

## HAUSHALTSBUCH stability freeze + deferred surface harmonization - 2026-03-30

- ACTIVE_THEME=HAUSHALTSBUCH
- WORKBOOK_TECHNICAL_STATE=STABLE
- WORKBOOK_SHA256=0339EF5F94120AE1A40D8E902AEE7045D83D7DEC0DBF5F4B6DCC5926C8B9CF35
- PRODUCT_VISIBLE_SYNTHETIC_BATCH_FILL_REMOVED=YES
- HAUSHALTSBUCH_SURFACE_ROW_HEIGHT_CHAOS_CONFIRMED=YES
- HAUSHALTSBUCH_SURFACE_HIDDEN_STATE_ROOTCAUSE=NO
- HAUSHALTSBUCH_SURFACE_ROOTCAUSE_KIND=ROWHEIGHT_STYLE_INCONSISTENCY
- SURFACE_HARMONIZATION_RUN_KIND=SEPARATE_WORKBOOKWIDE_AFTER_FORMULA_XML_FREEZE
- NO_VISIBLE_SYNTHETIC_ENDUSER_ROWS=ACTIVE
- STABILITY_BEFORE_SURFACE_HARMONIZATION=ACTIVE
- NEXT_EXACT_STEP=FILL_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_WITH_REAL_SOURCE_ROWS

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_STABILITY_FREEZE_AND_DEFER_SURFACE_HARMONIZATION_20260330:END -->

<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_HAUSHALTSBUCH_CLOSEOUT_20260330:START -->
## ROADMAP NOTE - AFTER HAUSHALTSBUCH CLOSEOUT - 2026-03-30

- MONAT bleibt gruener Closeout-Stand.
- PLANUNG bleibt gruener Closeout-Stand.
- JAHR bleibt gruener Closeout-Stand.
- BUDGETS bleibt gruener Closeout-Stand.
- FIXKOSTEN bleibt gruener Closeout-Stand.
- NOTGROSCHEN bleibt gruener Closeout-Stand.
- SCHULDEN bleibt gruener Closeout-Stand.
- MONATSABSCHLUSS bleibt gruener Closeout-Stand.
- STEUER bleibt gruener Closeout-Stand.
- SPARZIELE bleibt gruener Closeout-Stand.
- START bleibt gruener Closeout-Stand.
- HAUSHALTSBUCH ist im aktuellen Scope gruener Closeout-Stand.
- Aktiver Gesamtpfad jetzt:
  broader-workbook-wide-vollversion-reprioritization-under-verified-stage-only-after-haushaltsbuch-closeout
- Naechster echter Fachschritt:
  WORKBOOKWIDE_REPRIORITIZE_AFTER_HAUSHALTSBUCH_CLOSEOUT
- Kein Rueckfall in HAUSHALTSBUCH ohne neue reale Evidenz.
- Surface-Harmonisierung bleibt separat spaeter.
<!-- EGO_MANAGED_BLOCK:ROADMAP_AFTER_HAUSHALTSBUCH_CLOSEOUT_20260330:END -->

<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A1_O11_CLOSEOUT_20260330:START -->
## ROADMAP NOTE - BEDIENUNG A1:O11 CLOSED - 2026-03-30

- BEDIENUNG A1:O11 is green closed under verified-stage only.
- The block already matched the emitted payload exactly.
- No workbook hash change occurred.
- BEDIENUNG remains the active sheet scope.
- Next exact gate:
  DECIDE_EXACT_BEDIENUNG_NEXT_OPEN_WORK_ITEM_AFTER_A1_O11_CLOSEOUT_UNDER_VERIFIED_STAGE_ONLY
<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A1_O11_CLOSEOUT_20260330:END -->

<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A13_O35_CLOSEOUT_20260330:START -->
## ROADMAP NOTE - BEDIENUNG A13:O35 CLOSED - 2026-03-31

- BEDIENUNG A13:O35 is green closed under verified-stage only.
- Post-A13 tail A36:O79 has no further real non-empty block.
- BEDIENUNG is no longer an open workbook leaf.
- Next exact gate:
  SCAN_EXACT_WORKBOOKWIDE_REPRIORITIZATION_AFTER_BEDIENUNG_CLOSEOUT_UNDER_VERIFIED_STAGE_ONLY
- No fallback into BEDIENUNG without new real evidence.
<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A13_O35_CLOSEOUT_20260330:END -->

<!-- EGO_MANAGED_BLOCK:FREEBIE_PUBLIC_PAID_PRIVATE_RELEASE_RULE_20260331:START -->
## FREEBIE PUBLIC / PAID PRIVATE RELEASE RULE - 2026-03-31

- Nur die FREEBIE-Version darf öffentlich zum Download stehen.
- PRO und VOLLVERSION laufen nicht öffentlich.
- Paid-Tiers laufen nur über Digistore oder private Distribution.
- Paid-Aktivierung, echte Digistore-Links und echte Buy-Flags bleiben End-Gate.
- Diese Regel ist bindend für Release-, Bundle-, Surface-, Funnel-, Sitemap-, Bing-, GSC- und Monetization-Schritte.
<!-- EGO_MANAGED_BLOCK:FREEBIE_PUBLIC_PAID_PRIVATE_RELEASE_RULE_20260331:END -->

<!-- EGO_PREMIUM_REDESIGN_V4_START -->
## 2026-04-11 — Roadmap-Update / Premium Redesign V4

### Phase 1 — Vertrag + Dashboard-Finalizer
- Premium-Vertrag V4 syncen
- START finalisieren
- MONAT finalisieren
- NOTGROSCHEN finalisieren
- JAHR finalisieren
- PLANUNG finalisieren

### Phase 2 — Eingabe-Blätter
- PARAMETER
- HAUSHALTSBUCH
- BUDGETS
- FIXKOSTEN
- LISTEN
- SCHULDEN

### Phase 3 — Review / Verpackung
- AUDIT
- MONATSABSCHLUSS
- BEDIENUNG
- LIZENZ
- STEUER
- SPARZIELE
<!-- EGO_PREMIUM_REDESIGN_V4_END -->
