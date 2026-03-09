# Required Reads Enforcement Policy

## Status

Die Required-Reads-Logik ist nicht nur Governance, sondern technisch verpflichtend.

## Pflicht

Vor relevanten Arbeiten ist der Preflight auszuführen:

`_INTERN\tools\knowledge-required-reads-preflight.ps1`

## Mindestanforderungen

- TaskType muss angegeben werden
- TASK_REQUIRED_READS_MATRIX.tsv muss vorhanden sein
- alle Required Reads müssen auflösbar und vorhanden sein
- ein Run-Report muss geschrieben werden
- bei Fehlern wird hart abgebrochen

## Ziel

Kein Arbeiten mehr auf Basis von Vermutung oder unvollständigem Kontext.