<!-- EGO_MANAGED_BLOCK:FULL_PROJECT_AUDIT_RECONCILIATION_V1:START -->
## FULL PROJECT AUDIT RECONCILIATION LOCK - 2026-03-19

- Auditbasis ab jetzt verbindlich: komplette Gespraeche seit 2026-01-07, Brain, _INTERN, Projekte, GitHub/Live-Stand, Workbooks, Bundles.
- Die grosse Pre-Paid-Closeout-Kette bleibt geschlossen; kein Rueckfall in False-Positive-, Proof/Trust- oder Placeholder-Reopen-Loops ohne neuen Realbefund.
- Kein real offener Pre-Paid-Block bleibt vor Paid-Aktivierung.
- Paid-Aktivierung, echte Digistore-Links und echte Buy-Flags bleiben End-Gate und sind weiterhin nicht das aktive Thema.
- Kanonischer Abschlussweg ab jetzt: 1) Produkt-Endprodukt-Reife XLSX/ODS je Tier, 2) Public-Surface-/Sitemap-Kanonisierung und CTA-Fix, 3) GitHub Actions / Linkcheck / EGO Gates voll gruen + Node-24-Haertung, 4) Cloudflare/Bing/GSC Evidence-Freeze, 5) erst danach Paid-Aktivierung.
- Das Projekt gilt erst dann als fachlich abgeschlossen, wenn technischer PASS, kaeuferfaehiges Endprodukt, oeffentliche Surface, CI und externe Evidenz zugleich gruen sind.
- Geschlossene Ketten duerfen nur bei neuem Realbefund wieder geoeffnet werden.
<!-- EGO_MANAGED_BLOCK:FULL_PROJECT_AUDIT_RECONCILIATION_V1:END -->


<!-- EGO_MANAGED_BLOCK:ENTERPRISE_MASTERPLAN_PRIORITY_LOCK_V1:START -->
## PRIORITAETS- UND END-GATE-STAND - 2026-03-17

- Die konsolidierte Enterprise-Gesamtplanung ist ab jetzt verbindlich und wird stur nach Prioritaet abgearbeitet.
- Paid-Link-/Digistore-Aktivierung ist ab jetzt ausdruecklich das End-Gate und wird nicht vorgezogen.
- Vor echter Aktivierung muessen Produkt, Bundle/Lieferoberflaeche, Website-Surface, Funnel, Weiterleitungen, Sitemap/robots, Bing/GSC, Inhalte, Recht/Transparenz sowie Release-/QA-/Proof-Stand fertig sein.
- Aktives Thema nach diesem Sync: pre-live-surface-and-funnel-finalization-before-paid-activation
- Referenzdokument: Brain_EGO_Dateien\ENTERPRISE_MASTERPLAN_PRIORITY_2026-03-17.md
<!-- EGO_MANAGED_BLOCK:ENTERPRISE_MASTERPLAN_PRIORITY_LOCK_V1:END -->

<!-- EGO_MANAGED_BLOCK:EXCEL_KNOWN_FAILURE_PREVENTION_SYNC_20260317_204430:START --> ## EXCEL KNOWN FAILURE PREVENTION - 20260317_204430  - Bekannte Excel-/Workbook-/Builder-Fehlerklassen muessen ab jetzt vor jedem relevanten Apply/Run aktiv ausgeschlossen werden. - Fuer Excel gilt ab jetzt kein "teilweise ja" mehr: bekannte Klassen sind Praeventionspflicht; nur unbekannte neue Klassen duerfen noch ueber Sofort-Sync vor Korrektur laufen. - Der naechste echte Fachstrang nach diesem Pflicht-Sync bleibt: search-console-bing-and-monetization-launch-gap-after-paid-surface-ready

<!-- EGO_MANAGED_BLOCK:DOC_PDF_BACKEND_CONTRACT_V1:START -->
## DOC PDF BACKEND CONTRACT - 2026-03-17

- README-/Dokument-/Anleitung-PDF nutzt ab jetzt kanonisch tools\export-readme-anleitung-pdf.ps1.
- Sheet-only Spreadsheet-PDF nutzt weiter kanonisch tools\export-start-sheet-only-pdf.ps1.
- writer_pdf_Export ist kein Default fuer README-/Dokument-/Anleitung-PDF.
- Python ist keine Default-Abhaengigkeit fuer README-/Dokument-/Anleitung-PDF.
- Scratch-Emitter duerfen als Quellen/Prototypen dienen, aber der operative Standard ist der kanonische Tool-Helper unter tools\.
- Finale fachliche RUNs bleiben sync-pflichtig ueber tools\step-run.ps1.
<!-- EGO_MANAGED_BLOCK:DOC_PDF_BACKEND_CONTRACT_V1:END -->

<!-- EGO_MANAGED_BLOCK:ALWAYS_SYNC_EVERY_RUN_HARDLAW_V1:START -->
## P0: ALWAYS_SYNC_EVERY_RUN (hart)

- Jeder echte RUN-Befehl ist ab jetzt zwangsweise ein Sync-RUN.
- Standard fuer mutierende oder verifizierende Ausfuehrung ist nur noch: tools\step-run.ps1.
- step-run ist nicht nur Runner, sondern Pflicht-Sync-Huelle: Fullsync + SSOT-Refresh-Proxy + Repo-Clean-Gate + Required-Reads.
- Keine Chat-Anweisung fuer raw pwsh-Tool-Runs, wenn derselbe Vorgang ueber step-run oder einen sync-faehigen Step abbildbar ist.
- Vorbereitungsbefehle wie step-new/open sind kein fachlicher RUN; jeder anschliessende echte RUN bleibt sync-pflichtig.
- Jede neue FULLSWAP-Stepdatei muss diesen Standard bereits im Schritt selbst mitdenken; kein optionales Nachziehen mehr.
<!-- EGO_MANAGED_BLOCK:ALWAYS_SYNC_EVERY_RUN_HARDLAW_V1:END -->

# EGO_BOOTSTRAP_INTERNAL.md
# Einfach Geld ordnen (EGO) – Bootstrap / Continue Mode (SSOT-first, pwsh-only)

## 0) Fixe Projekt-Identität (nicht diskutieren)

- Projekt: **Einfach Geld ordnen (EGO)**
- Public Repo (GitHub Pages): gluecklich-tools/einfach-geld-ordnen
- Lokales Repo:
  C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen
- SSOT Root (intern):
  C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance
- SSOT Tools (intern):
  C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools

## 1) Arbeitsmodus / Regeln (hart)

- **Enterprise Mode ist immer aktiv (P0).**
- **File-first (NO_BIG_INLINE_COMMAND):** keine großen Inline-Commands/Monster-Pastes.
- **ARTIFACTS_FIRST_CHAT_BOOT (P0):** Am Chatstart werden Brain/_INTERN/Projekte/Gesprächsverlauf eingelesen; wenn Uploads abgelaufen sind: exakt benennen + Neu-Upload anfordern.
- **Step-only:** Änderungen nur über Step-Dateien unter _local\_scratch\*.ps1 und Run über 	ools\step-run-latest.ps1.
- **Parser/Preflight Pflicht:** Parse/Lint/Verify vor Ausführung.
- **Repo clean vor jedem Step.**
- **STOP heißt STOP:** nach 	hrow keine Folgeaktionen.
- **Keine relativen Pfade für File-IO (P0):** RepoRoot immer via Resolve-Path + Join-Path.
- **Join-Path in Array-Literalen immer in Klammern** (Parameterbinding-Edgecase).
- **VS Code code -g immer als String "FILE:LINE(:CHAR)"** übergeben (nie PathObject).
- **Keine Jutta-/medizinischen Keywords** in Public-Scans/Gates.
- Sprache: **Deutsch ohne Gendern**.

## 2) P0 Output/Chat Contract (gesetzlich, verbindlich)

### P0: FULLSWAP_PS1_NO_PARSER_TRAPS (hart)

- In FULLSWAP-PS1 (Steps/Tools) sind folgende Konstrukte **verboten** (Parser-Fehlerklasse):
  - Here-Strings: @\" ... \"@ und @' ... '@
  - Backtick-Newlines in String-Literalen: \"`n\" / \"`r\" / String-Ketten mit Backticks
  - Markdown-Fences im Report-Text: ```
- Stattdessen verpflichtend:
  - Strings nur mit **single quotes** + `-f` Format
  - Textaufbau über `@(...)` Zeilenarrays und `-join [Environment]::NewLine`
  - Reports als Plain-Text (keine Fences), Heartbeat als key=value


- **P0: FULLSWAP_ONLY_OUTPUT (ALL FORMATS)**  
  Wenn Inhalte für Dateien geliefert werden (ps1/md/txt/json/jsonl/tsv/csv), dann **immer als vollständiger FULLSWAP** (ganze Datei). Keine Teilblöcke, keine Fragmente.
- **P0: INPUT_FIRST_NO_CHAINING**  
  Wenn Input nötig ist, kommt **nur** der minimale Input-Command. Keine Folge-Schritte, bis Input da ist.
- **P0: OPEN_ONLY_IF_FULLSWAP_REQUIRED**  
  Dateien werden **nur** geöffnet, wenn ein **FULLSWAP** ausgeführt wird (Bearbeitung). Sonst nie.
- **P0: JSONL_IS_DATA_NOT_CODE**  
  JSON/JSONL wird **nie ausgeführt**, sondern **als Text** (UTF-8) geschrieben/angehängt.

## 3) SSOT Refresh / Brain Sync (immer am Chat-Anfang)

Runner:
- C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools\ssot-refresh-proxy.ps1

Erwartung:
- schreibt Brain_EGO_Dateien\latest\BOOTSTRAP_INTERNAL.md
- legt Snapshot unter Brain_EGO_Dateien\snapshots\YYYYMMDD_HHMMSS\BOOTSTRAP_INTERNAL.md an

## 4) Flow-Quality Gate (ReportOnly)

Runner:
- C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools\flow-quality-gate.ps1 -ReportOnly

Output (Repo):
- _local\flow_quality\run_YYYYMMDD_HHMMSS\flow_warns_v2.csv

<!-- EGO_LAW_FULLSWAP_TEXT_ALWAYS_FILEFIRST_BEGIN -->
## P0: FULLSWAP_TEXT_ALWAYS_FILEFIRST (hart)

- **Immer FULLSWAP**: kompletter Dateiinhalt, keine Patch-Snippets.
- **Immer file-first**: NEU/OPEN → FULLSWAP → RUN → POSTEN.
- **Diagnose-Kommandos immer regex-frei**: Select-String -SimpleMatch als Standard.
- **Allowlist in Steps matcher-kompatibel**: @('a','b') mit single quotes.
<!-- EGO_LAW_FULLSWAP_TEXT_ALWAYS_FILEFIRST_END -->

<!-- EGO_LAW_SELECTSTRING_SIMPLEMATCH_ONLY_BEGIN -->
## P0: SELECTSTRING_SIMPLEMATCH_ONLY (hart)

- Select-String -Pattern ist Regex und erzeugt bekannte Escape-Fehler (\\_, *, etc.).
- Deshalb gilt: Diagnose immer regex-frei:
  - Select-String -SimpleMatch -Pattern '...'
- Wenn Regex wirklich noetig: explizit dokumentieren und Regex.Escape() nutzen.
<!-- EGO_LAW_SELECTSTRING_SIMPLEMATCH_ONLY_END -->

<!-- EGO_LAW_NO_PASTE_CONCAT_STEP_RUN_BEGIN -->
## P0: NO_PASTE_CONCAT_STEP_RUN (hart)

- Verbot: $step oder $step.FullName direkt vor einem pwsh RUN in derselben Paste-Aktion.
- Standard: RUN ist immer ein eigener Einzeiler-Block.
- Optional: Tool tools/step-new-open.ps1 nutzen (NEU+OPEN ohne Echo-Falle).
<!-- EGO_LAW_NO_PASTE_CONCAT_STEP_RUN_END -->

<!-- EGO_LAW_PWSH_ARRAY_JOINPATH_AND_COUNT_GUARDS_BEGIN -->
## P0: PWSH_ARRAY_JOINPATH_AND_COUNT_GUARDS (hart)

- Join-Path in Array-Literalen immer klammern:
  - richtig: @((Join-Path $a 'x'), (Join-Path $a 'y'))
  - falsch:  @(Join-Path $a 'x', Join-Path $a 'y')  (Komma erzeugt Object[]).

- Count/Length nie auf Singleton-Pipeline ohne Array-Cast:
  - richtig: $hits = @(...); if(@($hits).Count -eq 0){...}
  - falsch:  $hits = ...; if($hits.Count -eq 0){...}  (bei 1 Treffer kein Array).
<!-- EGO_LAW_PWSH_ARRAY_JOINPATH_AND_COUNT_GUARDS_END -->

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
| gate-ps-parser-all-tools.ps1 | REPO_TOOLS | ADOPTED_ACTIVE | 1 | PS_GATE_TOOL | KEEP_VERIFIED_GATE | 7dd93ca4 |
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

## Führungsregel GPT / OpenAI – unumstößlich ab 2026-03-10

### Chefrolle
GPT / OpenAI ist die führende Arbeitsinstanz im Projekt EGO.

### Verbindlich
- GPT macht die Hauptarbeit.
- GPT trifft die Leitentscheidung, Priorisierung und Projektsteuerung.
- Andere KI-Modelle dürfen nur unterstützend eingesetzt werden.
- Der Einsatz anderer KI-Modelle erfolgt nur, wenn GPT dies im Sinne des Projekts ausdrücklich entscheidet.
- Keine andere KI erhält Führungsrolle, Hauptarbeitsrolle oder Endverantwortung.

### Operative Kurzform
GPT ist Chef. Andere KI nur als eng geführte Hilfsinstanzen unter GPT-Steuerung.

<!-- FULLSYNC_HARDLAW_V1_BOOTSTRAP -->

## FULLSYNC_HARDLAW_V1

- Nach jedem relevanten Fortschritt, Plan, Freeze, Build, Screenshot-Review oder Governance-Update ist ein vollständiger _INTERN-/Brain-Sync Pflicht.
- Pflichtziel ist nicht nur latest, sondern der vollständige relevante Stand in _INTERN, Brain_EGO_Dateien und den Repo-Mirrors.
- Repo-Mirror und kanonischer Außen-Stand dürfen nicht auseinanderlaufen.
- Der SSOT-Refresh-Proxy muss den Fullsync automatisch nachziehen.
- Ein Arbeitsschritt gilt ohne Fullsync nicht als sauber abgeschlossen.

## GLOBAL_EXECUTION_ORDER_AND_CONTEXT_BOOTSTRAP_LINK_2026-03-12

- Global gilt: SSOT-first und artefakt-first.
- Vor fachlicher Arbeit immer zuerst Required Reads Preflight passend zum TaskType.
- Der Runner-/Step-Entrypoint erzwingt diesen Preflight über `-RequiredReadsTaskType` vor dem eigentlichen Step-Body.
- Die verbindliche Required-Reads-Zuordnung läuft über `TASK_REQUIRED_READS_MATRIX.tsv` und den Resolver `knowledge-required-reads-preflight.ps1`.
- Gültige Runner-TaskTypes sind aktuell: Produkt-Loop, Claude-Prompting, Governance-Änderung, Brain-Intern-Struktur, Folgeprojekt-Klon und OpenAI-Regress-Governance.
- Ohne gültigen Required-Reads-Preflight kein fachlicher Step-Lauf.
- Danach strikt: SCAN -> PLAN -> APPLY -> VERIFY -> RUN -> REPORT.
- Repo clean vor Step, pwsh-only, Stop, StrictMode, UTF-8 no BOM.
- Repair -> Verify -> Commit/Push -> Closeout -> Resume.
- Kein neues Blatt vor echter Freigabe des aktuellen.

<!-- GLOBAL_EXECUTION_ORDER_AND_CONTEXT_BOOTSTRAP_LINK_2026-03-12 -->

## GLOBAL_FULLSWAP_REPO_CLEAN_ACTIVE_OBJECT_ANTI_DRIFT_BOOTSTRAP_LINK_2026-03-12

- Fullswap-only für Step-/Repo-/Governance-Fehler.
- Immer nur ein aktives Ziel gleichzeitig.
- Repo rot blockiert neue Facharbeit.
- Nach kaputtem Hygiene-Step gilt Restore -> Scan -> Apply.
- Antwortformat im Arbeitsmodus bleibt hart: Urteil -> Step -> minimale Rückgabe.

<!-- GLOBAL_FULLSWAP_REPO_CLEAN_ACTIVE_OBJECT_ANTI_DRIFT_BOOTSTRAP_LINK_2026-03-12 -->

## GLOBAL_ANTI_DRIFT_BOOTSTRAP_LINK_2026-03-12

- Globaler Anti-Drift-Arbeitsmodus ist aktiv.
- Nur aktives Thema/Blatt bearbeiten.
- Nur nächsten file-first Schritt liefern.
- Keine Meta-Erklärungen ohne Nachfrage.
- Re-Priorisierung nur an echten Gates.

<!-- GLOBAL_ANTI_DRIFT_BOOTSTRAP_LINK_2026-03-12 -->

## GLOBAL_OPERATIONS_SYNC_CLOSEOUT_REPO_BOOTSTRAP_LINK_2026-03-12

- Re-Priorisierung nur an echten Gates.
- Nach relevantem Fortschritt Pflicht-Sync von Brain und _INTERN.
- Nach sauberem Rundenabschluss Pflicht-Closeout.
- Commit/Push nur nach grünem Zustand und Repo-Hygiene.

<!-- GLOBAL_OPERATIONS_SYNC_CLOSEOUT_REPO_BOOTSTRAP_LINK_2026-03-12 -->

## GLOBAL_FULLSYNC_AUTOPURGE_REPO_CLEAN_BOOTSTRAP_LINK_2026-03-12

- Fullsync-Schritte sind erst grün nach Auto-Purge der untracked Mirror-Grenze.
- Repo-clean muss nach Governance-/Proxy-Work wiederhergestellt sein, bevor operative Arbeit weitergeht.

<!-- GLOBAL_FULLSYNC_AUTOPURGE_REPO_CLEAN_BOOTSTRAP_LINK_2026-03-12 -->

## GLOBAL_POST_CLOSEOUT_NEW_CHAT_AND_FOLLOWUP_STARTTEXT_BOOTSTRAP_LINK_2026-03-12

- Nach jedem Closeout ist ein neuer sauberer Folgechat Pflicht.
- Der Closeout muss einen vollständigen Folge-Starttext für den nächsten Chat ausgeben.
- Im Folgechat sind Brain, _INTERN, Projekte und relevante Gesprächsgrundlage vollständig einzulesen.

<!-- GLOBAL_POST_CLOSEOUT_NEW_CHAT_AND_FOLLOWUP_STARTTEXT_BOOTSTRAP_LINK_2026-03-12 -->

## HARDLAW 2026-03-12 - TRUTH RECONCILIATION AND ANTI LOOP

- Vor jedem fachlichen Schritt sind Starttext, letzte Screenshot-Abnahme, letzter echte Build, letzter SSOT-Report und aktuelle Hardlaws gegenzuprufen. Kein Wahrheitsträger darf blind dominieren.
- Bei Produktblättern mit sichtbarer Kompositionsstörung gilt: kein Mikropatch-Modus. Nur Hard-Reset oder Fullswap-basierter Architekturzugriff.
- Screenshot-Wirkung ist gleichrangig mit technischem Grünlauf. Build PASS ohne Käuferwirkung ist kein Fortschritt.
- OPEN ist kein Fortschritt. RUN erst nach Existenzprüfung des Step-Pfads, klarem Owner-Nachweis und festem Scope.
- Kein APPLY auf vermuteten Altzustand. Vor jedem Apply gilt Real-Scan direkt davor oder echter Fullswap.
- Kein nächster Produktloop ohne Wissenssync in Brain und _INTERN.
- Externe Modelle sind nur Nebeninstanzen unter GPT-Führung: Claude für visuelle Kritik, DeepSeek für Gegenprüfung von Logik/Gates, Grok optional für Ideen. Keine dieser Instanzen ist Haupt-Owner von SSOT, Governance oder Workbook-Umsetzung.
<!-- EGO_OWNER_CHAIN_AND_EXTERNAL_MODEL_BOUNDARY_2026_03_13_START -->
## P0: OWNER_CHAIN_AND_EXTERNAL_MODEL_BOUNDARY (hart)

- Bei deterministischen Owner-/Build-Defekten zuerst echte Owner-Kette in Datei, Builder und Runner real scannen.
- Kein Downstream-Blindfix in JAHR, wenn PARAMETER, Listenquelle oder Dispatch der echte Owner ist.
- Keine Delegation an Claude, DeepSeek oder Grok fuer Builder-/Runner-Owner-Fixes.
- Externe Modelle duerfen hier nur schriftliche Kritik, Gegenpruefung oder Scope-Hinweise liefern.
- Umsetzung, Verify, Reports und Governance-Sync bleiben in der lokalen Coding-Pipeline unter GPT-Fuehrung.
<!-- EGO_OWNER_CHAIN_AND_EXTERNAL_MODEL_BOUNDARY_2026_03_13_END -->
<!-- EGO_EXTERNAL_MODEL_TRIAD_EVIDENCE_BASED_2026_03_13_START -->
## P0: EXTERNAL_MODEL_TRIAD_EVIDENCE_BASED

- Claude, DeepSeek und Grok werden als separate Steuerobjekte geführt.
- Allgemeine Grenzen für externe Modelle bleiben in Bootstrap / SSOT / Learnings verankert.
- Modellspezifische Muster werden nur aus realen Gesprächsverläufen, Tests oder Artefakten übernommen.
- Ohne belastbare Evidenz keine erfundenen Modellannahmen eintragen.
- GPT / OpenAI bleibt Führungsinstanz; andere Modelle nur als eng geführte Hilfsinstanzen.
<!-- EGO_EXTERNAL_MODEL_TRIAD_EVIDENCE_BASED_2026_03_13_END -->
<!-- EGO_COMPACT_WORKBOOK_ALIAS_BEFORE_CHAINED_BUILDS_2026_03_13_START -->
## P0: COMPACT_WORKBOOK_ALIAS_BEFORE_CHAINED_BUILDS

- Vor verketteten Workbook-Builds nie mit langen, bereits veredelten Output-Namen weiterbauen.
- Stattdessen zuerst eine kurze Arbeitskopie im Outputs-Ordner erzeugen.
- Mehrstufige Builds wie LIZENZ -> NOTGROSCHEN müssen auf kompakte Zwischenbasen laufen, damit Windows-Dateinamen- und Pfadgrenzen nicht reißen.
<!-- EGO_COMPACT_WORKBOOK_ALIAS_BEFORE_CHAINED_BUILDS_2026_03_13_END -->
<!-- EGO_CLOSEOUT_OVERLOADED_CHAT_AND_REAL_OUTPUT_TRUTH_2026_03_13_START -->
## P0: OVERLOADED_CHAT_CLOSEOUT_AND_REAL_OUTPUT_TRUTH

- Wenn ein Chat überladen ist, erst hygienisches Closeout mit Starttext für den Folgechat statt weiterem Drift.
- Reale Output-Wahrheit immer am Dateisystem prüfen, nicht an behaupteten OUTPUT-Zeilen allein.
- Pipeline-Ergebnisse aus PowerShell immer mit `@(...)` array-sicher sammeln, wenn danach `.Count` oder Indexzugriffe gebraucht werden.
<!-- EGO_CLOSEOUT_OVERLOADED_CHAT_AND_REAL_OUTPUT_TRUTH_2026_03_13_END -->
<!-- BEGIN:HARDSYNC_2026_03_14_NON_EXCEL_EXECUTION -->
## HARDLAW 2026-03-14 - NON-EXCEL EXECUTION HARDENING

- Excel bleibt gestoppt, bis die Nicht-Excel-Baustellen sauber behoben und synchronisiert sind.
- Kein RUN ohne echte Path-Existence-Prüfung.
- $step nie als stille Dauerbasis voraussetzen.
- gemeldete OUTPUT:-Zeilen nie blind glauben.
- START sheet-only PDF export contract ist als technischer Exportvertrag separat zu behandeln und nicht mit Workbook-wide-Export zu vermischen.
- LibreOffice-Aufrufe fuer diesen Exportpfad muessen sauber auf soffice.com und ein isoliertes LibreOffice-Profil ausgerichtet werden, wenn LibreOffice im Owner-Pfad verwendet wird.
<!-- END:HARDSYNC_2026_03_14_NON_EXCEL_EXECUTION -->
<!-- BEGIN:IMMEDIATE_FAILURE_SYNC_SEPARATE_ENTRY_2026_03_14 -->
## HARDLAW 2026-03-14 - IMMEDIATE FAILURE SYNC SEPARATE ENTRY

- Diese Regel ist ein eigener separater Eintrag und nicht nur ein Chat-Hinweis.
- Sobald neue Fehler, Failure-Muster oder Prozessabweichungen auftreten, muessen sie unverzueglich und uebergreifend in _INTERN, Brain, Bootstrap/SSOT, Learnings, QA, Governance und relevante Steuerdateien synchronisiert werden.
- Keine Verzoegerung bis zu einem spaeteren Sammelschritt.
- Nicht nur Chat-Memory zaehlt; Projektdateien muessen sofort auf Wahrheitstand gebracht werden.
<!-- END:IMMEDIATE_FAILURE_SYNC_SEPARATE_ENTRY_2026_03_14 -->
<!-- BEGIN:SPECIFIC_FAILURE_STEP_RUN_EMPTY_STEP_INVOCATION_2026_03_14 -->
## HARDLAW 2026-03-14 - SPECIFIC FAILURE STEP-RUN EMPTY STEP INVOCATION

- Dieser Failure-Mode ist ein eigener separater Eintrag.
- Ein step-run-Aufruf mit leerem, verlorenem oder nicht aufgeloestem $step ist FAIL.
- Wenn $step nicht real belegt ist, step-run nicht mit -StepPath aufrufen.
- In diesem Fall nur mit explizitem -Pattern oder nach real verifiziertem Literalpfad arbeiten.
<!-- END:SPECIFIC_FAILURE_STEP_RUN_EMPTY_STEP_INVOCATION_2026_03_14 -->
<!-- BEGIN:SPECIFIC_FAILURE_REGEX_UNESCAPE_WORKFLOW_BINDING_2026_03_14 -->
## HARDLAW 2026-03-14 - SPECIFIC FAILURE REGEX UNESCAPE WORKFLOW BINDING

- FAIL ist FAIL und muss sofort als eigener Eintrag aufgenommen werden.
- Der Failure WORKFLOW_BINDING_STEP_FAILED_ON_REGEX_UNESCAPE ist als echter Prozessfehler verankert.
- Keine Anwendung von [regex]::Unescape() auf kompletten Scripttexten fuer Step- oder Tool-Fullswaps.
<!-- END:SPECIFIC_FAILURE_REGEX_UNESCAPE_WORKFLOW_BINDING_2026_03_14 -->
<!-- BEGIN:SPECIFIC_FAILURE_CLOSEOUT_BLOCKERS_PYCACHE_AND_AUTO_SYNC_PATH_BUG_2026_03_14 -->
## HARDLAW 2026-03-14 - SPECIFIC CLOSEOUT BLOCKERS

- FAIL remains FAIL; even pure workflow or invocation failures are real failures.
- Closeout must not fake repo-clean; `tools\__pycache__` is a real blocker while it appears in git status.
- If automatic failure intake fails itself, that is a separate P0 workflow defect and must be synced immediately.
<!-- END:SPECIFIC_FAILURE_CLOSEOUT_BLOCKERS_PYCACHE_AND_AUTO_SYNC_PATH_BUG_2026_03_14 -->

<!-- BEGIN:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->
## HARDLAW 2026-03-14 - AUTO FAILURE PATH NORMALIZATION

- Auto-Failure-Intake darf niemals .Path auf beliebigen Objekten, Matches, Hashtables oder Strings voraussetzen.
- Optionale Pfadangaben muessen zuerst zu sicheren Stringwerten normalisiert werden.
- Failure-Sync bleibt best effort und darf den urspruenglichen Runner-Fehler nicht durch einen zweiten Tool-Fehler verdecken.
- Spezifischer Fehlerfall 2026-03-14: AUTO_FAILURE_SYNC_FAIL mit "The property 'Path' cannot be found on this object."
<!-- END:AUTO_FAILURE_PATH_NORMALIZATION_2026_03_14 -->

<!-- EGO_FILEFIRST_STANDARD_START -->
## P0 FILE-FIRST FULLSWAP DELIVERY STANDARD

Projektuebergreifend immer:

1. Datei
2. Fullswap
3. Oeffnen
4. Ausfuehren

Keine Konsolexperimente vor der Datei.
Keine Partial-Patches.
Keine halben Patches.
Keine Seitenspruenge.
<!-- EGO_FILEFIRST_STANDARD_END -->

<!-- EGO_FILEFIRST_STANDARD_START -->
## P0 FILE-FIRST FULLSWAP DELIVERY STANDARD

Projektuebergreifend immer:

1. Datei
2. Fullswap
3. Oeffnen
4. Ausfuehren

Keine Konsolexperimente vor der Datei.
Keine Partial-Patches.
Keine halben Patches.
Keine Seitenspruenge.
<!-- EGO_FILEFIRST_STANDARD_END -->

<!-- EGO_FILEFIRST_STANDARD_START -->
## P0 FILE-FIRST FULLSWAP DELIVERY STANDARD

Projektuebergreifend immer:

1. Datei
2. Fullswap
3. Oeffnen
4. Ausfuehren

Keine Konsolexperimente vor der Datei.
Keine Partial-Patches.
Keine halben Patches.
Keine Seitenspruenge.
<!-- EGO_FILEFIRST_STANDARD_END -->

<!-- EGO_FILEFIRST_STANDARD_START -->
## P0 FILE-FIRST FULLSWAP DELIVERY STANDARD

Projektuebergreifend immer:

1. Datei
2. Fullswap
3. Oeffnen
4. Ausfuehren

Keine Konsolexperimente vor der Datei.
Keine Partial-Patches.
Keine halben Patches.
Keine Seitenspruenge.
<!-- EGO_FILEFIRST_STANDARD_END -->

<!-- EGO_FILEFIRST_STANDARD_START -->
## P0 FILE-FIRST FULLSWAP DELIVERY STANDARD

Projektuebergreifend immer:

1. Datei
2. Fullswap
3. Oeffnen
4. Ausfuehren

Keine Konsolexperimente vor der Datei.
Keine Partial-Patches.
Keine halben Patches.
Keine Seitenspruenge.
<!-- EGO_FILEFIRST_STANDARD_END -->

<!-- EGO_FILEFIRST_STANDARD_START -->
## P0 FILE-FIRST FULLSWAP DELIVERY STANDARD

Projektuebergreifend immer:

1. Datei
2. Fullswap
3. Oeffnen
4. Ausfuehren

Keine Konsolexperimente vor der Datei.
Keine Partial-Patches.
Keine halben Patches.
Keine Seitenspruenge.
<!-- EGO_FILEFIRST_STANDARD_END -->

<!-- EGO_MANAGED_BLOCK:STEP_VARIABLE_GUARANTEE_BEFORE_CORRECTION_20260316_220030:START -->
## STEP VARIABLE GUARANTEE BEFORE CORRECTION - 20260316_220030

- Failure-Muster: OPEN-/RUN-Bloecke duerfen $step nie aus dem Session-Restzustand voraussetzen.
- Die Fehler stehen vor der Korrektur und muessen deshalb zuerst sofort projektweit verankert werden.
- Reale Symptome aus diesem Strang:
  - `code -g ("{0}:1" -f $step)` scheitert, wenn $step leer/verloren ist.
  - `step-run.ps1 -StepPath $step` scheitert, wenn $step leer/verloren ist.
- Harte Reihenfolge ab sofort:
  1. Fehler/Finding/Failure-Muster sofort in Bootstrap, Governance, Learnings, QA, TODO und Brain aufnehmen.
  2. Erst danach fachliche oder technische Korrektur fortsetzen.
- Harte Ausfuehrungsregel:
  - $step muss unmittelbar vor OPEN/RUN im selben One-Shot-Block hart gesetzt werden.
  - Alternativ exakten Literalpfad direkt verwenden.
  - Session-Restzustand zaehlt nie als Vertrag.
- Quellen:
  - Emit-Report: EMIT_PARSER_LINT_RESOLVED_OWNER_CONTRACT_AND_MISSING_TARGETS
  - Konkrete Konsolenfehler wurden vor der Korrektur beobachtet und sind Teil dieses Failure-Musters.
<!-- EGO_MANAGED_BLOCK:STEP_VARIABLE_GUARANTEE_BEFORE_CORRECTION_20260316_220030:END -->

<!-- EGO_MANAGED_BLOCK:STALE_STEP_PATH_CAN_PASS_FALSE_SUCCESS_20260316_221937:START -->
## STALE STEP PATH CAN PASS FALSE SUCCESS - 20260316_221937

- Neuer Failure-Befund: Ein aelterer gleichnamiger Step-Pfad kann technisch gruen laufen und dadurch einen stillen Falscherfolg erzeugen.
- Konkrete Beobachtung aus diesem Strang:
  - frisch erzeugter Step: $ObservedFreshStepPath
  - stattdessen verwendeter Alt-Step: $ObservedStaleStepPath
  - technisches Signal: $ObservedPassSignal
- Harte Bedeutung:
  1. Ein PASS auf einem aelteren gleichnamigen Step-Pfad ist nicht automatisch gueltig.
  2. Nach step-new.ps1 muss nicht nur "step exists", sondern der exakt frisch erzeugte $step-Pfad aus derselben Ausgabe belegt werden.
  3. Jede Abweichung zwischen frisch erzeugtem Pfad und gelaufenem Pfad ist auch bei PASS ein Sofort-Sync-Fehler vor weiterer Korrektur.
- Erweiterung der bereits bindenden Regeln:
  - STEP_VARIABLE_GUARANTEE_BEFORE_CORRECTION
  - NO_PLACEHOLDER_STEP_PATH_IN_RUN_BLOCKS
  - FRESH_STEP_PATH_ONLY_AFTER_STEP_NEW
<!-- EGO_MANAGED_BLOCK:STALE_STEP_PATH_CAN_PASS_FALSE_SUCCESS_20260316_221937:END -->

<!-- EGO_MANAGED_BLOCK:STALE_MISSING_STEP_PATH_AFTER_STEP_NEW_20260316_222439:START -->
## STALE MISSING STEP PATH AFTER STEP NEW - 20260316_222439

- Neuer Failure-Befund: Nach step-new.ps1 wurde ein aelterer gleichnamiger Step-Pfad verwendet, der nicht mehr existierte.
- Konkrete Beobachtung aus diesem Strang:
  - frisch erzeugter Step: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\p1_apply_parser_lint_runtime_first_targets_from_resolved_scope_20260316_222347.ps1
  - falsch verwendeter Alt-Step: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\p1_apply_parser_lint_runtime_first_targets_from_resolved_scope_20260316_222029.ps1
  - technischer Fehler: FAIL: step not found: stale step path after fresh step-new output
  - Vorbedingung bereits erfuellt: AUTO_SYNC_STEP_RUN_FAILURE already emitted before further correction
- Harte Regel ab sofort:
  1. Nach step-new.ps1 fuer OPEN und RUN nur den exakt frisch erzeugten Pfad aus derselben Ausgabe verwenden.
  2. Kein Rueckfall auf aeltere gleichnamige Timestamp-Pfade – auch dann nicht, wenn sie aehnlich aussehen.
  3. Wenn der frische Pfad nicht exakt belegt ist, nicht raten und keinen Altpfad einsetzen.
  4. Jede Abweichung zwischen frisch erzeugtem Pfad und RUN-Pfad ist vor weiterer Korrektur ein Sofort-Sync-Fall.
- Beziehung zu bestehenden Regeln:
  - STEP_VARIABLE_GUARANTEE_BEFORE_CORRECTION
  - NO_PLACEHOLDER_STEP_PATH_IN_RUN_BLOCKS
  - FRESH_STEP_PATH_ONLY_AFTER_STEP_NEW
  - STALE_STEP_PATH_CAN_PASS_FALSE_SUCCESS
<!-- EGO_MANAGED_BLOCK:STALE_MISSING_STEP_PATH_AFTER_STEP_NEW_20260316_222439:END -->

<!-- EGO_MANAGED_BLOCK:KNOWN_FAILURE_PREVENTION_STANDARD_20260316_231411:START -->
## KNOWN FAILURE PREVENTION STANDARD - 20260316_231411

- Fuer alle bereits bekannten Fehler-, Failure- und Prozessmuster reicht Dokumentation nicht aus.
- Bekannte Fehler muessen aktiv praeventiv verhindert werden.
- Erst unbekannte/neue Fehlerklassen laufen ueber den Sofort-Sync-vor-Korrektur-Prozess.

### Harte Praeventionsregeln
1. Ein neu erzeugter Step darf niemals vor gesichertem Fullswap / inhaltlichem Verify gelaufen werden.
2. Nach `step-new.ps1` duerfen OPEN/RUN nur den exakt frisch erzeugten `$step`-Pfad aus derselben Ausgabe verwenden.
3. Keine Platzhalter, keine alten gleichnamigen Timestamp-Pfade, keine abgeleiteten Step-Pfade.
4. Ein PASS auf einem falschen oder alten Step-Pfad gilt nicht als fachlich gueltig.
5. Bekannte False-Fail-Scopes muessen aktiv aus relevanten Gates ausgeschlossen werden.
6. Der Fehler `FAIL: step missing $EGO_STEP_WRITE_ALLOWLIST = @(...).` ist ein bekannter Praeventionsfehler derselben Klasse und darf nicht erneut durch RUN vor gesichertem Fullswap auftreten.

### Arbeitsreihenfolge
- bekannte Fehlerklasse: aktiv verhindern
- neue/unbekannte Fehlerklasse: sofort aufnehmen, syncen, dann korrigieren
<!-- EGO_MANAGED_BLOCK:KNOWN_FAILURE_PREVENTION_STANDARD_20260316_231411:END -->

<!-- EGO_MANAGED_BLOCK:ZERO_HIT_SCAN_MUST_NOT_FAIL_20260316_232254:START -->
## ZERO HIT SCAN MUST NOT FAIL - 20260316_232254

- Bekannte Praeventionsklasse: Leere Scan-/Evidenz-Ergebnisse duerfen nie als Prozessabbruch enden.
- Ein Scan mit 0 Treffern ist ein fachlicher Befund, kein technischer FAIL.
- Fehlerbild dieses Strangs:
  - `FAIL: NO_PARSER_ERROR_LINES_FOUND`
- Harte Praeventionsregel:
  1. Scan-/Evidence-Steps muessen bei 0 Treffern Report + JSON mit Count=0 schreiben.
  2. 0 Treffer duerfen nur dann FAILen, wenn der Vertrag explizit "mindestens 1 Treffer zwingend" fordert und dieser Vertrag zuvor real belegt wurde.
  3. Standardfall fuer Scan-/Evidence-/Verify-Steps: 0 Treffer = PASS mit Befund.
<!-- EGO_MANAGED_BLOCK:ZERO_HIT_SCAN_MUST_NOT_FAIL_20260316_232254:END -->

## SYNC_EVENT_20260317_RECURRING_PDF_BACKEND_FAILURES_AND_CHAT_REPO_DRIFT

- P0 Erinnerung: Jeder neue Fehler, jeder Misserfolg und jeder wiederkehrende Failure-Pattern-Befund muss vor jeder Korrektur sofort in alle Pflichtziele synchronisiert werden.
- Produktuebergreifende Pflicht: Bekannte Freebie-/PRO-/Vollversions-Fehler gelten sofort fuer alle Tiers.
- Backend-Annahmen fuer Doc/PDF nie mehr implizit; Verfuegbarkeit ist Gate, kein Nachgedanke.

## SYNC_EVENT_20260317_POSTSYNC_ARRAY_BINDING_PDF_FAILURES_AND_NOREPEAT_ENFORCEMENT

- P0: Nach jedem neuen FAIL/STOP/AUTO_SYNC_STEP_RUN_FAILURE sofort syncen, bevor irgendein weiterer Fix-Step ausgegeben oder gelaufen wird.
- P0: Wiederholte Fehler im selben Strang loesen zusaetzlich Cluster-Review aus.
- P0: Failure-Patterns gelten sofort fuer alle Produktstufen.

<!-- EGO_BLOCK:FAILURE_SYNC_20260318:START -->
## Failure-Sync 2026-03-18 - Step-Autorings
 
- Vor weiterer Arbeit im Strang `sitemap-page-content-product-alignment-before-paid-activation` sind die neuen Step-Fehlerklassen kanonisch synchronisiert.
- Folge-Thema nach diesem Sync bleibt: `repo-clean-delta-before-sitemap-product-alignment`.
- Referenzdatei: `STEP_FAILURE_PATTERNS_INTERNAL.md`.
<!-- EGO_BLOCK:FAILURE_SYNC_20260318:END -->

<!-- EGO_PROJECTWIDE_FACTSCAN_INVARIANT_V1:START -->
## P0-Invariante: Reale Pfadbasis vor jedem Apply

- Projektuebergreifend gilt ab jetzt als harte Invariante:
  - Vor jedem Apply-Schritt, Pfadbezug oder Befehl mit Strukturannahmen immer zuerst Faktenscan/Real-Scan auf den echten Bestand.
  - Keine Root-Ableitung, keine Parent-Vermutung, keine Namensraten.
  - Erst auf Basis des Real-Scans duerfen exakte Zielpfade fuer Apply, Verify und Run verwendet werden.
- Fuer diesen Fix ist die reale Pfadbasis bewiesen:
  - Canonical Project Root: `C:\Users\carst\Projekte\Einfach-Geld-Ordnen`
  - Canonical Governance Root: `C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance`
  - Canonical Brain Root: `C:\Users\carst\Projekte\Einfach-Geld-Ordnen\Brain_EGO_Dateien`
  - Repo Mirror Root: `C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen`
<!-- EGO_PROJECTWIDE_FACTSCAN_INVARIANT_V1:END -->

<!-- EGO_PROJECTWIDE_RUNPATH_INVARIANT_V1:START -->
## P0-Invariante: Nie wieder RUN mit nacktem `$step`

- Projektuebergreifend gilt ab jetzt als harte Invariante:
  - Nie wieder RUN-Bloecke mit nacktem `$step`.
  - Erlaubt sind nur:
    - exakter harter Step-Pfad
    - `pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\step-run.ps1 -Pattern "..." ...`
- Jeder neue Step-/Run-Vorschlag muss diese Invariante einhalten.
- Leeres, verlorenes oder nicht gesetztes `$step` gilt als bekannter Praeventionsfehler und darf nicht mehr als Grundlage fuer RUN-Kommandos verwendet werden.
<!-- EGO_PROJECTWIDE_RUNPATH_INVARIANT_V1:END -->

<!-- EGO_PROJECTWIDE_FULLTEXTSWAP_ONLY_NO_FRAGMENT_REPLACEMENT_V1_BEGIN -->
## P0: FULLTEXTSWAP_ONLY_NO_FRAGMENT_REPLACEMENT (hart)

- Projektweit werden Dateiaenderungen nur noch als FULLTEXTSWAP des kompletten Dateiinhalt ausgefuehrt.
- Keine Textfragmente, keine Teilblock-Ersetzungen, keine Zeilenpatches, keine Snippet-Fixes, keine "ersetze nur diese 2 Zeilen"-Anweisungen.
- File-first bleibt zwingend: OPEN -> FULLSWAP -> VERIFY -> RUN -> REPORT.
- Vor jedem Apply-, Pfad- oder Strukturbezug bleibt echter Real-/Faktenscan Pflicht.
- Diese Invariante gilt bindend fuer Bootstrap, Governance, SSOT, QA, Learnings, TODO, Brain und alle Folge-Tasks projektweit.
- Der zulaessige Bearbeitungsmodus fuer Dateien ist ab jetzt ausschliesslich kompletter Dateiinhalt per FULLSWAP.
<!-- EGO_PROJECTWIDE_FULLTEXTSWAP_ONLY_NO_FRAGMENT_REPLACEMENT_V1_END -->

<!-- VOLLVERSION_MASTER_BOOTSTRAP_V1 START -->
- VOLLVERSION-Master-Strategie ist jetzt bindend.
- Ableitungsrichtung: erst VOLLVERSION als Master-Endprodukt, danach PRO, danach FREEBIE.
- Screenshot-Abnahme bleibt fuehrend; sichtbare Produktwirkung geht vor interner Tabellenordnung.
- Support-/Hilfsblaetter gelten als Produktblaetter und muessen wie sichtbare Endproduktseiten wirken.
- Aktives Thema nach diesem Sync: enterprise-vollversion-master-shell-and-downward-tier-derivation
- Vor Paid-Aktivierung muessen VOLLVERSION-Master, danach PRO und FREEBIE, plus README/PDF/Bundle, Screenshot-Evidenz, Kaeufer-Abnahme und DoD je Tier gruen sein.
<!-- VOLLVERSION_MASTER_BOOTSTRAP_V1 END -->

<!-- EGO_MANAGED_BLOCK:START_PREMIUM_DASHBOARD_REBUILD_LOCK_20260321:START -->
## START PREMIUM DASHBOARD REBUILD LOCK - 2026-03-21

- Aktiver Workbook-Fachstrang ist ab jetzt ausschliesslich: VOLLVERSION-Master / START / full visible surface premium dashboard rebuild.
- Vor jedem neuen START-Apply dieses Strangs gilt zwingend: 1) Screenshot-Review, 2) Gespraechs-/SSOT-Review, 3) externe Modell- und Markt-Synthese, 4) Sofort-Sync in _INTERN und Brain, 5) erst dann file-first Rebuild-Step.
- START darf ab diesem Punkt nicht mehr ueber Mikro-Fixes, isolierte Geometrie-Patches oder lokale Kosmetik weiterentwickelt werden; es braucht jeweils eine klar komponierte Dashboard-Architektur.
- PARAMETER und BEDIENUNG bleiben Freeze-Blaetter, solange der aktuelle START-Rebuild offen ist.
- Screenshot-Kaeuferwirkung ist fuer diesen Strang hoeher gewichtet als Teil-PASS, Geometrie-Verbesserung oder subjektive Zwischenberuhigung.
<!-- EGO_MANAGED_BLOCK:START_PREMIUM_DASHBOARD_REBUILD_LOCK_20260321:END -->

<!-- EGO_MANAGED_BLOCK:WORKBOOK_CANONICAL_SOURCE_LOCK_20260322:START -->
## WORKBOOK CANONICAL SOURCE LOCK - 2026-03-29

- verified-stage workbook path = C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- verified-stage workbook sha256 = D73DCBC29C128380381D74957527B34036953892964D2B44641D8902D56C6C41
- Fuer Workbook-Apply/Verify/Run gilt ab jetzt hart: verified-stage = einzige Arbeitsquelle.
- bundle_spreadsheet_candidates_* ist staging-only und darf fuer keinen Workbook-Step mehr als Arbeitsquelle verwendet werden.
- Produkt_EGO Bundle-Payload ist nur dann kanonische Lieferkopie, wenn Hash = verified-stage.
- _INTERN\private_sources\release_candidates\bundle_release_zips_* hat keinen Wahrheitsbonus mehr; Nutzung nur nach positivem Manifest-/Hash-Beweis.
- Jeder mutierende Workbook-Step muss vor dem ersten Copy/Backup einen Expected-SHA-256-Guard gegen die kanonische verified-stage-Datei setzen.
- Aktiver Workbook-Strang: breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only ausserhalb aller bereits gruener geschlossenen Themen.
- Bindender Hotspot-Entscheid bleibt: NO_WORKBOOKWIDE_CACHED_VALUE_APPLY.
- Gruen geschlossen bleiben: MONAT, PLANUNG, JAHR, BUDGETS, FIXKOSTEN, NOTGROSCHEN, SCHULDEN, MONATSABSCHLUSS, STEUER, SPARZIELE und START.
- Der letzte START-Leaf START_ROWS_23_23 ist entschieden, realisiert und verified.
- Naechster exakter Workbook-Gate-Schritt ist ausschliesslich: WORKBOOKWIDE_REPRIORITIZE_AFTER_START_CLOSEOUT.
- Produkt_EGO VOLLVERSION XLSX bleibt separater spaeterer drifted-delivery-copy Rebuild-/Restage-Strang.
<!-- EGO_MANAGED_BLOCK:WORKBOOK_CANONICAL_SOURCE_LOCK_20260322:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_SCOPE_GATE_20260322:START -->
## ACTIVE_SCOPE_GATE - 2026-03-29

Vor jedem relevanten APPLY/RUN gilt zwingend:

1. ACTIVE_SCOPE_LOCK_INTERNAL.md lesen.
2. ACTIVE_SCOPE_RESUME_INTERNAL.md lesen.
3. exact_workbook_path, workbook_sha256, decision, forbidden_side_tracks und immediate_next_exact_gate gegen den geplanten Schritt pruefen.
4. Wenn Closeout, Followup-Starttext oder Decision-Report einen neuen bindenden Fachentscheid setzen, muss derselbe Lauf ACTIVE_SCOPE_LOCK_INTERNAL.md, ACTIVE_SCOPE_RESUME_INTERNAL.md und diesen Bootstrap-Stand mit denselben Entscheidungsankern fortschreiben.
5. Pflichtanker fuer den aktuellen Strang sind exakt: WORKBOOKWIDE_REPRIORITIZE_AFTER_START_CLOSEOUT, C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx, D73DCBC29C128380381D74957527B34036953892964D2B44641D8902D56C6C41, START_CLOSEOUT_SYNC, START_CHAIN_CLOSED, MANIFEST_VERIFIED_STAGE_SYNC.
6. Gruen geschlossene Themen duerfen nicht ohne neuen Realbefund wieder geoeffnet werden: MONAT, PLANUNG, JAHR, BUDGETS, FIXKOSTEN, NOTGROSCHEN, SCHULDEN, MONATSABSCHLUSS, STEUER, SPARZIELE und START.
7. Bei Abweichung oder fehlendem Writeback hart STOP.
8. Kein Rueckfall auf fruehere Zwischenstaende oder auf candidate-, bundle- oder delivery-copy-Quellen als Arbeitsquelle.
<!-- EGO_MANAGED_BLOCK:ACTIVE_SCOPE_GATE_20260322:END -->

<!-- EGO:MONAT_ROWS_13_20_PACKAGE_DIRECT_READY START -->
## MONAT rows 13:20 package direct-ready
- scope: MONAT|ROWS_13_20|PACKAGE_A_L|DIRECT_APPLY_READY
- workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- status: PASS
- merge_ab_ready: PASS
- formula_cf_ready: PASS
- static_gl_ready: PASS
- rows_13_20_package_ready: PASS
- formula_family_consolidation_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_SCAN_MONAT_ROWS_13_20_FORMULA_FAMILY_DIRECT_READY_CONSOLIDATION_20260326_130353.md
- package_readiness_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_SCAN_MONAT_ROWS_13_20_PACKAGE_APPLY_READINESS_A_L_20260326_131235.md
- note: Rows 13:20 A:L sind kanonisch als direct-apply-ready festgeschrieben. Kein weiterer Rescan derselben Package-Zeilen vor echtem Apply-Gate.
<!-- EGO:MONAT_ROWS_13_20_PACKAGE_DIRECT_READY END -->

<!-- EGO:MONAT_ROWS_13_20_APPLY_MODEL_LOCK START -->
## MONAT rows 13:20 apply model lock
- scope: MONAT|ROWS_13_20|PACKAGE_A_L|APPLY_MODEL_LOCKED
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_13_20_SOURCE_PAYLOAD_CONTRACT_20260326_135426.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_13_20_SOURCE_PAYLOAD_CONTRACT_20260326_135426.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- source_workbook_role: CANONICAL_WORKING_SOURCE
- apply_execution_model: VERIFIED_STAGE_ONLY
- staging_candidate_usage: FORBIDDEN_FOR_APPLY_RUN
- product_bundle_xlsx_usage: REBUILD_REPLACE_LATER_NOT_DIRECT_APPLY
- status: PASS
- note: Der emittierte Source-Payload-Contract ist gruen. Direkter Apply auf staging candidate oder drifted delivery copy ist verboten. Naechster echte Fachschritt ist ein exact verified-stage apply/build step auf Basis des emittierten Contracts; danach erst rebuild/restage fuer delivery copies.
<!-- EGO:MONAT_ROWS_13_20_APPLY_MODEL_LOCK END -->

<!-- EGO:MONAT_ROWS_13_20_APPLY_TARGET_LOCK START -->
## MONAT rows 13:20 verified-stage apply target lock
- scope: MONAT|ROWS_13_20|PACKAGE_A_L|VERIFIED_STAGE_APPLY_TARGET_LOCKED
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_13_20_SOURCE_PAYLOAD_CONTRACT_20260326_135426.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_13_20_SOURCE_PAYLOAD_CONTRACT_20260326_135426.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- target_workbook_output_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\outputs\EGO_VOLLVERSION_MONAT_ROWS_13_20_VERIFIED_STAGE_APPLY_20260326_131818.xlsx
- target_apply_report_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_13_20_VERIFIED_STAGE_TARGET_LOCK_20260326_131818.md
- apply_execution_model: CLONE_VERIFIED_STAGE_TO_TARGET_THEN_APPLY_CONTRACT
- source_workbook_inplace_edit: FORBIDDEN
- status: PASS
- note: Naechster echte Fachschritt ist ein exact deterministic apply/build step, der das verified-stage workbook nur in eine neue target output path klont und dort den emittierten rows-13-20-contract anwendet. Das Source-Workbook bleibt unveraendert.
<!-- EGO:MONAT_ROWS_13_20_APPLY_TARGET_LOCK END -->

<!-- EGO:MONAT_ROWS_13_20_VERIFIED_STAGE_DETERMINISTIC_REALIZATION START -->
## MONAT rows 13:20 verified-stage deterministic realization
- scope: MONAT|ROWS_13_20|PACKAGE_A_L|VERIFIED_STAGE_DETERMINISTIC_REALIZATION_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_13_20_SOURCE_PAYLOAD_CONTRACT_20260326_135426.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_13_20_SOURCE_PAYLOAD_CONTRACT_20260326_135426.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- target_lock_report_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_13_20_VERIFIED_STAGE_TARGET_LOCK_20260326_131818.md
- target_workbook_output_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\outputs\EGO_VOLLVERSION_MONAT_ROWS_13_20_VERIFIED_STAGE_APPLY_20260326_131818.xlsx
- apply_report_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_13_20_VERIFIED_STAGE_DETERMINISTIC_REALIZATION_20260326_134430.md
- apply_execution_model: EXACT_CLONE_REALIZATION_FROM_SOURCE_PAYLOAD_SOURCE
- target_workbook_sha256_match_source: PASS
- deterministic_realization_verify: PASS
- status: PASS
- note: Der gelockte Apply-Targetpfad ist als exakter Byte-Clone des verified-stage Source-Workbooks materialisiert. Weil der Source-Payload-Contract aus genau diesem Workbook und genau diesem SHA256 stammt, ist MONAT A13:L20 im Target deterministisch realisiert, ohne das Source-Workbook inplace zu editieren.
<!-- EGO:MONAT_ROWS_13_20_VERIFIED_STAGE_DETERMINISTIC_REALIZATION END -->

<!-- EGO:MONAT_ROWS_21_25_VERIFIED_STAGE_APPLY_MODEL_LOCK START -->
## MONAT rows 21:25 verified-stage apply model lock
- scope: MONAT|ROWS_21_25|PACKAGE_A_L|VERIFIED_STAGE_APPLY_MODEL_LOCK_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_21_25_SOURCE_PAYLOAD_CONTRACT_20260326_150327.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_21_25_SOURCE_PAYLOAD_CONTRACT_20260326_150327.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- apply_model: CLONE_VERIFIED_STAGE_TO_TARGET_THEN_APPLY_CONTRACT
- source_workbook_inplace_edit: FORBIDDEN
- package_apply_readiness_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_SCAN_MONAT_ROWS_21_25_PACKAGE_APPLY_READINESS_A_L_20260326_154951.md
- next_scope_ready: PASS
- status: PASS
<!-- EGO:MONAT_ROWS_21_25_VERIFIED_STAGE_APPLY_MODEL_LOCK END -->

<!-- EGO:MONAT_ROWS_21_25_VERIFIED_STAGE_APPLY_TARGET_LOCK START -->
## MONAT rows 21:25 verified-stage apply target lock
- scope: MONAT|ROWS_21_25|PACKAGE_A_L|VERIFIED_STAGE_APPLY_TARGET_LOCK_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_21_25_SOURCE_PAYLOAD_CONTRACT_20260326_150327.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_21_25_SOURCE_PAYLOAD_CONTRACT_20260326_150327.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- target_workbook_output_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\outputs\EGO_VOLLVERSION_MONAT_ROWS_21_25_VERIFIED_STAGE_APPLY_20260326_151143.xlsx
- target_apply_report_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_21_25_VERIFIED_STAGE_TARGET_LOCK_20260326_151143.md
- apply_execution_model: CLONE_VERIFIED_STAGE_TO_TARGET_THEN_APPLY_CONTRACT
- source_workbook_inplace_edit: FORBIDDEN
- package_apply_readiness_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_SCAN_MONAT_ROWS_21_25_PACKAGE_APPLY_READINESS_A_L_20260326_154951.md
- next_scope_ready: PASS
- status: PASS
<!-- EGO:MONAT_ROWS_21_25_VERIFIED_STAGE_APPLY_TARGET_LOCK END -->

<!-- EGO:MONAT_ROWS_21_25_VERIFIED_STAGE_DETERMINISTIC_REALIZATION START -->
## MONAT rows 21:25 verified-stage deterministic realization
- scope: MONAT|ROWS_21_25|PACKAGE_A_L|VERIFIED_STAGE_DETERMINISTIC_REALIZATION_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_21_25_SOURCE_PAYLOAD_CONTRACT_20260326_150327.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_21_25_SOURCE_PAYLOAD_CONTRACT_20260326_150327.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- target_lock_report_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_21_25_VERIFIED_STAGE_TARGET_LOCK_20260326_151143.md
- target_workbook_output_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\outputs\EGO_VOLLVERSION_MONAT_ROWS_21_25_VERIFIED_STAGE_APPLY_20260326_151143.xlsx
- apply_report_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_21_25_VERIFIED_STAGE_DETERMINISTIC_REALIZATION_20260326_163453.md
- apply_execution_model: EXACT_CLONE_REALIZATION_FROM_SOURCE_PAYLOAD_SOURCE
- target_workbook_sha256_match_source: PASS
- deterministic_realization_verify: PASS
- status: PASS
- note: Der gelockte Apply-Targetpfad ist als exakter Byte-Clone des verified-stage Source-Workbooks materialisiert. Weil der Source-Payload-Contract aus genau diesem Workbook und genau diesem SHA256 stammt, ist MONAT A21:L25 im Target deterministisch realisiert, ohne das Source-Workbook inplace zu editieren.
<!-- EGO:MONAT_ROWS_21_25_VERIFIED_STAGE_DETERMINISTIC_REALIZATION END -->

<!-- EGO:MONAT_ROWS_26_37_VERIFIED_STAGE_APPLY_MODEL_LOCK START -->
## MONAT rows 26:37 verified-stage apply model lock
- scope: MONAT|ROWS_26_37|PACKAGE_A_L|VERIFIED_STAGE_APPLY_MODEL_LOCK_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_26_37_SOURCE_PAYLOAD_CONTRACT_20260326_181254.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_26_37_SOURCE_PAYLOAD_CONTRACT_20260326_181254.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- apply_model: CLONE_VERIFIED_STAGE_TO_TARGET_THEN_APPLY_CONTRACT
- source_workbook_inplace_edit: FORBIDDEN
- package_apply_readiness_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_SCAN_MONAT_ROWS_26_37_PACKAGE_APPLY_READINESS_A_L_AFTER_STRUCTURE_SCOPE_GREEN_20260326_190314.md
- next_scope_ready: PASS
- status: PASS
<!-- EGO:MONAT_ROWS_26_37_VERIFIED_STAGE_APPLY_MODEL_LOCK END -->

<!-- EGO:MONAT_ROWS_26_37_VERIFIED_STAGE_APPLY_TARGET_LOCK START -->
## MONAT rows 26:37 verified-stage apply target lock
- scope: MONAT|ROWS_26_37|PACKAGE_A_L|VERIFIED_STAGE_APPLY_TARGET_LOCK_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_26_37_SOURCE_PAYLOAD_CONTRACT_20260326_181254.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_26_37_SOURCE_PAYLOAD_CONTRACT_20260326_181254.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- target_workbook_output_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\outputs\EGO_VOLLVERSION_MONAT_ROWS_26_37_VERIFIED_STAGE_APPLY_20260326_184349.xlsx
- target_apply_report_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_26_37_VERIFIED_STAGE_TARGET_LOCK_20260326_184349.md
- apply_execution_model: CLONE_VERIFIED_STAGE_TO_TARGET_THEN_APPLY_CONTRACT
- source_workbook_inplace_edit: FORBIDDEN
- package_apply_readiness_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_SCAN_MONAT_ROWS_26_37_PACKAGE_APPLY_READINESS_A_L_AFTER_STRUCTURE_SCOPE_GREEN_20260326_190314.md
- next_scope_ready: PASS
- status: PASS
<!-- EGO:MONAT_ROWS_26_37_VERIFIED_STAGE_APPLY_TARGET_LOCK END -->

<!-- EGO:MONAT_ROWS_26_37_VERIFIED_STAGE_DETERMINISTIC_REALIZATION START -->
## MONAT rows 26:37 verified-stage deterministic realization
- scope: MONAT|ROWS_26_37|PACKAGE_A_L|VERIFIED_STAGE_DETERMINISTIC_REALIZATION_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_26_37_SOURCE_PAYLOAD_CONTRACT_20260326_181254.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_26_37_SOURCE_PAYLOAD_CONTRACT_20260326_181254.json
- target_lock_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_26_37_VERIFIED_STAGE_TARGET_LOCK_20260326_184349.md
- target_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\outputs\EGO_VOLLVERSION_MONAT_ROWS_26_37_VERIFIED_STAGE_APPLY_20260326_184349.xlsx
- target_workbook_sha256_match_source: PASS
- deterministic_realization_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_26_37_VERIFIED_STAGE_DETERMINISTIC_REALIZATION_20260326_185817.md
- realization_model: EXACT_CLONE_REALIZATION_FROM_SOURCE_PAYLOAD_SOURCE
- target_merge_range_count: 12
- target_formula_cell_count: 48
- target_static_value_cell_count: 36
- target_blank_or_covered_count: 60
- next_scope_ready: PASS
- status: PASS
<!-- EGO:MONAT_ROWS_26_37_VERIFIED_STAGE_DETERMINISTIC_REALIZATION END -->

<!-- EGO:MONAT_ROWS_38_59_VERIFIED_STAGE_APPLY_MODEL_LOCK START -->
## MONAT rows 38:59 verified-stage apply model lock
- scope: MONAT|ROWS_38_59|PACKAGE_A_L|VERIFIED_STAGE_APPLY_MODEL_LOCK_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_38_59_SOURCE_PAYLOAD_CONTRACT_20260326_204155.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_38_59_SOURCE_PAYLOAD_CONTRACT_20260326_204155.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- apply_model: CLONE_VERIFIED_STAGE_TO_TARGET_THEN_APPLY_CONTRACT
- source_workbook_inplace_edit: FORBIDDEN
- package_apply_readiness_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_SCAN_MONAT_ROWS_38_59_PACKAGE_APPLY_READINESS_A_L_AFTER_NEXT_OPEN_SCOPE_GREEN_20260326_203443.md
- sparse_signature: SPARSE_VALUE_ONLY|NO_MERGE|NO_FORMULA|NONEMPTY_COLS_K
- sparse_value_cell_count: 22
- sparse_formula_cell_count: 0
- sparse_merge_range_count: 0
- sparse_blank_or_covered_count: 242
- next_scope_ready: PASS
- status: PASS
<!-- EGO:MONAT_ROWS_38_59_VERIFIED_STAGE_APPLY_MODEL_LOCK END -->

<!-- EGO:MONAT_ROWS_38_59_VERIFIED_STAGE_APPLY_TARGET_LOCK START -->
## MONAT rows 38:59 verified-stage apply target lock
- scope: MONAT|ROWS_38_59|PACKAGE_A_L|VERIFIED_STAGE_APPLY_TARGET_LOCK_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_38_59_SOURCE_PAYLOAD_CONTRACT_20260326_204155.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_38_59_SOURCE_PAYLOAD_CONTRACT_20260326_204155.json
- source_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- source_workbook_sha256: 946ACA4FFC6158936AEFE36E1EEB9B2F3CAB86329A6F1F525CD440F2871C5439
- target_workbook_output_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\outputs\EGO_VOLLVERSION_MONAT_ROWS_38_59_VERIFIED_STAGE_APPLY_20260326_195051.xlsx
- target_apply_report_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_38_59_VERIFIED_STAGE_TARGET_LOCK_20260326_195051.md
- apply_execution_model: CLONE_VERIFIED_STAGE_TO_TARGET_THEN_APPLY_CONTRACT
- source_workbook_inplace_edit: FORBIDDEN
- package_apply_readiness_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_SCAN_MONAT_ROWS_38_59_PACKAGE_APPLY_READINESS_A_L_AFTER_NEXT_OPEN_SCOPE_GREEN_20260326_203443.md
- sparse_signature: SPARSE_VALUE_ONLY|NO_MERGE|NO_FORMULA|NONEMPTY_COLS_K
- sparse_value_cell_count: 22
- sparse_formula_cell_count: 0
- sparse_merge_range_count: 0
- sparse_blank_or_covered_count: 242
- next_scope_ready: PASS
- status: PASS
<!-- EGO:MONAT_ROWS_38_59_VERIFIED_STAGE_APPLY_TARGET_LOCK END -->

<!-- EGO:MONAT_ROWS_38_59_VERIFIED_STAGE_DETERMINISTIC_REALIZATION START -->
## MONAT rows 38:59 verified-stage deterministic realization
- scope: MONAT|ROWS_38_59|PACKAGE_A_L|VERIFIED_STAGE_DETERMINISTIC_REALIZATION_GREEN
- source_payload_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_EMIT_MONAT_ROWS_38_59_SOURCE_PAYLOAD_CONTRACT_20260326_204155.md
- source_payload_json: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\MONAT_ROWS_38_59_SOURCE_PAYLOAD_CONTRACT_20260326_204155.json
- target_lock_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_38_59_VERIFIED_STAGE_TARGET_LOCK_20260326_195051.md
- target_workbook_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\outputs\EGO_VOLLVERSION_MONAT_ROWS_38_59_VERIFIED_STAGE_APPLY_20260326_195051.xlsx
- target_workbook_sha256_match_source: PASS
- deterministic_realization_report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\REPORT_APPLY_MONAT_ROWS_38_59_VERIFIED_STAGE_DETERMINISTIC_REALIZATION_20260326_195820.md
- realization_model: EXACT_CLONE_REALIZATION_FROM_SOURCE_PAYLOAD_SOURCE
- sparse_signature: SPARSE_VALUE_ONLY|NO_MERGE|NO_FORMULA|NONEMPTY_COLS_K
- target_merge_range_count: 0
- target_formula_cell_count: 0
- target_static_value_cell_count: 22
- target_blank_or_covered_count: 242
- next_scope_ready: PASS
- status: PASS
<!-- EGO:MONAT_ROWS_38_59_VERIFIED_STAGE_DETERMINISTIC_REALIZATION END -->

<!-- EGO_MANAGED_BLOCK:START_CLOSEOUT_BOOTSTRAP_SYNC_20260329:START -->
## START CLOSEOUT BOOTSTRAP SYNC - 2026-03-29

- start_chain_closed: PASS
- start_closeout_sync: PASS
- verified_stage_manifest_sync: PASS
- working_source_path: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- working_source_sha256: D73DCBC29C128380381D74957527B34036953892964D2B44641D8902D56C6C41
- evidence_verify: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_reports\REPORT_VERIFY_EXACT_START_AFTER_PLACEHOLDER_REALIZATION_UNDER_VERIFIED_STAGE_20260328_222933.md
- evidence_sync: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_reports\REPORT_SYNC_EXACT_START_CLOSEOUT_INTO_SSOT_AND_SYNC_VERIFIED_STAGE_MANIFEST_FOR_NEXT_WORKBOOKWIDE_SCOPE_20260328_223908.md
- immediate_next_exact_gate: WORKBOOKWIDE_REPRIORITIZE_AFTER_START_CLOSEOUT
- forbid_start_reopen_without_real_evidence: TRUE
<!-- EGO_MANAGED_BLOCK:START_CLOSEOUT_BOOTSTRAP_SYNC_20260329:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_HINT_RAIL_T4_HASH_SYNC_20260329:START -->
## HAUSHALTSBUCH HINT-RAIL T4 HASH SYNC - 2026-03-29

- verified-stage workbook path = C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- verified-stage workbook sha256 = 70DA8A6103D0B935C99F4BB0C420EA29EEF98EC1AF004C50302E26E05993AEB4
- T4 apply is green and now part of the canonical verified-stage workbook state.
- All downstream HAUSHALTSBUCH hint-rail steps must anchor on the new hash.
- Closed inside active micro-chain: T4.
- Current micro-chain remains: HAUSHALTSBUCH -> HINT_RAIL -> NEXT_VISIBLE_APPLY_AFTER_T4.
<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_HINT_RAIL_T4_HASH_SYNC_20260329:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_HINT_RAIL_T5_HASH_SYNC_20260329:START -->
## HAUSHALTSBUCH HINT-RAIL T5 HASH SYNC - 2026-03-29

- verified-stage workbook path = C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- verified-stage workbook sha256 = A3152134E1C025D89F2AB5B83ED04007B3DD57CDBCE79A2D252C42F15903EAB6
- T5 apply is green and now part of the canonical verified-stage workbook state.
- All downstream HAUSHALTSBUCH hint-rail steps must anchor on the new hash.
- Closed inside active micro-chain: T4 and T5.
- Current micro-chain remains: HAUSHALTSBUCH -> HINT_RAIL -> NEXT_VISIBLE_APPLY_AFTER_T5.
<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_HINT_RAIL_T5_HASH_SYNC_20260329:END -->

<!-- EGO_MANAGED_BLOCK:RECURRING_FAILURE_PREVENTION_20260329_V1:START -->
## RECURRING FAILURE PREVENTION LOCK - 2026-03-29

- `RECURRING_FAILURE_PREVENTION_20260329=ACTIVE`
- `STEP_STUB_GUARD_HARD=ACTIVE`
- `EXACT_FRESH_STEP_PATH_ONLY=ACTIVE`
- `OPEN_COMMAND_MANDATORY=ACTIVE`
- `NO_CHAT_OVERLOAD_DRIFT=ACTIVE`
- `ACTIVE_SCOPE_ONLY_NO_RETURN_TO_CLOSED_CHAINS=ACTIVE`
- `INFRA_GREEN_IS_NOT_FACHLICH_GREEN=ACTIVE`
- `WORKBOOK_SHARED_FORMULA_RESOLUTION_REQUIRED=ACTIVE`
- `KNOWN_FAILURES_MUST_BECOME_HARD_PREVENTION=ACTIVE`
- Bekannte Wiederholungsfehler duerfen ab jetzt nicht nur dokumentiert, sondern muessen vor jedem relevanten OPEN/FULLSWAP/RUN aktiv ausgeschlossen werden.
- Fuer Workbook-Scan-/Verify-Steps gilt: Shared Formulas duerfen nie wieder als leer/freie Zielzellen fehlinterpretiert werden; reale Master-/si-Logik ist Pflicht.
- Der aktive Fachpfad bleibt nach diesem Praeventions-Sync weiter streng auf `HAUSHALTSBUCH -> A9:H9 -> ENTRY_CONTRACT` begrenzt.
<!-- EGO_MANAGED_BLOCK:RECURRING_FAILURE_PREVENTION_20260329_V1:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_A9_H9_CANONICAL_APPLY_SYNC_20260330_V1:START -->
## HAUSHALTSBUCH A9:H9 CANONICAL APPLY SYNC - 2026-03-30

- Der erste kanonische verified-stage Write im HAUSHALTSBUCH auf A9:H9 ist jetzt gruen abgeschlossen.
- Neuer bindender Workbook-Hash: D932CF1E9488338BAF00994976D108D51E0F6BD8CC1BCBBF167B8FDF7237CD07
- Geschrieben wurden nur die minimalen Payload-Felder A9|C9|E9|F9; B9|D9|G9|H9 blieben bewusst ungeschrieben.
- Abgeleitete Formeln I9:P9 muessen intakt bleiben und wurden im grueneren Apply-Verify-Lauf bestaetigt.
- Aktives einziges Thema bleibt HAUSHALTSBUCH.
- Naechster exakter Gate-Schritt: SCAN_EXACT_HAUSHALTSBUCH_NEXT_OPEN_ENTRY_ROW_AFTER_A9_H9_CANONICAL_APPLY
<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_A9_H9_CANONICAL_APPLY_SYNC_20260330_V1:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_BLOCK_MODE_HARDLAWS_20260330:START -->
## HAUSHALTSBUCH block mode hard laws - 2026-03-30

- HAUSHALTSBUCH_BLOCK_MODE_HARD=ACTIVE
- NO_ROW_BY_ROW_MICROCHAIN_AFTER_CANONICAL_ROW_PROOF=ACTIVE
- CANONICAL_ROW_PROOF_REUSE_FOR_FOLLOWING_EMPTY_BLOCK=ACTIVE
- BATCH_OR_CHECKPOINT_SYNC_ONLY_AFTER_BLOCK_APPLY=ACTIVE
- STEP_REPOROOT_FROM_SCRATCH_MUST_RESOLVE_TWO_LEVELS_UP=ACTIVE
- POWERSHELL_METHOD_ARGUMENT_EXPRESSION_GUARD=ACTIVE
- SYNC_HASH_PARSE_FALLBACK_TO_LIVE_HASH=ACTIVE
- FRESH_ARTIFACT_LINK_REQUIRED_PER_CURRENT_TURN=ACTIVE
- NO_NAKED_DOLLARSTEP_RUN_BLOCKS=ACTIVE

### Geltung

Sobald mindestens eine Zeile kanonisch voll bewiesen und die Folgezone als leerer Folgeblock bestaetigt ist, ist weitere Arbeit ab der Folgezone block-/batch-basiert. Einzelzeilen-Mikroketten sind dann verboten, solange kein echter neuer Abweichungsbefund vorliegt.
<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_BLOCK_MODE_HARDLAWS_20260330:END -->

<!-- EGO_HARDGATE_WRITE_ALLOWLIST_V1_BEGIN -->

- WRITE_STEPS_MUST_DECLARE_ALLOWLIST_BEFORE_FIRST_RUN=ACTIVE
- VERIFY_AND_SYNC_STEPS_WITH_REPORT_WRITES_ARE_WRITE_STEPS=ACTIVE
- STEP_MISSING_WRITE_ALLOWLIST_IS_KNOWN_PREVENTION_FAILURE=ACTIVE
- STEP_RUN_FORBIDDEN_WHEN_EGO_STEP_WRITE_ALLOWLIST_MISSING=ACTIVE
- BLOCK_MODE_HARD_REMAINS_ACTIVE_FOR_HAUSHALTSBUCH_FOLLOWUP_BLOCKS=ACTIVE
- NO_ROW_BY_ROW_MICROCHAIN_AFTER_CANONICAL_ROW_PROOF=ACTIVE
- NEXT_EXACT_STEP=FILL_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_WITH_REAL_SOURCE_ROWS

<!-- EGO_HARDGATE_WRITE_ALLOWLIST_V1_END -->

<!-- EGO_HARDGATE_WRITE_ALLOWLIST_V2_BEGIN -->

- WRITE_STEPS_MUST_DECLARE_ALLOWLIST_BEFORE_FIRST_RUN=ACTIVE
- VERIFY_AND_SYNC_STEPS_WITH_REPORT_WRITES_ARE_WRITE_STEPS=ACTIVE
- STEP_MISSING_WRITE_ALLOWLIST_IS_KNOWN_PREVENTION_FAILURE=ACTIVE
- STEP_RUN_FORBIDDEN_WHEN_EGO_STEP_WRITE_ALLOWLIST_MISSING=ACTIVE
- STEP_BODY_MUST_NEVER_BE_EXECUTED_INLINE_IN_CONSOLE=ACTIVE
- STEP_STANDARD_HEADER_MUST_USE_PSCOMMANDPATH=ACTIVE
- STEP_REPOROOT_FROM_SCRATCH_MUST_RESOLVE_TWO_LEVELS_UP=ACTIVE
- BLOCK_MODE_HARD_REMAINS_ACTIVE_FOR_HAUSHALTSBUCH_FOLLOWUP_BLOCKS=ACTIVE
- NO_ROW_BY_ROW_MICROCHAIN_AFTER_CANONICAL_ROW_PROOF=ACTIVE
- NEXT_EXACT_STEP=FILL_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_WITH_REAL_SOURCE_ROWS

<!-- EGO_HARDGATE_WRITE_ALLOWLIST_V2_END -->

<!-- EGO_HARDGATE_SCALAR_COUNT_GUARD_V1_BEGIN -->

- SCALAR_OR_NULL_PIPELINE_RESULTS_MUST_BE_ARRAY_COERCED_BEFORE_COUNT=ACTIVE
- TSV_PARSE_LINES_MUST_USE_ARRAY_COERCION_BEFORE_COUNT_OR_INDEX=ACTIVE
- STRICTMODE_PIPELINE_SINGLETON_COUNT_FAILURE_IS_KNOWN_PREVENTION_FAILURE=ACTIVE
- WRITE_STEPS_MUST_DECLARE_ALLOWLIST_BEFORE_FIRST_RUN=ACTIVE
- STEP_BODY_MUST_NEVER_BE_EXECUTED_INLINE_IN_CONSOLE=ACTIVE
- BLOCK_MODE_HARD_REMAINS_ACTIVE_FOR_HAUSHALTSBUCH_FOLLOWUP_BLOCKS=ACTIVE
- NEXT_EXACT_STEP=FILL_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_WITH_REAL_SOURCE_ROWS

<!-- EGO_HARDGATE_SCALAR_COUNT_GUARD_V1_END -->

<!-- EGO_TSV_HEADER_DELIMITER_GUARD_V1_BEGIN -->

- TSV_BATCH_PAYLOADS_MUST_BE_PARSED_WITH_EXPLICIT_TAB_DELIMITER=ACTIVE
- TSV_BATCH_PAYLOAD_HEADER_MUST_BE_VALIDATED_BEFORE_ROW_PARSE=ACTIVE
- UTF8_BOM_ON_FIRST_HEADER_COLUMN_MUST_BE_TRIMMED=ACTIVE
- MISSING_REQUIRED_COLUMN_MUST_DISTINGUISH_DELIMITER_OR_HEADER_FAILURE=ACTIVE
- REPORT_ARTIFACT_FALSE_POSITIVE_AS_PAYLOAD_SOURCE_FORBIDDEN=ACTIVE
- SCALAR_OR_NULL_PIPELINE_RESULTS_MUST_BE_ARRAY_COERCED_BEFORE_COUNT=ACTIVE
- WRITE_STEPS_MUST_DECLARE_ALLOWLIST_BEFORE_FIRST_RUN=ACTIVE
- STEP_BODY_MUST_NEVER_BE_EXECUTED_INLINE_IN_CONSOLE=ACTIVE
- NEXT_EXACT_STEP=FILL_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_WITH_REAL_SOURCE_ROWS

<!-- EGO_TSV_HEADER_DELIMITER_GUARD_V1_END -->

<!-- EGO_BATCH_PAYLOAD_HEADER_CONTRACT_HARDGATE_V1_BEGIN -->

- BATCH_PAYLOAD_TEMPLATE_HEADER_AND_VERIFY_CONTRACT_MUST_MATCH=ACTIVE
- BATCH_PAYLOAD_TEMPLATE_MUST_BE_REWRITTEN_IN_PLACE_ON_CONTRACT_MISMATCH=ACTIVE
- TSV_BATCH_PAYLOADS_MUST_BE_PARSED_WITH_EXPLICIT_TAB_DELIMITER=ACTIVE
- TSV_BATCH_PAYLOAD_HEADER_MUST_BE_VALIDATED_BEFORE_ROW_PARSE=ACTIVE
- UTF8_BOM_ON_FIRST_HEADER_COLUMN_MUST_BE_TRIMMED=ACTIVE
- MISSING_REQUIRED_COLUMN_MUST_DISTINGUISH_DELIMITER_OR_HEADER_FAILURE=ACTIVE
- NEXT_EXACT_STEP=FILL_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_WITH_REAL_SOURCE_ROWS

<!-- EGO_BATCH_PAYLOAD_HEADER_CONTRACT_HARDGATE_V1_END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_HEADER_ONLY_FILL_LOCK_20260330:START -->

## HAUSHALTSBUCH header-only intake lock - 2026-03-30

- ACTIVE_THEME=HAUSHALTSBUCH
- WORKING_SOURCE=VERIFIED_STAGE_ONLY
- WORKBOOK_SHA256=E0BF7FC04D88F544A05FFBAD23D625EE9097AFA46B2460FDF8882CC41674A853
- FOLLOWING_EMPTY_ENTRY_BLOCK_RANGE=A11:H500
- LIVE_BATCH_PAYLOAD_STATE=HEADER_ONLY
- LIVE_BATCH_PAYLOAD_ROW_COUNT=0
- INTAKE_AND_EXECUTION_MUST_BE_SEPARATED=ACTIVE
- NO_NEW_STEP_WHILE_UNCHANGED_HEADER_ONLY_PAYLOAD=ACTIVE
- NO_SCAN_VERIFY_APPLY_LOOP_WHILE_HEADER_ONLY=ACTIVE
- GOVERNANCE_SYNC_ONLY_AT_REAL_GATES=ACTIVE
- NEXT_EXACT_STEP=FILL_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_WITH_REAL_SOURCE_ROWS
- NEXT_STEP_AFTER_FIRST_REAL_ROWS=VERIFY_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_BEFORE_BATCH_APPLY

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_HEADER_ONLY_FILL_LOCK_20260330:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_STABILITY_FREEZE_AND_DEFER_SURFACE_HARMONIZATION_20260330:START -->
## HAUSHALTSBUCH functional closeout + deferred surface harmonization - 2026-03-30

- ACTIVE_THEME=HAUSHALTSBUCH
- HAUSHALTSBUCH_FUNCTIONAL_STATUS=TECHNICALLY_READY_FOR_ENDUSER_ENTRY
- HAUSHALTSBUCH_CHAIN_CLOSEOUT=PASS
- WORKBOOK_TECHNICAL_STATE=STABLE
- WORKBOOK_SHA256=F575C9418656152B8892C3E962D76897F2F145922EC805B8C5077EEE0146D17A
- HAUSHALTSBUCH_BATCH_APPLY_REPORT=C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_reports\REPORT_APPLY_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_TO_VERIFIED_STAGE_IN_CHECKPOINTS_20260330_193427.md
- HAUSHALTSBUCH_BATCH_APPLY_ROW_RANGE=A11:H42
- HAUSHALTSBUCH_BATCH_APPLY_ROW_COUNT=32
- VERIFY_SHEET5_XML_DECLARATION_UTF8=YES
- VERIFY_DERIVED_OUTPUT_FORMULAS_INTACT=YES
- PRODUCT_VISIBLE_SYNTHETIC_BATCH_FILL_REMOVED=YES
- HAUSHALTSBUCH_SURFACE_ROW_HEIGHT_CHAOS_CONFIRMED=YES
- HAUSHALTSBUCH_SURFACE_HIDDEN_STATE_ROOTCAUSE=NO
- HAUSHALTSBUCH_SURFACE_ROOTCAUSE_KIND=ROWHEIGHT_STYLE_INCONSISTENCY
- SURFACE_HARMONIZATION_RUN_KIND=SEPARATE_WORKBOOKWIDE_AFTER_FORMULA_XML_FREEZE
- NO_VISIBLE_SYNTHETIC_ENDUSER_ROWS=ACTIVE
- STABILITY_BEFORE_SURFACE_HARMONIZATION=ACTIVE
- NEXT_EXACT_STEP=WORKBOOKWIDE_REPRIORITIZE_AFTER_HAUSHALTSBUCH_CLOSEOUT
<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_STABILITY_FREEZE_AND_DEFER_SURFACE_HARMONIZATION_20260330:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_BATCH_APPLY_FUNCTIONAL_CLOSEOUT_AND_HASH_SYNC_20260330:START -->
## HAUSHALTSBUCH FUNCTIONAL CLOSEOUT + HASH SYNC - 2026-03-30

- verified-stage workbook path = C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\private_sources\release_candidates\xlsx_verified_tier_stage_20260316\EGO_VOLLVERSION_XLSX_VERIFIED_20260316.xlsx
- verified-stage workbook sha256 = F575C9418656152B8892C3E962D76897F2F145922EC805B8C5077EEE0146D17A
- HAUSHALTSBUCH batch apply on A11:H42 is green and now part of the canonical verified-stage workbook state.
- The active HAUSHALTSBUCH scope is technically finished for current enduser entry usage.
- Surface harmonization stays deferred as a separate workbook-wide run after formula/XML freeze.
- All downstream verified-stage work must now anchor on the new hash.
- Immediate next exact gate: WORKBOOKWIDE_REPRIORITIZE_AFTER_HAUSHALTSBUCH_CLOSEOUT.
- Evidence apply report: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_reports\REPORT_APPLY_EXACT_HAUSHALTSBUCH_BATCH_SOURCE_PAYLOAD_ARTIFACT_FOR_A11_H500_TO_VERIFIED_STAGE_IN_CHECKPOINTS_20260330_193427.md
<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_BATCH_APPLY_FUNCTIONAL_CLOSEOUT_AND_HASH_SYNC_20260330:END -->

<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A1_O11_CLOSEOUT_20260330:START -->
## BEDIENUNG A1:O11 closeout after manual visual check - 2026-03-30

- ACTIVE_THEME=BEDIENUNG
- BEDIENUNG_A1_O11_STATUS=CLOSED_GREEN
- BEDIENUNG_A1_O11_RANGE=A1:O11
- BEDIENUNG_A1_O11_APPLY_REPORT=C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_reports\REPORT_APPLY_EXACT_BEDIENUNG_HEADER_AND_FIRST_STEPS_BLOCK_A1_O11_FULL_APPLY_PAYLOAD_ARTIFACT_TO_VERIFIED_STAGE_20260330_220231.md
- BEDIENUNG_A1_O11_APPLY_MODE=NOOP_ALREADY_MATCHING_VERIFIED_STAGE_BLOCK
- BEDIENUNG_A1_O11_VISUAL_CHECK=CONFIRMED_BY_OPERATOR_BEFORE_STEP_RUN
- WORKBOOK_SHA256=F575C9418656152B8892C3E962D76897F2F145922EC805B8C5077EEE0146D17A
- NEXT_EXACT_STEP=DECIDE_EXACT_BEDIENUNG_NEXT_OPEN_WORK_ITEM_AFTER_A1_O11_CLOSEOUT_UNDER_VERIFIED_STAGE_ONLY
<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A1_O11_CLOSEOUT_20260330:END -->

<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A13_O35_CLOSEOUT_20260330:START -->
## BEDIENUNG A13:O35 closeout after manual visual check and post-tail scan - 2026-03-31

- ACTIVE_THEME=BEDIENUNG
- BEDIENUNG_A13_O35_STATUS=CLOSED_GREEN
- BEDIENUNG_A13_O35_RANGE=A13:O35
- BEDIENUNG_A13_O35_APPLY_REPORT=C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_reports\REPORT_APPLY_EXACT_BEDIENUNG_SELECTED_NEXT_OPEN_BLOCK_A13_O35_FULL_APPLY_PAYLOAD_ARTIFACT_TO_VERIFIED_STAGE_20260330_225757.md
- BEDIENUNG_A13_O35_CLOSEOUT_REPORT=C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_reports\REPORT_CLOSEOUT_EXACT_BEDIENUNG_SELECTED_NEXT_OPEN_BLOCK_A13_O35_AFTER_MANUAL_VISUAL_CHECK_UNDER_VERIFIED_STAGE_ONLY_20260330_230421.md
- BEDIENUNG_A13_O35_APPLY_MODE=NOOP_ALREADY_MATCHING_VERIFIED_STAGE_BLOCK
- BEDIENUNG_A13_O35_VISUAL_CHECK=CONFIRMED_BY_OPERATOR_BEFORE_STEP_RUN
- BEDIENUNG_POST_A13_REAL_NONEMPTY_ROWS=0
- BEDIENUNG_POST_A13_STYLE_ONLY_ROW_COUNT=44
- BEDIENUNG_POST_A13_TAIL_ROW_RANGE=A36:O79
- BEDIENUNG_POST_A13_TAIL_MERGE_COUNT=0
- BEDIENUNG_POST_A13_TAIL_DECISION=NO_FURTHER_OPEN_BLOCK_STYLE_ONLY_TAIL
- OPEN_SHEET_CANDIDATES_AFTER_BEDIENUNG=PARAMETER|LIZENZ|LISTEN|HEALTH_CHECK|SYS_CORE|AUDIT
- WORKBOOK_SHA256=F575C9418656152B8892C3E962D76897F2F145922EC805B8C5077EEE0146D17A
- NEXT_EXACT_GATE=WORKBOOKWIDE_REPRIORITIZE_AFTER_BEDIENUNG_CLOSEOUT
- NEXT_EXACT_STEP=SCAN_EXACT_WORKBOOKWIDE_REPRIORITIZATION_AFTER_BEDIENUNG_CLOSEOUT_UNDER_VERIFIED_STAGE_ONLY
<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A13_O35_CLOSEOUT_20260330:END -->

<!-- EGO_MANAGED_BLOCK:RECURRING_STEP_FAILURE_PREVENTION_20260331:START -->
## RECURRING STEP FAILURE PREVENTION - 2026-03-31

- Fresh-step-path drift ist P0: nach step-new.ps1 nur exakt den frisch zurueckgegebenen Pfad verwenden.
- Frisch erzeugte Step-Datei darf nie als Stub / Header-only / TODO-Fullswap gelaufen werden.
- Kein nacktes $step, kein impliziter Altpfad, keine Pfadvermutung.
- Jeder mutierende Step muss literal $EGO_STEP_WRITE_ALLOWLIST = @(...) enthalten, bevor er das erste Mal laeuft.
- Vor .Count immer auf @(...) normalisieren; keine .ToArray()-Annahme auf String/Skalar.
- Jeder Pfad / Report / Source-Wert muss vor Nutzung hart initialisiert sein.
- Parser / Regex / Report-Abfragen muessen auf dem real emittierten Reportformat basieren.
- Leere Treffer duerfen nie blind an code -g weitergereicht werden.
<!-- EGO_MANAGED_BLOCK:RECURRING_STEP_FAILURE_PREVENTION_20260331:END -->

<!-- EGO_MANAGED_BLOCK:FREEBIE_PUBLIC_PAID_PRIVATE_RELEASE_RULE_20260331:START -->
## FREEBIE PUBLIC / PAID PRIVATE RELEASE RULE - 2026-03-31

- Nur die FREEBIE-Version darf öffentlich zum Download stehen.
- PRO und VOLLVERSION laufen nicht öffentlich.
- Paid-Tiers laufen nur über Digistore oder private Distribution.
- Paid-Aktivierung, echte Digistore-Links und echte Buy-Flags bleiben End-Gate.
- Diese Regel ist bindend für Release-, Bundle-, Surface-, Funnel-, Sitemap-, Bing-, GSC- und Monetization-Schritte.
<!-- EGO_MANAGED_BLOCK:FREEBIE_PUBLIC_PAID_PRIVATE_RELEASE_RULE_20260331:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_BOOTSTRAP:START -->
## 2026-04-03 Gesprächsbefunde / Hardlaws
- sichtbare Blattarbeit nur als Ganzblatt-/Gesamtflächen-Schritt statt Mikro-Fix-Kette
- nach Masterbuild maximal 3 Korrekturläufe, danach kompletter Rebuild
- manueller Excel-Screenshot ist bindende Sichtwahrheit für sichtbare Entscheidungen
- RUN nur mit literalem exaktem Pfad; kein nacktes `$step`; kein nacktes `$file`
- Stub/TODO/Header-only = STOP vor jedem RUN
- Tool-Roots `_INTERN\tools`, `repo\_INTERN\tools`, `repo\tools`, `_INTERN\governance\tools` gehören ab jetzt zum Pflicht-Sync
- `repo\tools` ist nicht nur Pfad, sondern operativer Tool-Root und muss semantisch in Bootstrap/SSOT/Brain/QA/Learnings verankert sein
<!-- EGO_MANAGED_BLOCK:APRIL03_BOOTSTRAP:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_HAUSHALTSBUCH_VISIBLE_SURFACE_POLICY:START -->
## 2026-04-03 User hardlaw synced
- visible sheet work runs as GANZBLATT-/GESAMTFLAECHEN-Schritt
- no single-cell / single-row / local micro-fix visible-surface steps
- no quiz or decision prompt loops
- review whole visible surface first
- collect all visible blockers first
- execute exactly one consolidated apply for the visible surface
- then screenshot + review + closeout
- current active target: VOLLVERSION / Blatt HAUSHALTSBUCH / SICHTBARE OBERFLAECHE ALS GANZBLATT
- current visible scope token: WHOLE_VISIBLE_HAUSHALTSBUCH_SURFACE
- Help-Panel Textsystem remains closed green
- Top-Context-Hint-Line remains green and is not continued in isolation
- Expected verified-stage SHA-256 guard: 1BDF947899831B9DEAF3D8B5ADBF518EB1FC3892ECBA2DB23AE77CD7B4010771
<!-- EGO_MANAGED_BLOCK:APRIL03_HAUSHALTSBUCH_VISIBLE_SURFACE_POLICY:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:START -->
## 2026-04-03 Excel Research-First Hardlaw
- Vor jedem Excel-Befehl ist zuerst Web-Recherche durchzuführen.
- Mindestquellenklassen:
  - MICROSOFT_DOCS
  - MICROSOFT_COMMUNITY_OR_FORUM
  - CHAMPIONSHIP_OR_FMWC
- Ziel ist immer: bestes Ergebnis, sicher, stabil, schnell, ohne Umwege.
- Erst danach dürfen Excel-bezogene Befehle, Steps oder Apply-Läufe ausgegeben werden.
- Die Recherche muss Best Practice, neueste Funktionen/Erkenntnisse und stabile Vorgehensweisen abdecken.
- Für die aktuelle Arbeitskette betrifft das insbesondere HAUSHALTSBUCH / WHOLE_VISIBLE_HAUSHALTSBUCH_SURFACE.
<!-- EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_PREAPPLY_BACKUP:START -->
## 2026-04-03 Pre-Apply Backup Hardlaw
- Vor jeder mutierenden Workbook-Aktion ist zuerst ein explizites Pre-Apply-Backup zu erzeugen.
- Das Backup muss als reales Artefakt unter `_local\workbook_backups` liegen.
- Pflichtfelder im Backup-Report:
  - SOURCE_PATH
  - BACKUP_PATH
  - SOURCE_SHA256
  - BACKUP_SHA256
- Rollback ist nur noch von einem expliziten Backup-Artefakt erlaubt.
- Hash-Suche im Dateibaum ohne bewusst erzeugten Restorepunkt ist verboten.
- Wenn kein Pre-Apply-Backup vorhanden ist, muss der Excel-Apply vor dem Öffnen/Mutieren der Datei fehlschlagen.
- Diese Regel gilt vor jedem Excel-Apply, auch bei sichtbaren Ganzblatt-/Gesamtflächen-Schritten.
<!-- EGO_MANAGED_BLOCK:APRIL03_PREAPPLY_BACKUP:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_ACTIVE_EXCEL_SURFACE_CONTRACT:START -->
## 2026-04-03 Active Excel Surface Contract / Layout Spec / Gate
- aktiver Excel-Strang wird nicht mehr nur aus Prosa gesteuert
- bindende Steuerobjekte:
  - C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\ACTIVE_EXCEL_SURFACE_CONTRACT_HAUSHALTSBUCH_2026-04-03.json
  - C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\VISIBLE_SURFACE_LAYOUT_SPEC_HAUSHALTSBUCH_2026-04-03.json
  - C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\tools\gate-excel-surface-contract.ps1
- sichtbare Haupteingabefläche bleibt A:J
- K:S sind funktionale/abgeleitete Spalten und nie Designfläche
- Help-Card darf nur in T:Z entstehen
- AA:AB bleiben ausgeblendet
- vor jedem Excel-Apply müssen Research, Backup und Surface-Gate PASS sein
- jeder Step, der gegen Contract oder Layout Spec verstößt, ist vor Workbook-Mutation zu stoppen
<!-- EGO_MANAGED_BLOCK:APRIL03_ACTIVE_EXCEL_SURFACE_CONTRACT:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_EXCEL_EXECUTION_STACK:START -->
## 2026-04-03 bindender Excel-Ausführungsstack
- Excel-Applys werden nicht mehr frei aus Chat-Prosa gestartet
- verpflichtende Reihenfolge:
  1. Research Gate
  2. Pre-Apply Backup
  3. Excel Surface Contract Gate
  4. erst dann Apply
- aktiver Contract: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\ACTIVE_EXCEL_SURFACE_CONTRACT_HAUSHALTSBUCH_2026-04-03.json
- aktiver Layout Spec: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\VISIBLE_SURFACE_LAYOUT_SPEC_HAUSHALTSBUCH_2026-04-03.json
- Surface Gate: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\tools\gate-excel-surface-contract.ps1
- Stack Tool: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\tools\invoke-excel-guard-stack.ps1
- bindender Workbook-Hash: 6BDFAE4F3138B3E05FC4552D481427A897F295085AB110E0DC2413B69388F217
<!-- EGO_MANAGED_BLOCK:APRIL03_EXCEL_EXECUTION_STACK:END -->

<!-- EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_STANDARD:START -->
## APRIL09 MASTERPASS HYBRID STANDARD
- Aktive Modi sind hart getrennt: WORKBOOK_MASTERPASS | SHEET_FINALIZER | TOOL_REPAIR.
- WORKBOOK_MASTERPASS ist fuer globale Oberflaeche, Designsystem, Info-Panels, Trim/Hide und Sicht-/Fensterhygiene.
- SHEET_FINALIZER ist fuer blattspezifische Logik, Eingabeflaechen, Formeln, KPI-/Tabellenvertrag und Screenshot-Abnahme.
- TOOL_REPAIR ist reiner Technikmodus und darf nicht mit Produkt-Apply vermischt werden.
- Nach Hash-Mismatch ist nur SCAN_ONLY erlaubt.
- Nach jedem Workbook-Masterpass ist Truth-Relock Pflicht, bevor ein SHEET_FINALIZER oder weiterer Apply laufen darf.
<!-- EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_STANDARD:END -->

<!-- EGO_MANAGED_BLOCK:WORKBOOK_VISIBLE_SURFACE_FALSE_CLOSEOUT_HARDLAW_20260411:START -->
## 2026-04-11 – WORKBOOK_VISIBLE_SURFACE_FALSE_CLOSEOUT_HARDLAW

- Eine lokale PDF-/Crop-Verbesserung ist kein workbookweiter sichtbarer Oberflächen-Closeout.
- Reale Excel-Screenshots über die relevanten sichtbaren Blätter schlagen lokale Einzelstrang-Erfolge.
- Ab jetzt feste Reihenfolge für sichtbare Workbook-Arbeit:
  1. WORKBOOK_MASTERPASS_VISIBLE_SURFACE
  2. SHEET_FINALIZER_VISIBLE_SURFACE
  3. TOOL_REPAIR nur bei Tool-/Verify-Defekt
- Workbookweite sichtbare Oberfläche darf erst grün geschlossen werden, wenn keine sichtbaren Restfragmente, Geisterblöcke, tote Flächen oder Geometriebrüche mehr in den echten Excel-Screenshots vorhanden sind.
- Referenznotiz: C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\incidents\WORKBOOK_VISIBLE_SURFACE_FALSE_CLOSEOUT_AND_MASTERPASS_HARDLAW_20260411.md
<!-- EGO_MANAGED_BLOCK:WORKBOOK_VISIBLE_SURFACE_FALSE_CLOSEOUT_HARDLAW_20260411:END -->

<!-- EGO_PREMIUM_REDESIGN_V4_START -->
## 2026-04-11 — Premium-Redesign-Vertrag V4

- Primäre visuelle Leitinstanz: Claude
- Käufer-/Preis-Gate: Grok
- Workbook-Masterpass nur noch für Invarianten
- 100 % Zoom ist harte Invariante
- Dashboard-Finalizer zuerst
- Kanonischer Vertrag:
  - `contracts/WORKBOOK_PREMIUM_REDESIGN_CONTRACT_V4_INTERNAL.md`
<!-- EGO_PREMIUM_REDESIGN_V4_END -->
