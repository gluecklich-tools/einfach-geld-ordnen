#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)]
  [string]$BaseUrl = "https://gluecklich-tools.github.io",
  [Parameter(Mandatory=$false)]
  [string]$ProjectBase = "/einfach-geld-ordnen",
  [Parameter(Mandatory=$false)]
  [string]$OutPath = ""
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if ($IsWindows) { try { chcp 65001 | Out-Null } catch {} }
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $RepoRoot

function Normalize-ProjectBase {
  param([string]$p)
  $x = ($p ?? "").Trim()
  if ([string]::IsNullOrWhiteSpace($x)) { return "" }
  if (-not $x.StartsWith("/")) { $x = "/" + $x }
  if ($x.EndsWith("/")) { $x = $x.TrimEnd("/") }
  return $x
}
function Normalize-UrlJoin {
  param([string]$a, [string]$b)
  $aa = ($a ?? "").TrimEnd("/")
  $bb = ($b ?? "")
  if (-not $bb.StartsWith("/")) { $bb = "/" + $bb }
  return $aa + $bb
}
function Get-FrontmatterPermalink {
  param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
  if (-not $Text.StartsWith("---")) { return $null }
  $lines = $Text -split "`n"
  if ($lines.Length -lt 3) { return $null }
  if ($lines[0].Trim() -ne "---") { return $null }
  $end = -1
  for ($i=1; $i -lt $lines.Length; $i++) { if ($lines[$i].Trim() -eq "---") { $end = $i; break } }
  if ($end -lt 0) { return $null }
  for ($j=1; $j -lt $end; $j++) {
    $ln = $lines[$j].Trim()
    if ($ln -match '^\s*permalink\s*:\s*(.+)\s*$') {
      $val = $Matches[1].Trim()
      if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
        $val = $val.Substring(1, $val.Length-2)
      }
      if (-not [string]::IsNullOrWhiteSpace($val)) { return $val }
    }
  }
  return $null
}
function Derive-PermalinkFromPath {
  param([string]$RelPath)
  $p = ($RelPath ?? "").Replace("\","/").TrimStart("/")
  if ([string]::IsNullOrWhiteSpace($p)) { return $null }
  if ($p -notmatch '^(seiten|pillar)/') { return $null }
  if ($p.EndsWith(".md")) { $p = $p.Substring(0, $p.Length-3) }
  elseif ($p.EndsWith(".markdown")) { $p = $p.Substring(0, $p.Length-9) }
  return ("/" + $p + ".html")
}
function Make-LiveUrl {
  param([string]$Permalink, [string]$BaseUrl, [string]$ProjectBase)
  $pb = Normalize-ProjectBase -p $ProjectBase
  $pl = ($Permalink ?? "").Trim()
  if ([string]::IsNullOrWhiteSpace($pl)) { return $null }
  if (-not $pl.StartsWith("/")) { $pl = "/" + $pl }
  if (-not $pl.EndsWith(".html")) { $pl = $pl.TrimEnd("/") + ".html" }
  if ($pb -ne "" -and -not $pl.StartsWith($pb + "/") -and $pl -ne $pb) { $pl = $pb + $pl }
  return (Normalize-UrlJoin -a $BaseUrl -b $pl)
}

$ProjectBase = Normalize-ProjectBase -p $ProjectBase

if ([string]::IsNullOrWhiteSpace($OutPath)) {
  $dir = Join-Path $RepoRoot 'assets\audit\live_checklist_manual'
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $OutPath = Join-Path $dir ('live_checklist_manual_' + (Get-Date).ToString('yyyyMMdd-HHmmss') + '.md')
} else {
  $parent = Split-Path -Parent $OutPath
  if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
}

$files = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Force |
  Where-Object {
    ($_.Extension -in @('.md','.markdown')) -and
    ((($_.FullName -replace '\\\\','/') -notlike '*/_site/*')) -and
(($_.FullName -replace '\','/') -notlike '*/assets/audit/*') -and
    ((($_.FullName -replace '\\\\','/') -notlike '*/_audit/*')) -and
(($_.FullName -replace '\','/') -notlike '*/_local/*') -and
(($_.FullName -replace '\','/') -like '*/seiten/*' -or (($_.FullName -replace '\','/') -like '*/pillar/*'))
  }

$rows = New-Object System.Collections.Generic.List[object]
foreach ($f in $files) {
  $rel = $f.FullName.Substring($RepoRoot.Length).TrimStart('\','/').Replace('\','/')
  $txt = [IO.File]::ReadAllText($f.FullName, [Text.UTF8Encoding]::new($false))
  $pl = Get-FrontmatterPermalink -Text $txt
  if ([string]::IsNullOrWhiteSpace($pl)) { $pl = Derive-PermalinkFromPath -RelPath $rel }
  $url = $null
  if (-not [string]::IsNullOrWhiteSpace($pl)) { $url = Make-LiveUrl -Permalink $pl -BaseUrl $BaseUrl -ProjectBase $ProjectBase }
  if (-not [string]::IsNullOrWhiteSpace($url)) {
    $rows.Add([pscustomobject]@{ RelPath=$rel; LiveUrl=$url }) | Out-Null
  }
}

$sorted = $rows | Sort-Object LiveUrl -Unique

$L = New-Object System.Collections.Generic.List[string]
$L.Add('# MANUAL Live-Abnahme (EGO) – pro Seite (was Klaus nicht kann)') | Out-Null
$L.Add('') | Out-Null
$L.Add(('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))) | Out-Null
$L.Add('') | Out-Null
$L.Add('Setup: Inkognito + Strg+F5. DevTools: Console + Network + Mobile Toggle.') | Out-Null
$L.Add('') | Out-Null
$L.Add(('## Seitenliste (' + ($sorted | Measure-Object).Count + ')')) | Out-Null
$L.Add('') | Out-Null

foreach ($r in $sorted) {
  $L.Add('---') | Out-Null
  $L.Add(('### [ ] Seite (MANUAL): ' + $r.LiveUrl)) | Out-Null
  $L.Add(('Datei: `' + $r.RelPath + '`')) | Out-Null
  $L.Add('') | Out-Null

  $L.Add('#### Inhalt & Klarheit (Redaktion)') | Out-Null
  $L.Add('- [ ] H1 sagt exakt, worum es geht (keine Überraschung).') | Out-Null
  $L.Add('- [ ] Einleitung (2–4 Sätze) erklärt Nutzen + Zielgruppe + Ergebnis.') | Out-Null
  $L.Add('- [ ] Keine widersprüchlichen Aussagen / keine Dopplungen / keine „vielleicht“-Schwammigkeit.') | Out-Null
  $L.Add('- [ ] Beispiele/Schritte sind konkret (keine leeren Versprechen).') | Out-Null
  $L.Add('') | Out-Null

  $L.Add('#### UX / „Fertigkeitsgefühl“') | Out-Null
  $L.Add('- [ ] Layout wirkt konsistent (Abstände, Überschriften, Listen, Buttons).') | Out-Null
  $L.Add('- [ ] Links sind klar benannt (kein „hier klicken“ ohne Kontext).') | Out-Null
  $L.Add('- [ ] Keine visuellen „Brüche“: komische Zeilenumbrüche, kaputte Tabellen, zu lange Zeilen.') | Out-Null
  $L.Add('') | Out-Null

  $L.Add('#### Mobile / Responsive (muss man sehen)') | Out-Null
  $L.Add('- [ ] Mobile Ansicht: keine horizontale Scrollbar, nichts läuft über den Rand.') | Out-Null
  $L.Add('- [ ] Buttons/Links gut antippbar, Textgröße angenehm.') | Out-Null
  $L.Add('- [ ] Mindestens 2 Presets prüfen: iPhone + Android.') | Out-Null
  $L.Add('') | Out-Null

  $L.Add('#### Browser-Praxis (Realität)') | Out-Null
  $L.Add('- [ ] Chrome/Edge ok.') | Out-Null
  $L.Add('- [ ] Zweitbrowser (Firefox) stichprobenhaft ok.') | Out-Null
  $L.Add('- [ ] Kein „Cache-Geisterproblem“ nach Strg+F5/Inkognito.') | Out-Null
  $L.Add('') | Out-Null

  $L.Add('#### Vertrauen / Recht / Transparenz (nur Sichtprüfung)') | Out-Null
  $L.Add('- [ ] Wenn es Aussagen zu „Sparen/Schulden“ gibt: Ton ist sauber, keine Garantien, keine Übertreibung.') | Out-Null
  $L.Add('- [ ] Externe Links: führen auf seriöse Ziele und passen zum Kontext.') | Out-Null
  $L.Add('') | Out-Null

  $L.Add('#### Ergebnis') | Out-Null
  $L.Add('- [ ] PASS') | Out-Null
  $L.Add('- [ ] FAIL (Grund): __________________________') | Out-Null
  $L.Add('') | Out-Null
}

[IO.File]::WriteAllText($OutPath, ($L.ToArray() -join "`n"), [Text.UTF8Encoding]::new($false))
"OK: wrote " + $OutPath