# MODEL_COMPARISON_CLAUDE_VS_DEEPSEEK_2026-03-10

## Zweck
Operative Vergleichsmatrix für den Einsatz von Claude und DeepSeek im Projekt EGO.

## Kurzfazit
Claude und DeepSeek sind beide nützlich, aber für klar unterschiedliche Rollen. Claude ist stärker als Kritiker, Drift-/Guardrail-Reflektor und Qualitäts-/Rahmungsprüfer. DeepSeek ist stärker als Strukturgeber, Verdichter, Vergleicher und Sparringspartner.

## Claude

### Beste Rollen
- Kritiker
- Drift-/Guardrail-Analyse
- Risiko-Markierung
- Zielbild-/Qualitätskritik
- Rahmung / Defaultisierung / Scope-Risiken sichtbar machen

### Hauptrisiken
- wohlmeinende Klarheits-/Qualitäts-Drift
- offene Qualitätsverben als Trigger
- stille Politur / Mitverbesserung
- weiche Scope-Erweiterung
- Reihenfolge / Rahmung / Defaults als verdeckte Lenkung

### Beste Steuerung
- enge Rolle
- harte Scope-Bremse
- Beispiel
- exaktes Format
- "wenn unklar: fragen, nicht ergänzen"
- keine offenen Qualitätsverben ohne Zusatzgrenze

### Nicht bevorzugte Nutzung
- ungeprüfter Umsetzer
- Faktenautorität
- finaler Prüfer
- Generalist mit offenem Breitenauftrag

## DeepSeek

### Beste Rollen
- Strukturgeber
- Verdichter
- Sparringspartner
- Vergleicher
- Perspektivwechsel
- Problemordnung

### Hauptrisiken
- glatte Scheinsicherheit bei Fakten
- aktuelle Fakten / Echtzeitdaten / Zahlen / Quellen
- zu normativ-ordentliche Selbstdarstellung
- Drift bei vagen, offenen, kreativen oder philosophischen Prompts
- schnelle Verengung in professionellen Standard-/Engineering-Frame

### Beste Steuerung
- klare Einzelaufgabe
- konkreter Kontext
- festes Format
- enge Rolle
- Beispiel
- nur die gestellte Frage beantworten

### Nicht bevorzugte Nutzung
- Faktenautorität
- finaler Prüfer
- ungeprüfter Umsetzer
- offene Kreativrolle ohne harte Begrenzung

## Direkter Vergleich

### Wenn Kritik, Drift, Scope und Rahmung im Vordergrund stehen
Claude bevorzugen.

### Wenn Struktur, Verdichtung, Vergleich und Sparring im Vordergrund stehen
DeepSeek bevorzugen.

### Wenn Fakten, Zahlen oder Quellen kritisch sind
Keines von beiden blind vertrauen; externe Verifikation oder deterministische Pipeline nötig.

### Wenn final umgesetzt werden soll
Keines von beiden ungeprüft einsetzen; Umsetzung weiter file-first / script-basiert absichern.

## Operative Einsatzregel für EGO

### Claude bevorzugen bei
- Produktkritik
- Qualitäts-/Premium-Wirkung
- Prompt-/Guardrail-Reflexion
- Scope-/Drift-Prüfung
- sprachlicher Rahmungsanalyse

### DeepSeek bevorzugen bei
- Strukturierung unklarer Lage
- Verdichtung großer Gedankenmengen
- Vergleich von Optionen
- Sparring zu Konzepten
- Aufbau von Gliederungen / Gerüsten

## Harte Gesamtregel
Kein Modell als ungeprüfte Faktenautorität oder finalen Prüfer einsetzen. Modellnutzung ist wertvoll als Denk- und Strukturhilfe, nicht als automatische Endwahrheit.

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
