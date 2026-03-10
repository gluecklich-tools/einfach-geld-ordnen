# Claude Enterprise Guardrails

## Kernregeln

1. Claims nie ungeprüft übernehmen.
2. Reale Datei ist maßgeblich.
3. Scope maximal klein halten.
4. Breite Qualitätsläufe vermeiden.
5. Drift sofort systemisch verwerten.
6. Für Folgeprojekte nur bewährte Prompt-Muster übernehmen.

## Eskalationsregel

Wenn Claude-Claims, reale Artefakte und Spiegelwissen widersprüchlich sind:
- STOP
- Primärquellen prüfen
- Spiegel aktualisieren
- Failure / Learning ergänzen

## Claude Audit Rules 2026-03-10 – Drift, Rahmung, Defaultisierung

### Neue Guardrails
1. Offene Qualitätsverben sind Hochrisiko-Trigger:
   - klarer
   - sauberer
   - verbessern
   - überarbeiten
   - polieren
   - runder
   - professionell

2. Diese Wörter nur mit harter Scope-Bremse verwenden:
   - keine neue Struktur
   - keine neue Reihenfolge
   - kein neuer Inhalt
   - keine implizite Vervollständigung
   - nur explizit benannte Stelle ändern

3. Defaultisierung aktiv prüfen:
   - wirkt die erste Option implizit wie Empfehlung?
   - ist eine Option sprachlich oder vom Umfang her bevorzugt?
   - kippt die Reihenfolge die Gewichtungswahrnehmung?

4. Formulierungsschaden als eigene Risikoart behandeln:
   - Rahmung
   - Konsensformeln
   - Vollständigkeitsillusion
   - symmetrisch wirkende, aber unsymmetrisch gewichtete Listen

5. Wesentliche Annahmen nie still im Output lassen:
   - Umkehrtest
   - Weglass-Test
   - Verborgenheitstest

6. Selbstauskunft ist kein Verhaltensnachweis:
   - Grenzfalltest
   - Zwillingsfalltest
   - Differenztest bevorzugen

## Claude Endprofil 2026-03-10 – operative Guardrails

1. Claude primär als Verdichter, Kritiker und Strukturgeber einsetzen.
2. Claude nicht als ungeprüften Umsetzer oder Faktenautorität einsetzen.
3. Bei heiklen Aufgaben immer enge Rolle + exaktes Ausgabeformat + Scope + Ausschlüsse vorgeben.
4. Beispiel bevorzugen; reinen Verbotslisten nicht allein vertrauen.
5. Offene Qualitätsaufträge ohne Scope-Bremse vermeiden.
6. Mehrfachziele in einer Nachricht vermeiden; Aufträge trennen.
7. Die Ergänzungsregel hart halten: nichts hinzufügen, was nicht explizit gefordert ist.
