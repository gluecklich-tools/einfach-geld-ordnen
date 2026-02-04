#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)]
  [string]$OutPath = ""
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $RepoRoot

if ([string]::IsNullOrWhiteSpace($OutPath)) {
  $dir = Join-Path $RepoRoot 'assets\audit\live_checklist'
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $OutPath = Join-Path $dir ('live_check_explainer_' + (Get-Date).ToString('yyyyMMdd-HHmmss') + '.md')
} else {
  $parent = Split-Path -Parent $OutPath
  if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
}

$L = New-Object System.Collections.Generic.List[string]
$L.Add('# Live-Check Explainer (EGO) – Wie du jeden Haken prüfst') | Out-Null
$L.Add('') | Out-Null
$L.Add(('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))) | Out-Null
$L.Add('') | Out-Null
$L.Add('Diese Datei erklärt dir **konkret**, wie du die Punkte in der pro-Seite-Checkliste prüfst.') | Out-Null
$L.Add('') | Out-Null

$L.Add('## 0) Setup: immer gleich testen') | Out-Null
$L.Add('') | Out-Null
$L.Add('- Browser: **Inkognito** + **Strg+F5** (Cache aushebeln).') | Out-Null
$L.Add('- Bei komischen Effekten: zusätzlich **anderer Browser** (Edge/Firefox).') | Out-Null
$L.Add('- DevTools: F12 → Tabs: **Network**, **Console**, **Elements**.') | Out-Null
$L.Add('') | Out-Null

$L.Add('## Erreichbarkeit & Status') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Laedt ohne Fehler“') | Out-Null
$L.Add('- Seite öffnet ohne White-Screen, ohne „Page not found“, ohne kaputtes Layout.') | Out-Null
$L.Add('- DevTools → Console: keine roten Errors (Warnungen ok, aber anschauen).') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „HTTP 200“') | Out-Null
$L.Add('- DevTools → Network: Hauptdokument Status **200**.') | Out-Null
$L.Add('- Alternativ lokal: `Invoke-WebRequest` (macht dein Generator schon bei -DoHttp200).') | Out-Null
$L.Add('') | Out-Null

$L.Add('## Rendering / Frontmatter') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Kein Frontmatter im sichtbaren HTML“') | Out-Null
$L.Add('- Wenn du im Browser am Seitenanfang `---` oder `layout:` siehst: Frontmatter wird gerendert → **FAIL**.') | Out-Null
$L.Add('- Quick-Check: `view-source:` vor die URL setzen und laden.') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Layout/Styling ok“') | Out-Null
$L.Add('- Header/Footer vorhanden, Schrift/Abstände passen, keine ungestylten Listen/Buttons.') | Out-Null
$L.Add('- Mobile: DevTools → Toggle Device Toolbar → iPhone/Android Preset → nichts läuft über den Rand.') | Out-Null
$L.Add('') | Out-Null

$L.Add('## MVP-02 Navigation (ohne Sackgassen)') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „## Weiter vorhanden“') | Out-Null
$L.Add('- Scroll ans Ende: Abschnitt **## Weiter** muss sichtbar sein.') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Genau 3 interne Links“') | Out-Null
$L.Add('- Unter „## Weiter“ exakt **3** Links (keine 2, keine 4).') | Out-Null
$L.Add('- Es müssen interne Links sein (Projektseiten), nicht externe.') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Alle 3 Links führen auf existierende Seiten“') | Out-Null
$L.Add('- Jeden der 3 Links öffnen (neuer Tab) → Seite lädt, kein 404, URL passt.') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „No-Sackgasse-Footer vorhanden“') | Out-Null
$L.Add('- Unterhalb des Weiter-Blocks muss der No-Sackgasse-Footer sichtbar sein.') | Out-Null
$L.Add('') | Out-Null

$L.Add('## Link-Qualität (Killer)') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Keine .md Links“') | Out-Null
$L.Add('- Rechtsklick auf interne Links → Linkadresse prüfen: darf **nicht** auf `.md` enden.') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Kein Trailing-Slash auf interne Seiten“') | Out-Null
$L.Add('- Interne Ziel-URLs dürfen nicht wie `/seiten/name/` aussehen.') | Out-Null
$L.Add('- Richtig ist: `/einfach-geld-ordnen/seiten/name.html` (mit baseurl + `.html`).') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Interne Links baseurl + .html“') | Out-Null
$L.Add('- In der URL muss `/einfach-geld-ordnen/` drin sein.') | Out-Null
$L.Add('- Endung muss `.html` sein.') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Keine TODO/Platzhalterlinks“') | Out-Null
$L.Add('- Keine Links wie „coming soon“, „TODO“, „Platzhalter“, „Beispiel“.') | Out-Null
$L.Add('- Wenn ein Link ins Leere führt: entweder Seite bauen oder Link entfernen.') | Out-Null
$L.Add('') | Out-Null

$L.Add('## Inhalt & UX') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „H1 passt, Einleitung klar“') | Out-Null
$L.Add('- H1 ist eindeutig (Thema der Seite) und Einleitung sagt in 2–4 Sätzen, was der Leser hier bekommt.') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Nächster Schritt vorhanden“') | Out-Null
$L.Add('- Auf jeder Seite muss klar sein, was als nächstes zu tun ist (Download/Rechner/Checkliste/konkreter Schritt).') | Out-Null
$L.Add('') | Out-Null
$L.Add('### „Mobilansicht ok“') | Out-Null
$L.Add('- DevTools Mobile: keine horizontale Scrollbar, Buttons/Links gut anklickbar, Text nicht winzig.') | Out-Null
$L.Add('') | Out-Null

[IO.File]::WriteAllText($OutPath, ($L.ToArray() -join "`n"), [Text.UTF8Encoding]::new($false))
"OK: wrote " + $OutPath