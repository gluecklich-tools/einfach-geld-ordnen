<!-- EGO_MANAGED_BLOCK:FULL_PROJECT_AUDIT_RECONCILIATION_V1:START -->
## TODO PRIORITY LOCK AFTER RECONCILE CLOSEOUT AND EXPLICIT _INTERN BUNDLE_RELEASE_ZIPS FREEZE - 2026-03-24

- P0 abgeschlossen:
  - [x] source-contract and acceptance mirror sync for the repaired green START / sheet1 state abschliessen.
  - [x] WORKBOOK_CANONICAL_SOURCE_MANIFEST_20260322.tsv und WORKBOOK_SOURCE_IDENTITY_AUDIT_2026-03-22.md fuer die verbleibenden VOLLVERSION-Widersprueche hart reconciliieren.
  - [x] _INTERN bundle_release_zips bis zur Identitaetsfreigabe explizit sperren.
  - [x] Alle weiteren workbook-mutierenden Steps projektweit auf candidate-/bundle-Quellen scannen und bei Treffern auf verified-stage umstellen; live repo/_INTERN-Tooltreffer = 0.
  - [x] governance closeout + follow-up starttext fuer den jetzt grueneren Reconcile-Strang ausfuehren.

- P1 nachgelagert:
  - [ ] breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only wieder aufnehmen.
  - [ ] danach erst START-/VOLLVERSION-Design-, Public-Surface-, Funnel-, Sitemap-, Bing-, GSC- und Paid-Themen in neuer Re-Priorisierung freigeben.

- End-Gate / bewusst deferred:
  - [ ] Paid-Aktivierung / echte Digistore-Links / echte Buy-Flags erst nach spaeterem workbook-weiten Fortschritt und erneuter gruener Gesamt-P0/P1-Kette.

- Definitiv nicht erneut als aktives Thema fuehren:
  - [x] pre-live-surface-and-funnel-finalization-before-paid-activation
  - [x] README-/Anleitung-PDF-Repriorisierung
  - [x] START premium dashboard rebuild als aktueller Sofortpfad
  - [x] workbook-weite VOLLVERSION-Arbeit vor dem grueneren Reconcile-Closeout
<!-- EGO_MANAGED_BLOCK:FULL_PROJECT_AUDIT_RECONCILIATION_V1:END -->

<!-- EGO_MANAGED_BLOCK:ENTERPRISE_MASTERPLAN_PRIORITY_LOCK_V1:START -->
## TODO PRIORITY LOCK - 20260324

- Diese Reihenfolge ist jetzt verbindlich:
  1) broader workbook-wide VOLLVERSION work under verified-stage only
  2) erst danach weitere Release-/Bundle-/Funnel-/Sitemap-/Bing-/GSC-/Paid-Arbeit in neuer Re-Priorisierung
- _INTERN bundle_release_zips bleibt bis Identitaetsfreigabe/Rebuild/Freigabe gesperrt.
- Referenzdokument: Brain_EGO_Dateien\ENTERPRISE_MASTERPLAN_PRIORITY_2026-03-17.md
<!-- EGO_MANAGED_BLOCK:ENTERPRISE_MASTERPLAN_PRIORITY_LOCK_V1:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_REPRIORIZATION_AFTER_DOC_PDF_CLOSEOUT:START -->
## ACTIVE NEXT TOPIC - 20260328

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang ist jetzt ebenfalls gruener geschlossen; BUDGETS!A12:E31 ist deterministisch realisiert und BUDGETS_ROWS_32_36 ist bewusst als NO_APPLY_INTENTIONAL_STATIC_TAIL entschieden.
- Aktives Thema bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- Naechster exakter Gate-Schritt ausserhalb MONAT, PLANUNG, JAHR und BUDGETS ist WORKBOOKWIDE_REPRIORITIZE_AFTER_BUDGETS_CLOSEOUT.
- Kein weiterer BUDGETS-Run und kein Ruecksprung in BUDGETS!A12:E31 oder BUDGETS_ROWS_32_36.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_REPRIORIZATION_AFTER_DOC_PDF_CLOSEOUT:END -->

## SYNC_EVENT_20260317_RECURRING_PDF_BACKEND_FAILURES_AND_CHAT_REPO_DRIFT

- Offener Governance-Punkt: Sofort-Sync-Mechanik fuer wiederkehrende PDF-/Backend-/Array-/Owner-Scan-Fehler dauerhaft verankern und spaeter auf weitere Produktstraenge spiegeln.
- Geschlossen am 20260317_182112: kontrollierter doc->pdf Backend-Standard ist jetzt kanonisch definiert. README-/Anleitung-PDF nutzt tools\export-readme-anleitung-pdf.ps1; Writer/Python sind dafuer nicht der Default.

## SYNC_EVENT_20260317_POSTSYNC_ARRAY_BINDING_PDF_FAILURES_AND_NOREPEAT_ENFORCEMENT

- Offener Governance-Punkt: Den Post-Failure-Sync als Standard-Mechanik weiter haerten, bis Wiederholungen praktisch ausgeschlossen sind.
- Teilweise geschlossen am 20260317_182112: kanonischer README-/Anleitung-PDF-Helper ist gehaertet. Verbleibender Restpunkt ist nur noch Consumer-Migration/Verify gegen den neuen Contract.
- Offener Reviewpunkt: Bei nächster ruhiger Phase weitere sichtbare März-Fehlercluster produktübergreifend prüfen.

<!-- EGO_MANAGED_BLOCK:HTMLPROOFER_ROOTCAUSE_PREVENTION_TODO_V1:START -->
## Präventionsstandard nach HTMLProofer-Rootcause 2026-03-19

- [ ] `THIRD_PARTY_TOOL_ESCALATION_GATE` als feste Arbeitsregel in künftigen Dritttool-Fällen aktiv mitführen
- [ ] `RUNNER_FREEZE_AFTER_STABLE_LOG` in künftigen CI-/Runner-Fällen aktiv erzwingen
- [ ] `FAILURE_CATEGORY_SHIFT_STOP` in Reports und Apply-Ketten sichtbar machen
- [ ] `NO_PLACEHOLDER_STEP_PATH_EXECUTION` als harte Präventionsregel weiter absichern
- [ ] `HTMLPROOFER_SINGLE_DIRECTORY_CLI_RULE` in QA/Governance als Standard verankert halten
- [ ] `SOURCE_FIRST_AFTER_SCOPE_ISOLATION` als Default nach Scope-Bereinigung erzwingen
<!-- EGO_MANAGED_BLOCK:HTMLPROOFER_ROOTCAUSE_PREVENTION_TODO_V1:END -->

<!-- EGO_PROJECTWIDE_RUNPATH_AND_SCAN_TODO_V1:START -->
## Sofort dauerhaft beachten

- Projektuebergreifend immer zuerst Faktenscan/Real-Scan vor jedem Apply, Pfadbezug oder Struktur-Claim.
- Projektuebergreifend nie wieder RUN mit nacktem `$step`.
- Nur exakter harter Step-Pfad oder `step-run.ps1 -Pattern "..."`.
- Bei neuen Fixes erst Real-Scan, dann exakter Apply, dann Verify.
<!-- EGO_PROJECTWIDE_RUNPATH_AND_SCAN_TODO_V1:END -->

<!-- EGO_PROJECTWIDE_FULLTEXTSWAP_ONLY_TODO_V1_BEGIN -->
## P0 sofort dauerhaft: FULLTEXTSWAP_ONLY_NO_FRAGMENT_REPLACEMENT

- Bei allen kuenftigen Tasks nur kompletter FULLSWAP von Dateiinhalt.
- Niemals mehr Textfragment-, Teilblock-, Einzelzeilen- oder Snippet-Ersetzungen fuer Dateien vorschlagen oder anwenden.
- Niemals mehr "ersetze nur diese 2 Zeilen" als Dateibearbeitungsmodus.
- Bei Bedarf neuer Fixes: Real-Scan -> OPEN -> FULLSWAP -> VERIFY -> RUN -> REPORT.
<!-- EGO_PROJECTWIDE_FULLTEXTSWAP_ONLY_TODO_V1_END -->

<!-- EGO_MANAGED_BLOCK:WORKBOOK_ARTIFACT_IDENTITY_TODO_20260322:START -->
## P0 WORKBOOK ARTIFACT IDENTITY

- [x] verified-stage als einzige Arbeitsquelle fuer Workbook-Apply/Run festziehen.
- [x] Manifest fuer alle beobachteten Workbook-Artefaktrollen erzeugen.
- [x] Verify-Helper fuer Hash-/Payload-Identitaet anlegen.
- [x] START-Recovery-Closeout als TEMP_P0_RECOVERY_ONLY_EXPLICIT_CANDIDATE_SOURCE dokumentieren.
- [x] WORKBOOK_CANONICAL_SOURCE_MANIFEST_20260322.tsv und WORKBOOK_SOURCE_IDENTITY_AUDIT_2026-03-22.md fuer die verbleibenden VOLLVERSION-Widersprueche hart reconciliieren.
- [x] _INTERN bundle_release_zips bis zur Identitaetsfreigabe explizit sperren.
- [x] Alle weiteren workbook-mutierenden Steps projektweit auf candidate-/bundle-Quellen scannen und bei Treffern umstellen; live repo/_INTERN-Tooltreffer = 0.
- [x] governance closeout + follow-up starttext fuer den Reconcile-Strang gruener abgeschlossen.
<!-- EGO_MANAGED_BLOCK:WORKBOOK_ARTIFACT_IDENTITY_TODO_20260322:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_SCOPE_LOCK_TODO_20260322:START -->
## P0 ACTIVE_SCOPE_LOCK_ROLLOUT

- ACTIVE_SCOPE_LOCK_INTERNAL.md eingefuehrt
- ACTIVE_SCOPE_RESUME_INTERNAL.md eingefuehrt
- ACTIVE_SCOPE_OVERRIDE_LOG.tsv eingefuehrt
- Brain latest + kb_event gespiegelt
- explizite _INTERN bundle_release_zips freeze bis Identitaetsfreigabe verankert
- live repo/_INTERN tool scan = 0 actionable hits
- Reconcile-Strang gruener geschlossen
- naechster Fachschritt ist jetzt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only
<!-- EGO_MANAGED_BLOCK:ACTIVE_SCOPE_LOCK_TODO_20260322:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_FIXKOSTEN_CLOSEOUT_20260328:START -->
## ACTIVE NEXT TOPIC - 20260328_FIXKOSTEN

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang bleibt gruener geschlossen.
- FIXKOSTEN-Strang ist jetzt ebenfalls gruener geschlossen; F9:F30 ist deterministisch realisiert und es bleibt kein weiterer offener FIXKOSTEN-Apply.
- Aktives Thema bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- Naechster exakter Gate-Schritt ausserhalb MONAT, PLANUNG, JAHR, BUDGETS und FIXKOSTEN ist WORKBOOKWIDE_REPRIORITIZE_AFTER_FIXKOSTEN_CLOSEOUT.
- Kein weiterer FIXKOSTEN-Run und kein Ruecksprung in F9:F30.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_FIXKOSTEN_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_NOTGROSCHEN_CLOSEOUT_20260328:START -->
## ACTIVE NEXT TOPIC - 20260328_NOTGROSCHEN

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang bleibt gruener geschlossen.
- FIXKOSTEN-Strang bleibt gruener geschlossen.
- NOTGROSCHEN-Strang ist jetzt ebenfalls gruener geschlossen; A12:B18 ist deterministisch realisiert und es bleibt kein weiterer offener NOTGROSCHEN-Apply.
- Aktives Thema bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- Naechster exakter Gate-Schritt ausserhalb MONAT, PLANUNG, JAHR, BUDGETS, FIXKOSTEN und NOTGROSCHEN ist WORKBOOKWIDE_REPRIORITIZE_AFTER_NOTGROSCHEN_CLOSEOUT.
- Kein weiterer NOTGROSCHEN-Run und kein Ruecksprung in A12:B18.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_NOTGROSCHEN_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_SCHULDEN_CLOSEOUT_20260328:START -->
## ACTIVE NEXT TOPIC - 20260328_SCHULDEN

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang bleibt gruener geschlossen.
- FIXKOSTEN-Strang bleibt gruener geschlossen.
- NOTGROSCHEN-Strang bleibt gruener geschlossen.
- SCHULDEN-Strang ist jetzt ebenfalls gruener geschlossen; ab Zeile 4 bleibt kein befuellter SCHULDEN-Bereich offen und damit kein Apply.
- Aktives Thema bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- Naechster exakter Gate-Schritt ausserhalb MONAT, PLANUNG, JAHR, BUDGETS, FIXKOSTEN, NOTGROSCHEN und SCHULDEN ist WORKBOOKWIDE_REPRIORITIZE_AFTER_SCHULDEN_CLOSEOUT.
- Kein weiterer SCHULDEN-Run ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_SCHULDEN_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_MONATSABSCHLUSS_CLOSEOUT_20260328:START -->
## ACTIVE NEXT TOPIC - 20260328_MONATSABSCHLUSS

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang bleibt gruener geschlossen.
- FIXKOSTEN-Strang bleibt gruener geschlossen.
- NOTGROSCHEN-Strang bleibt gruener geschlossen.
- SCHULDEN-Strang bleibt gruener geschlossen.
- MONATSABSCHLUSS-Strang ist jetzt ebenfalls gruener geschlossen; Row-4-Leaf war leer und damit bleibt kein Apply offen.
- Aktives Thema bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- Naechster exakter Gate-Schritt ausserhalb der bereits geschlossenen Themen ist WORKBOOKWIDE_REPRIORITIZE_AFTER_MONATSABSCHLUSS_CLOSEOUT.
- Kein weiterer MONATSABSCHLUSS-Run ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_MONATSABSCHLUSS_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_STEUER_CLOSEOUT_20260328:START -->
## ACTIVE NEXT TOPIC - 20260328_STEUER

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang bleibt gruener geschlossen.
- FIXKOSTEN-Strang bleibt gruener geschlossen.
- NOTGROSCHEN-Strang bleibt gruener geschlossen.
- SCHULDEN-Strang bleibt gruener geschlossen.
- MONATSABSCHLUSS-Strang bleibt gruener geschlossen.
- STEUER-Strang ist jetzt ebenfalls gruener geschlossen; die Platzhalter-Realization wurde applied und verified.
- Aktives Thema bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- Naechster exakter Gate-Schritt ausserhalb der bereits geschlossenen Themen ist WORKBOOKWIDE_REPRIORITIZE_AFTER_STEUER_CLOSEOUT.
- Kein weiterer STEUER-Run ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_STEUER_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_SPARZIELE_CLOSEOUT_20260328:START -->
## ACTIVE NEXT TOPIC - 20260328_SPARZIELE

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang bleibt gruener geschlossen.
- FIXKOSTEN-Strang bleibt gruener geschlossen.
- NOTGROSCHEN-Strang bleibt gruener geschlossen.
- SCHULDEN-Strang bleibt gruener geschlossen.
- MONATSABSCHLUSS-Strang bleibt gruener geschlossen.
- STEUER-Strang bleibt gruener geschlossen.
- SPARZIELE-Strang ist jetzt ebenfalls gruener geschlossen; die Platzhalter-Realization wurde applied und verified.
- Aktives Thema bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- Naechster exakter Gate-Schritt ausserhalb der bereits geschlossenen Themen ist WORKBOOKWIDE_REPRIORITIZE_AFTER_SPARZIELE_CLOSEOUT.
- Kein weiterer SPARZIELE-Run ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_SPARZIELE_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_START_CLOSEOUT_20260328:START -->
## ACTIVE NEXT TOPIC - 20260328_START

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang bleibt gruener geschlossen.
- FIXKOSTEN-Strang bleibt gruener geschlossen.
- NOTGROSCHEN-Strang bleibt gruener geschlossen.
- SCHULDEN-Strang bleibt gruener geschlossen.
- MONATSABSCHLUSS-Strang bleibt gruener geschlossen.
- STEUER-Strang bleibt gruener geschlossen.
- SPARZIELE-Strang bleibt gruener geschlossen.
- START-Strang ist jetzt ebenfalls gruener geschlossen; der letzte Leaf START_ROWS_23_23 wurde als Platzhalter-True-Leaf realisiert und verified.
- Aktives Thema bleibt breitere workbook-weite VOLLVERSION-Arbeit unter verified-stage only.
- Verified-stage-Manifest ist auf den neuen Workbook-Hash synchronisiert.
- Naechster exakter Gate-Schritt ausserhalb der bereits geschlossenen Themen ist WORKBOOKWIDE_REPRIORITIZE_AFTER_START_CLOSEOUT.
- Kein weiterer START-Run ohne neue reale Evidenz.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_START_CLOSEOUT_20260328:END -->

<!-- EGO_MANAGED_BLOCK:RECURRING_FAILURE_PREVENTION_20260329_V1:START -->
## RECURRING FAILURE PREVENTION TODO / DONE - 2026-03-29

- [x] `STEP_STUB_GUARD_HARD` als bindende Praeventionsregel verankert.
- [x] `EXACT_FRESH_STEP_PATH_ONLY` als bindende Praeventionsregel verankert.
- [x] `OPEN_COMMAND_MANDATORY` als bindende Praeventionsregel verankert.
- [x] `NO_CHAT_OVERLOAD_DRIFT` als bindende Praeventionsregel verankert.
- [x] `ACTIVE_SCOPE_ONLY_NO_RETURN_TO_CLOSED_CHAINS` als bindende Praeventionsregel verankert.
- [x] `INFRA_GREEN_IS_NOT_FACHLICH_GREEN` als bindende Praeventionsregel verankert.
- [x] `WORKBOOK_SHARED_FORMULA_RESOLUTION_REQUIRED` als bindende Praeventionsregel verankert.
- [x] `KNOWN_FAILURES_MUST_BECOME_HARD_PREVENTION` als bindende Praeventionsregel verankert.
- [ ] Bei jedem kuenftigen Workbook-Scan-Step Shared-Formula-Aufloesung vor Marker-Verify aktiv mitpruefen.
- [ ] Bei jedem kuenftigen Step/Open/Run-Paket Stub-Guard, exakten Pfad und Open-Befehl explizit mitfuehren.
<!-- EGO_MANAGED_BLOCK:RECURRING_FAILURE_PREVENTION_20260329_V1:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_A9_H9_CANONICAL_APPLY_SYNC_20260330_V1:START -->
## HAUSHALTSBUCH first verified-stage write progression - 2026-03-30

- [x] A9:H9 Feldschema / Entry-Contract / Constraints / Payload-Gate gruen schliessen.
- [x] Kanonischen Minimal-Payload auf A9:H9 in verified-stage schreiben.
- [x] Naechsten exakten offenen Folgeblock bestimmen.
- [x] Batch-/Checkpoint-Strategie fuer A11:H500 unter wiederverwendetem A9-Vertrag festschreiben.
- [x] Echten Payload fuer A11:H500 verifizieren.
- [x] A11:H42 erfolgreich in verified-stage anwenden.
- [x] Post-Apply-Hash auf F575C9418656152B8892C3E962D76897F2F145922EC805B8C5077EEE0146D17A anheben und Binder darauf synchronisieren.
- [x] HAUSHALTSBUCH im aktuellen Scope technisch gruen und endnutzer-befuellbar schliessen.
<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_A9_H9_CANONICAL_APPLY_SYNC_20260330_V1:END -->

<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_BLOCK_MODE_TODO_LOCK_20260330:START -->
## HAUSHALTSBUCH block-mode closeout lock - 2026-03-30

- [x] A9:H9 kanonisch beweisen und anwenden.
- [x] A10:H10 unter wiederverwendetem A9-Vertrag kanonisch anwenden.
- [x] Folgeblock A11:H500 als Batch-/Checkpoint-Pfad statt Einzelzeilen-Mikrokette festschreiben.
- [x] Echten Payload fuer A11:H500 verifizieren.
- [x] A11:H42 erfolgreich auf verified-stage anwenden.
- [x] HAUSHALTSBUCH-Funktionsstand fuer den aktuellen Scope gruen schliessen.
- [ ] Naechster exakter Schritt: WORKBOOKWIDE_REPRIORITIZE_AFTER_HAUSHALTSBUCH_CLOSEOUT
- [ ] Surface-Harmonisierung spaeter separat nach Formel-/XML-Freeze behandeln.
<!-- EGO_MANAGED_BLOCK:HAUSHALTSBUCH_BLOCK_MODE_TODO_LOCK_20260330:END -->

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

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_HAUSHALTSBUCH_CLOSEOUT_20260330:START -->
## ACTIVE NEXT TOPIC - 20260330_HAUSHALTSBUCH_CLOSEOUT

- MONAT-Strang bleibt gruener geschlossen.
- PLANUNG-Strang bleibt gruener geschlossen.
- JAHR-Strang bleibt gruener geschlossen.
- BUDGETS-Strang bleibt gruener geschlossen.
- FIXKOSTEN-Strang bleibt gruener geschlossen.
- NOTGROSCHEN-Strang bleibt gruener geschlossen.
- SCHULDEN-Strang bleibt gruener geschlossen.
- MONATSABSCHLUSS-Strang bleibt gruener geschlossen.
- STEUER-Strang bleibt gruener geschlossen.
- SPARZIELE-Strang bleibt gruener geschlossen.
- START-Strang bleibt gruener geschlossen.
- HAUSHALTSBUCH-Strang ist jetzt im aktuellen Scope ebenfalls gruener geschlossen; A11:H42 ist erfolgreich auf verified-stage angewendet.
- Aktives Thema wechselt jetzt auf breitere workbook-weite VOLLVERSION-Repriorisierung unter verified-stage only.
- Naechster exakter Gate-Schritt ist WORKBOOKWIDE_REPRIORITIZE_AFTER_HAUSHALTSBUCH_CLOSEOUT.
- Kein weiterer HAUSHALTSBUCH-Reopen ohne neuen Realbefund.
- Surface-Harmonisierung bleibt bewusst separat und spaeter.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_HAUSHALTSBUCH_CLOSEOUT_20260330:END -->

<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A1_O11_CLOSEOUT_20260330:START -->
## BEDIENUNG A1:O11 first block closeout - 2026-03-30

- [x] BEDIENUNG A1:O11 real scan.
- [x] BEDIENUNG A1:O11 atomic full-block decision.
- [x] BEDIENUNG A1:O11 payload emit.
- [x] BEDIENUNG A1:O11 payload verify.
- [x] BEDIENUNG A1:O11 apply/no-op verify.
- [x] BEDIENUNG A1:O11 manual visual check.
- [x] BEDIENUNG A1:O11 closeout.
- [ ] Next exact step: DECIDE_EXACT_BEDIENUNG_NEXT_OPEN_WORK_ITEM_AFTER_A1_O11_CLOSEOUT_UNDER_VERIFIED_STAGE_ONLY
<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A1_O11_CLOSEOUT_20260330:END -->

<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A13_O35_CLOSEOUT_20260330:START -->
## BEDIENUNG A13:O35 block closeout - 2026-03-31

- [x] BEDIENUNG A13:O35 real scan.
- [x] BEDIENUNG A13:O35 atomic full-block decision.
- [x] BEDIENUNG A13:O35 full payload contract scan.
- [x] BEDIENUNG A13:O35 payload emit.
- [x] BEDIENUNG A13:O35 payload verify.
- [x] BEDIENUNG A13:O35 apply/no-op verify.
- [x] BEDIENUNG A13:O35 manual visual check.
- [x] BEDIENUNG A13:O35 closeout.
- [x] BEDIENUNG post-A13 tail real scan.
- [x] BEDIENUNG post-A13 no-further-open-block decision.
- [ ] Next exact step: SCAN_EXACT_WORKBOOKWIDE_REPRIORITIZATION_AFTER_BEDIENUNG_CLOSEOUT_UNDER_VERIFIED_STAGE_ONLY
<!-- EGO_MANAGED_BLOCK:BEDIENUNG_A13_O35_CLOSEOUT_20260330:END -->

<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_BEDIENUNG_CLOSEOUT_20260331:START -->
## ACTIVE NEXT TOPIC - 20260331

- BEDIENUNG-Strang ist jetzt gruener geschlossen.
- BEDIENUNG!A1:O11 bleibt geschlossen.
- BEDIENUNG!A13:O35 bleibt geschlossen.
- BEDIENUNG!A36:O79 ist style-only tail ohne realen Inhalt oder Merges.
- Aktives Thema wechselt jetzt auf workbook-weite Repriorisierung unter verified-stage only.
- Naechster exakter Gate-Schritt ist $NextExactStep.
- Kein weiterer BEDIENUNG-Apply und kein Reopen ohne neuen Realbefund.
<!-- EGO_MANAGED_BLOCK:ACTIVE_NEXT_TOPIC_AFTER_BEDIENUNG_CLOSEOUT_20260331:END -->

<!-- EGO_MANAGED_BLOCK:RECURRING_STEP_FAILURE_PREVENTION_20260331:START -->
## RECURRING FAILURE PREVENTION SYNC - 2026-03-31

- [x] Fresh-step-path drift als bekannter P0-Praeventionsfehler synchronisiert.
- [x] Stub-/Header-only-Step-Run als harter STOP-Fehler synchronisiert.
- [x] Literal Write-Allowlist-Pflicht synchronisiert.
- [x] Array-/Skalar-Normalisierung als Technikstandard synchronisiert.
- [x] Uninitialisierte Variablen als bekannter Defekt synchronisiert.
- [x] Report-/Regex-Formatdrift als Parser-Standard synchronisiert.
- [x] Empty-path-to-code-g als harter Guard synchronisiert.
<!-- EGO_MANAGED_BLOCK:RECURRING_STEP_FAILURE_PREVENTION_20260331:END -->

<!-- EGO_MANAGED_BLOCK:FREEBIE_PUBLIC_PAID_PRIVATE_RELEASE_RULE_20260331:START -->
## FREEBIE PUBLIC / PAID PRIVATE RELEASE RULE - 2026-03-31

- Nur die FREEBIE-Version darf öffentlich zum Download stehen.
- PRO und VOLLVERSION laufen nicht öffentlich.
- Paid-Tiers laufen nur über Digistore oder private Distribution.
- Paid-Aktivierung, echte Digistore-Links und echte Buy-Flags bleiben End-Gate.
- Diese Regel ist bindend für Release-, Bundle-, Surface-, Funnel-, Sitemap-, Bing-, GSC- und Monetization-Schritte.
<!-- EGO_MANAGED_BLOCK:FREEBIE_PUBLIC_PAID_PRIVATE_RELEASE_RULE_20260331:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_TODO:START -->
## 2026-04-03 Priorisierte To-dos
- Tool-Semantik schrittweise von Root-Ebene auf einzelne Long-Tail-Tools ausbauen
- `UNKNOWN/REVIEW_REQUIRED`-Bestand im Tool-Inventar systematisch abbauen
- Ganzblatt-Masterbuild je sichtbarer Seite als Standardlauf beibehalten
- Nach jedem neuen Failure-Muster sofort Sync in Bootstrap/Governance/Learnings/QA/Brain/Tools
<!-- EGO_MANAGED_BLOCK:APRIL03_TODO:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_HAUSHALTSBUCH_VISIBLE_SURFACE_POLICY:START -->
## 2026-04-04 next exact scope
- P0: WHOLE_VISIBLE_HAUSHALTSBUCH_SURFACE
- first run the contract-gated manual Excel screenshot/manual review on the hard-reset baseline
- only after that review: run at most one consolidated visible-surface apply for the next review cycle
- keep Help-Panel Textsystem closed
- keep Top-Context-Hint-Line integrated and not isolated
- if correction_count reaches 3: stop doktern and rebuild from baseline
<!-- EGO_MANAGED_BLOCK:APRIL03_HAUSHALTSBUCH_VISIBLE_SURFACE_POLICY:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:START -->
## 2026-04-03 Excel Research-First
- Vor jedem Excel-Befehl Research-Beleg erzeugen oder aktualisieren.
- Research-Precheck-Tool vor zukuenftigen Excel-Schritten mitlaufen lassen.
- Nur nach bestandenem Research-Precheck weiter in Masterbuild/Apply.
<!-- EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_PREAPPLY_BACKUP:START -->
## 2026-04-03 Workbook Backup Pflicht
- Vor jedem Excel-Apply `tools\new-workbook-preapply-backup.ps1` ausführen
- Backup-Report im Apply-Report referenzieren
- Rollback nur von BACKUP_PATH aus
<!-- EGO_MANAGED_BLOCK:APRIL03_PREAPPLY_BACKUP:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_ACTIVE_EXCEL_SURFACE_CONTRACT:START -->
## 2026-04-03 P0 Excel-Surface-Steuerung
- vor jedem Excel-Apply zuerst gate-excel-surface-contract.ps1 laufen
- Contract und Layout Spec bei Scope-Wechsel sofort aktualisieren
- keine Workbook-Mutation ohne PASS von Research + Backup + Surface Gate
<!-- EGO_MANAGED_BLOCK:APRIL03_ACTIVE_EXCEL_SURFACE_CONTRACT:END -->

<!-- EGO_MANAGED_BLOCK:APRIL03_EXCEL_EXECUTION_STACK:START -->
## 2026-04-03 P0 Excel-Ausführungsstack
- vor jedem Excel-Apply invoke-excel-guard-stack.ps1 laufen
- nur nach PASS von Research + Backup + Surface Gate in Workbook mutieren
- bei Scope-Wechsel Contract/Layout Spec zuerst aktualisieren
<!-- EGO_MANAGED_BLOCK:APRIL03_EXCEL_EXECUTION_STACK:END -->

<!-- EGO_MANAGED_BLOCK: -->
## TODO LOCK AFTER HAUSHALTSBUCH VISIBLE RIGHT MODULE GREEN CLOSEOUT - 2026-04-09
- [x] HAUSHALTSBUCH sichtbarer rechter Bereich T:Z gruen abschliessen.
- [x] Aktuellen Workbook-Hash als Wahrheitsstand ziehen: BA63DFF24F1A7914CF246EA515057C632591B94D2C45D6A9C9A5DBD52DA58EE2
- [ ] Naechster exakter Schritt: SCAN_EXACT_WORKBOOKWIDE_REPRIORITIZATION_AFTER_HAUSHALTSBUCH_VISIBLE_SURFACE_GREEN_CLOSEOUT_UNDER_VERIFIED_STAGE_ONLY
- [ ] Danach erst neuen echten Excel-Scope oeffnen.
<!-- EGO_MANAGED_BLOCK: -->

<!-- EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_TODO_LOCK:START -->
## APRIL09 MASTERPASS HYBRID TODO LOCK
- [x] Aktiven Modus auf WORKBOOK_MASTERPASS / RECOVERY umstellen.
- [x] Aktuellen Workbook-Hash in die Wahrheitsdateien ziehen: B06765F9EBCB063EF50D29454BCD2FC34921FD2D99B4BD11C594E27AE8CF568F
- [x] Hash-Mismatch als harter STOP-vor-Apply-Zustand dokumentieren.
- [x] WORKBOOK_MASTERPASS / SHEET_FINALIZER / TOOL_REPAIR als getrennte Modi dokumentieren.
- [x] RequiredReads-Matrix und Runner-ValidateSets auf neue TaskTypes erweitern.
- [ ] Naechster exakter Schritt: SCAN_EXACT_CURRENT_WORKBOOK_HASH_AND_VISIBLE_SURFACE_TRUTH_AFTER_MASTERPASS_DRIFT
- [ ] Danach: Truth-Relock schreiben.
- [ ] Erst danach: WORKBOOK_MASTERPASS oder SHEET_FINALIZER gezielt fortsetzen.
<!-- EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_TODO_LOCK:END -->

<!-- EGO_PREMIUM_REDESIGN_V4_START -->
## 2026-04-11 — TODO / Premium Redesign V4

### P0 — jetzt
- [ ] START Dashboard-Finalizer
- [ ] MONAT Dashboard-Finalizer
- [ ] NOTGROSCHEN Dashboard-Finalizer
- [ ] JAHR Dashboard-Finalizer
- [ ] PLANUNG Dashboard-Finalizer

### P1 — danach
- [ ] PARAMETER Finalizer
- [ ] HAUSHALTSBUCH Finalizer
- [ ] BUDGETS Finalizer
- [ ] FIXKOSTEN Finalizer
- [ ] LISTEN Finalizer
- [ ] SCHULDEN Finalizer

### P2 — danach
- [ ] AUDIT Finalizer
- [ ] MONATSABSCHLUSS Finalizer
- [ ] BEDIENUNG Finalizer
- [ ] LIZENZ Finalizer
- [ ] STEUER Finalizer
- [ ] SPARZIELE Finalizer
<!-- EGO_PREMIUM_REDESIGN_V4_END -->
