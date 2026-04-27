# TODO_INTERNAL

## AKTIVER P0-STRANG - 20260413_150900

- [x] Starttext/Artefakte/letzte 10 Tage gegeneinander abgeglichen.
- [x] False-Closeout-/One-Shot-/Recovery-Learnings in Bootstrap, Governance, Learnings, QA, Failure-Patterns, Flowmap und Start-Akzeptanz verankert.
- [x] `WORKBOOK_VISIBLE_SURFACE_FALSE_CLOSEOUT_AND_MASTERPASS_HARDLAW_20260411.md` kanonisch gespiegelt.
- [x] `WORKBOOK_OPENXML_RECOVERY_PRE_REPAIR_HARDLAW_20260413.md` neu kanonisch angelegt und gespiegelt.
- [x] Task-Matrix und Runner/Required-Reads auf `OpenXML-Recovery-PreRepair` und konsistente TaskTypes aktualisiert.
- [ ] Exact backup-Artefakt fuer `EGO_Pro_Baseline_TierVerify_20260316_152701.xlsx` vor erstem Repair-Step schreiben.
- [ ] Exakten Recovery-Plan fuer START festschreiben und nur den ersten Repair-Step vorbereiten.
- [ ] Nach jedem Recovery-Apply: VERIFY -> RUN -> REPORT -> Sofort-Sync.

## AKTUELL NICHT AKTIV

- [ ] Kein weiterer workbookweiter Masterpass-Apply.
- [ ] Kein weiterer START-Dashboard-Finalizer.
- [ ] Kein Rueckfall in HAUSHALTSBUCH-only Scope.
- [ ] Keine Public-Surface-/Funnel-/Paid-Arbeit vor Recovery-Closeout.
- [ ] Kein `step-run-latest` fuer OpenXML-Recovery.

# BEGIN EGO_MANAGED_BLOCK:START_BEDIENUNG_USED_RANGE_CLEANUP_TODO_20260426
## Active TODO - 20260426 START/BEDIENUNG UsedRange cleanup
- [x] ZIP/TXT/XLSX intake and drift analysis complete.
- [x] Safe scan/plan complete for START and BEDIENUNG.
- [x] Governance/Brain/Tooling sync for merge-safe cleanup prepared.
- [ ] Run exact governance/tooling sync step and confirm report.
- [ ] Create exact workbook backup before any workbook mutation.
- [ ] Apply OpenXML bounds cleanup to START and BEDIENUNG only.
- [ ] Verify workbook opens, merge ranges preserved, UsedRange reduced, HAUSHALTSBUCH unchanged.
- [ ] Report and sync final state.
# END EGO_MANAGED_BLOCK:START_BEDIENUNG_USED_RANGE_CLEANUP_TODO_20260426

<!-- EGO-MANAGED: -->
# Workbook-Product-Finish-Contract aus Screenshot-Evidenz

## Entscheidung

Der LIZENZ-Einzelpfad wird gestoppt. Die Screenshots zeigen einen workbookweiten Produktfinish-Bedarf.

- CURRENT_WORKBOOK_SHA256 = A7821AFEDFF8D97BBE3269D6A7F9CDA70CFE61A2394AF68BC136A7666CBB7F5A
- TARGET = VOLLVERSION_PRODUCT_READY
- ROUTE = CLASS_BASED_IN_PLACE_PRODUCT_FINISH
- NEXT = ONE_SHOT_WORKBOOK_PRODUCT_FINISH_APPLY_FROM_CONTRACT

## Positiv funktionierender Weg

- Werte und Formeln bleiben an Ort und Stelle.
- Keine dynamische Payload-/Restore-Logik mehr.
- Keine neuen Merges.
- Keine Shapes als Fremdflächen über Zellgitter.
- Gridlines aus.
- Feste Spaltenbreiten und Zeilenhöhen.
- Screenshot entscheidet.
- Nach Acceptance kein weiteres Mikroflickern.

## Harte Screenshot-Befunde

- START wirkt nicht wie eine starke Produkt-Startseite.
- PARAMETER hat Setup-/Leerflächen- und Linienartefakte.
- LIZENZ ist inhaltlich brauchbar, aber optisch zu langes Raster.
- LISTEN hat einen rechten dunklen Fremdblock.
- MONAT enthält sichtbare ##### und ist damit Release-Blocker.
- BUDGETS, FIXKOSTEN, JAHR, NOTGROSCHEN, SCHULDEN, MONATSABSCHLUSS und AUDIT brauchen class-based Product-Finish.
- STEUER und SPARZIELE sind akzeptiert und werden nicht weiter gedoktert.
- HAUSHALTSBUCH bleibt ohne separaten Contract no-touch.

## Sheet-Klassen

- START = landing_dashboard
- PARAMETER = setup_configuration
- LIZENZ = license_release_facing
- LISTEN = reference_masterdata
- HAUSHALTSBUCH = core_input_table
- MONAT / JAHR = analysis
- BUDGETS / FIXKOSTEN = planning_input
- NOTGROSCHEN / SCHULDEN = financial_goal_strategy
- MONATSABSCHLUSS / AUDIT = review_gate
- BEDIENUNG = manual
- STEUER / SPARZIELE = accepted_product_surface

## Nächster Step

Ein einziger workbookweiter Master-Apply auf Contract-Basis:

- Backup vor Änderung.
- Hash-Gate auf A7821AFEDFF8D97BBE3269D6A7F9CDA70CFE61A2394AF68BC136A7666CBB7F5A.
- Workbookweit #####-Scan und Display-Fix.
- Class-based Width/Height/PrintArea/Gridline/Tab-Finish.
- Support-/Release-Sheets kompakter machen.
- Kein HAUSHALTSBUCH-Apply.
- Kein STEUER/SPARZIELE-Mikrofix.
<!-- EGO-MANAGED: -->

<!-- EGO:PARAMETER_ACCEPTANCE_AFTER_CORRECTION_PASS1:START -->
## PARAMETER accepted after correction pass 1 — 2026-04-27

STATUS=ACCEPTED
WORKBOOK_SHA256=C1D1E2C15AE08839F35FA8DE2802A0BC0186989E27741BAFCE6B89A7771B6301
ACTIVE_SHEET=PARAMETER
ACCEPTED_STEP=p0_apply_parameter_correction_pass1_surface_limit_20260427_040000.ps1
SCREENSHOT_ACCEPTANCE=PASS
DECISION=NO_FURTHER_PARAMETER_APPLY
NEXT_PRIORITY=LIZENZ

### Ergebnis

PARAMETER ist nach Correction Pass 1 als produktfähige Einstellungsseite akzeptiert. Der sichtbare untere Artefaktbereich ist entfernt; die Seite wirkt ruhig, kompakt und ausreichend sauber für die VOLLVERSION.

### Verbotene Folgeaktionen

- Kein weiterer PARAMETER-Tail-/Gridline-Hack.
- Kein Workbookwide OpenXML-/COM-Masterpass auf Spalten/Zeilen.
- Kein Clear/Delete/UnMerge/AutoFit.
- Keine PARAMETER-Mutation ohne neuen Real-Scan und neues Screenshot-Indiz.

### Nächster Produktfokus

Nach diesem Sync weiter mit LIZENZ als nächstem offenen Produktflächen-Kandidaten.
<!-- EGO:PARAMETER_ACCEPTANCE_AFTER_CORRECTION_PASS1:END -->

<!-- EGO:AUTO: -->
ACCEPTANCE=LIZENZ_TARGETED_FINALIZER
STATUS=PASS_ACCEPTED_AND_SYNCED
WORKBOOK_SHA256=D2053725A232D18D4E17078FC459529F075C40E2AFE7D34E4A286FC3938F12A1
ACCEPTED_SHEET=LIZENZ
SCOPE=LIZENZ_ONLY
VISUAL_DECISION=ACCEPT_LIZENZ
APPLY_REPORT=C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_reports\REPORT_APPLY_LIZENZ_TARGETED_FINALIZER_HIDE_EMPTY_GRID_SURFACE_20260427_044500.md
APPLY_JSON=C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\_scratch\LIZENZ_TARGETED_FINALIZER_HIDE_EMPTY_GRID_SURFACE_20260427_044500.json
NEXT_PRIORITY=LISTEN_TARGETED_PRODUCT_SURFACE_CONTRACT
UPDATED=20260427_050000
WORKBOOK_MUTATION=NO
<!-- EGO:AUTO: -->

<!-- EGO_AUTO_SYNC:LISTEN_ACCEPTED_20260427_060000:BEGIN -->
## LISTEN akzeptiert

- Zeitpunkt: 20260427_060000
- Workbook-SHA256: 282751D86403F946ECAFC5FF4DBB749A4D74B3848BE1B557E3660468E7E3129C
- Akzeptiertes Blatt: LISTEN
- Entscheidung: LISTEN ist nach gezieltem Q-Spalten-Finalizer visuell akzeptiert.
- Kein weiterer LISTEN-Apply.
- Kein Workbookwide-Masterpass.
- Akzeptierte Locks bleiben No-Touch: PARAMETER, LIZENZ, LISTEN, STEUER, SPARZIELE.
- HAUSHALTSBUCH bleibt No-Touch.
- Nächster fachlicher Zielbereich: MONAT, weil dort sichtbare Hash-/Overflow-Markierungen als verbleibender Produktfinish-Blocker bekannt sind.
<!-- EGO_AUTO_SYNC:LISTEN_ACCEPTED_20260427_060000:END -->

<!-- EGO_FINAL_WORKBOOK_PRODUCT_FINISH_ACCEPTANCE_START -->
## Final Workbook Product Finish Acceptance

STATUS=WORKBOOK_PRODUCT_FINISH_VISUAL_CLOSEOUT_READY
WORKBOOK_SHA256=E4C0FEF810325ACDFDE7CB26597C3E34072217C9A1C333171CE1858E6175832D
ACCEPTED_AT=20260427_081500
WORKBOOK_MUTATION=NO

### Finaler Scan

FINAL_SCAN=FINAL_WORKBOOK_CLOSEOUT_RESCAN_AFTER_AUDIT_ACCEPTANCE
FINAL_SCAN_STATUS=PASS_READONLY
OPEN_CANDIDATES_VISIBLE_NOT_ACCEPTED_NOT_NO_TOUCH=NONE
HARD_BLOCKERS=NONE
VISIBLE_SHEET_COUNT=17
SHEET_COUNT=19

### Akzeptierte Locks

- START_ACCEPTED_LOCK_NO_TOUCH
- PARAMETER_ACCEPTED_LOCK_NO_TOUCH
- LIZENZ_ACCEPTED_LOCK_NO_TOUCH
- LISTEN_ACCEPTED_LOCK_NO_TOUCH
- HAUSHALTSBUCH_NO_TOUCH
- MONAT_ACCEPTED_LOCK_NO_TOUCH
- BUDGETS_ACCEPTED_LOCK_NO_TOUCH
- JAHR_ACCEPTED_LOCK_NO_TOUCH
- FIXKOSTEN_ACCEPTED_LOCK_NO_TOUCH
- BEDIENUNG_ACCEPTED_LOCK_NO_TOUCH
- NOTGROSCHEN_ACCEPTED_LOCK_NO_TOUCH
- PLANUNG_ACCEPTED_LOCK_NO_TOUCH
- AUDIT_ACCEPTED_LOCK_NO_TOUCH
- SCHULDEN_ACCEPTED_LOCK_NO_TOUCH
- MONATSABSCHLUSS_ACCEPTED_LOCK_NO_TOUCH
- STEUER_ACCEPTED_LOCK_NO_TOUCH
- SPARZIELE_ACCEPTED_LOCK_NO_TOUCH

### Entscheidung

DECISION=NO_FURTHER_WORKBOOK_VISUAL_APPLY
NO_WORKBOOKWIDE_MASTERPASS=ACTIVE
NO_ACCEPTED_SHEET_MUTATION_WITHOUT_NEW_REAL_EVIDENCE=ACTIVE

### Nächster Produkt-/Release-Schritt

NEXT=CREATE_RELEASE_CANDIDATE_SNAPSHOT_AND_GIT_CLOSEOUT
<!-- EGO_FINAL_WORKBOOK_PRODUCT_FINISH_ACCEPTANCE_END -->
