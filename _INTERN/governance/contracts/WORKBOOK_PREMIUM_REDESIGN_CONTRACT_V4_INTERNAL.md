# WORKBOOK PREMIUM REDESIGN CONTRACT V4 (INTERNAL)

Stand: 2026-04-11  
Status: verbindlich  
Primäre visuelle Leitinstanz: Claude  
Käufer-/Preis-/Premium-Gate: Grok  
DeepSeek: nur sekundäre Hilfsquelle, kein Primärvertrag

## Zweck

Dieser Vertrag ersetzt den unsauberen generischen Workbook-Masterpass als Hauptsteuerung.
Ab sofort gilt:

- zuerst harte Invarianten workbookweit,
- danach nur noch blattspezifische Finalizer nach Sheet-Typ,
- keine pauschalen Vollumbauten mehr ohne expliziten Vertrag und sichtbare Screenshot-Abnahme.

## Bekannte Failure-Klassen aus den letzten Läufen

- FAILED_WORKBOOK_MASTERPASS_HARD_CROP_AND_PANEL_TRUNCATION
- ACTIVEWINDOW_ZOOM_PERSISTENCE_AFTER_WORKBOOK_MASTERPASS_V2
- PARTIAL_FAILED_MASTERPASS_V3_STATE_ROLLED_BACK
- FALSE_LOCAL_CLOSEOUT_AFTER_LOCAL_PDF_CROP
- generische workbookweite Redesign-Applies ohne ausreichend enge Typ-/Viewport-Verträge

## Harte Invarianten

1. Jedes Blatt öffnet auf **100 % Zoom**.
2. Kein `Fit to Window`, kein Zoom-Trick, kein Hard-Crop.
3. Gridlines bleiben aus.
4. Freeze-Panes nur mit `A...`, niemals mit `B...` oder weiter rechts.
5. Zeilenhöhen-Hierarchie ist fest:
   - Header: 32 pt
   - Section: 26 pt
   - Column Header: 22 pt
   - Data: 20 pt
   - Spacer: 6 pt
6. Info-Panel ist ein fixes Designelement und nicht pro Blatt frei improvisiert.
7. Sichtbare Hilfs-/Systemspalten sind verboten.
8. Tote rechte Restflächen sind aktiv zu minimieren.
9. Workbook-Masterpass darf nur noch Invarianten setzen.
10. Layout-/Premium-Wirkung entsteht danach nur noch über Sheet-Finalizer.

## Sheet-Typen

### Dashboard
- START
- MONAT
- JAHR
- NOTGROSCHEN
- PLANUNG

### Eingabe
- PARAMETER
- LISTEN
- HAUSHALTSBUCH
- BUDGETS
- FIXKOSTEN
- SCHULDEN

### Review / Kontrolle
- AUDIT
- MONATSABSCHLUSS

### Info / Verpackung
- BEDIENUNG
- LIZENZ
- STEUER
- SPARZIELE

## Freeze-Map

- START -> A5
- PARAMETER -> A3
- LIZENZ -> A3
- LISTEN -> A4
- HAUSHALTSBUCH -> A4
- MONAT -> A4
- BUDGETS -> A4
- JAHR -> A6
- FIXKOSTEN -> A4
- BEDIENUNG -> A4
- NOTGROSCHEN -> A3
- PLANUNG -> A6
- AUDIT -> A8
- SCHULDEN -> A10
- MONATSABSCHLUSS -> A9
- STEUER -> A4
- SPARZIELE -> A4

## Ausführungsreihenfolge nach diesem Sync

1. START Finalizer
2. MONAT Finalizer
3. NOTGROSCHEN Finalizer
4. JAHR Finalizer
5. PLANUNG Finalizer

Erst nach sauberer Screenshot-Abnahme dieser fünf Dashboard-Blätter folgen:

6. PARAMETER
7. HAUSHALTSBUCH
8. BUDGETS
9. FIXKOSTEN
10. LISTEN
11. SCHULDEN
12. AUDIT
13. MONATSABSCHLUSS
14. BEDIENUNG
15. LIZENZ
16. STEUER
17. SPARZIELE

## Verbotene Muster

- generischer workbookweiter Premium-Vollumbau ohne strikten Typvertrag
- Fit-to-Window
- Zoom ungleich 100 %
- Mini-Spacer unter 6 pt
- sichtbare technische Hilfsspalten
- Anleitung doppelt in mehreren Blättern
- große rechte schwarze Wüste als sichtbares Endergebnis
- „A-M für alle Blätter“ als blindes Globalgesetz
- „AO sichtbar für alle Blätter“ als blindes Globalgesetz

## OpenPyXL-Basis für den Vertrag

Die Invarianten sind technisch an folgende reale Steuerpunkte gekoppelt:

- `ws.sheet_view.zoomScale`
- `ws.sheet_view.showGridLines`
- `ws.freeze_panes`
- `ws.row_dimensions[...].height`
- `ws.column_dimensions[...].width`

## Nächster Modus

Aktiver Nachfolgemodus nach diesem Sync:

`DASHBOARD_FINALIZER_START`
