# EGO Projektstatus

UPDATED=2026-06-05 12:28:02

## Current Truth

Der oeffentliche EGO-Website-Hauptweg ist live sauber und shop-ready vorbereitet.

Gepruefter Hauptweg:

- Startseite
- Freebie
- Downloads
- Versionen & Preise
- Pro / Vollversion

Letzter Website-Smoke-Test:

- alle 5 Kernseiten: HTTP 200
- Freebie-Download: HTTP 200
- keine sichtbaren Liquid-/Include-Reste
- keine alten START_HIER-/Vorschau-Bilder-/Markdown-Tabellenreste
- Git-Status nach Website-Arbeit: leer

## Shop-Status

Shop-Button-Logik ist vorbereitet:

- _data/shop_links.yml
- _includes/ego-shop-button.html

Solange echte Shop-Links leer sind, zeigen Buttons bewusst Fallbacks wie ansehen oder vergleichen.

Keine Fake-Kaufbuttons.
Keine erfundenen Bewertungen.
Keine erfundenen Nutzerzahlen.

Naechster Shop-Schritt:

1. Kaufplattform waehlen.
2. Produkte dort anlegen.
3. echte Shop-Links in _data/shop_links.yml eintragen.
4. Kaufbutton-Live-Test durchfuehren.

## Produktlinie

Aktuelle Preislogik:

- Freebie Budgetstarter: 0 EUR
- Basic PC: 29 EUR
- Basic Android APK: 29 EUR
- Basic Bundle PC + Android: 39 EUR
- Pro PC / Vollversion: 59 EUR
- Pro Android APK: 59 EUR
- Pro Bundle PC + Android: 89 EUR

## Offene Produktpunkte

P0 offen:

- Basic Android APK als eigene APK erstellen.
- Produktpakete final pruefen.
- Begrifflichkeit App/Pakete vereinheitlichen: Daten-Datei statt irrefuehrend Excel-Datei, sofern technisch keine echte XLSX-Datei gemeint ist.
- Echte Shop-/Checkout-Links eintragen.
- Kaufstrecke live testen.

## Workbook / Excel-Stand

Die Excel-Workbook-Spur ist nicht final abgenommen.

Wichtige Learnings:

- Reale Excel-Oeffnung, Screenshot und Nutzerurteil schlagen jeden Report.
- Excel-Reparaturmeldung = sofort FAIL.
- Technik-Gates wie ZIP/XML/Formelscan sind nur Mindestbedingungen.
- Keine FINAL-/LOCK-/VISUAL_LOCK-/verkaufsfertig-Behauptung ohne echte Nutzerabnahme.
- Keine grossen neuen Workbook-Rebuild-Schleifen ohne klaren Einzelbereich.
- Wenn Workbook wieder aktiv wird: zuerst START, BEDIENUNG und HAUSHALTSBUCH als Musterblaetter loesen.

## Nicht aktiv

- Lizenzschutz / Workbook-DRM
- iOS
- neue Feature-Schleifen
- Fake-Social-Proof
- Kaufbuttons ohne echten Checkout

## Naechste Prioritaet

1. Dokumente und Tools synchron halten.
2. Projektordner aufraeumen.
3. Kaufplattform entscheiden.
4. Produktpakete pruefen.
5. Basic APK erstellen.
6. Shop-Links eintragen und Live-Kaufstrecke testen.
