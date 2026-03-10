# Claude Work Guard Policy

## Pflicht

Vor jeder Claude-bezogenen Arbeit ist zusätzlich zum allgemeinen Required-Reads-Preflight der Claude Work Guard auszuführen.

## Gilt für
- Claude-Prompting
- Produkt-Loop mit Claude
- Bewertung von Claude-Ergebnissen
- Folgeprojekt-Arbeit mit Claude

## Harte Regeln
1. Keine Claude-Arbeit ohne Claude Work Guard.
2. Keine nächste Seite ohne reale Freigabe der aktuellen Seite.
3. Keine Freigabe auf Basis von Claude-Claims.
4. Premium-Ziele nur über Mikro-Loops.

## Technischer Einstieg
`_INTERN\tools\claude-work-guard.ps1`

## Claude Audit Enforcement 2026-03-10

### Operative Arbeitsregeln
1. Bei Text-, Produkt- oder Dateiarbeit keine stillen Glättungen außerhalb des expliziten Auftrags.
2. Kein Schluss ergänzen, keine Liste vervollständigen, keine Reihenfolge "reparieren", wenn das nicht ausdrücklich verlangt wurde.
3. Objektiver Fehler ist nicht gleich subjektive Unklarheit:
   - objektiver Fehler -> eher korrigierbar
   - subjektive Unklarheit -> eher offenlegen
   - bloßer Eindruck von Unvollständigkeit -> eher Drift
4. Empfehlung nur mit offengelegter Referenzklassen- oder Nutzergruppen-Annahme.
5. Claude-Ausgaben im Zweifel gegen Scope, Rahmung und Defaultisierung prüfen.
6. Für EGO: Claude eher für Diagnose, Zielbild, Kritik und Risiko-Markierung; deterministische Umsetzung weiter file-first/script-basiert.

## Claude Endprofil 2026-03-10 – Arbeitsmodus

### Empfohlener Einsatz
- analysieren
- verdichten
- kritisieren
- strukturieren
- Risiken markieren

### Nicht bevorzugter Einsatz
- faktische Letztprüfung
- autonome Endumsetzung
- rechtliche, medizinische, finanzielle oder sicherheitskritische Prüferrolle
- breite Generalistenrolle mit offenen Qualitätszielen

### Prompt-Rahmen
Rolle: enge Fachrolle
Aufgabe: genau eine Sache
Ausgabe: exaktes Format / Länge / Struktur
Scope: explizit benannt
Ausschlüsse: explizit benannt
Wenn unklar: fragen, nicht ergänzen
Keine Kommentare oder Empfehlungen außerhalb der Ausgabe
