#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)]
  [string]$BaseUrl = "https://gluecklich-tools.github.io",
  [Parameter(Mandatory=$false)]
  [string]$ProjectBase = "/einfach-geld-ordnen",
  [Parameter(Mandatory=$false)]
  [string]$OutPath = "",
  [Parameter(Mandatory=$false)]
  [int]$HttpTimeoutSec = 20,
  [Parameter(Mandatory=$false)]
  [switch]$DoHttp200
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if ($IsWindows) { try { chcp 65001 | Out-Null } catch {} }
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# Repo root = parent of /tools
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

  # frontmatter must start at line 1 with ---
  if (-not $Text.StartsWith("---")) { return $null }

  $lines = $Text -split "`n"
  if ($lines.Length -lt 3) { return $null }
  if ($lines[0].Trim() -ne "---") { return $null }

  $end = -1
  for ($i=1; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Trim() -eq "---") { $end = $i; break }
  }
  if ($end -lt 0) { return $null }

  for ($j=1; $j -lt $end; $j++) {
    $ln = $lines[$j].Trim()
    if ($ln -match '^\s*permalink\s*:\s*(.+)\s*$') {
      $val = $Matches[1].Trim()
      # strip quotes if present
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

  # allowlist only: seiten/* and pillar/*
  if ($p -notmatch '^(seiten|pillar)/') { return $null }

  # remove extension
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

  # ensure .html
  if (-not $pl.EndsWith(".html")) { $pl = $pl.TrimEnd("/") + ".html" }

  # ensure project base present
  if ($pb -ne "" -and -not $pl.StartsWith($pb + "/") -and $pl -ne $pb) {
    $pl = $pb + $pl
  }

  return (Normalize-UrlJoin -a $BaseUrl -b $pl)
}

function Try-Http200 {
  param([string]$Url)
  try {
    $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -MaximumRedirection 5 -TimeoutSec $HttpTimeoutSec
    return [pscustomobject]@{ Ok = ($r.StatusCode -eq 200); Status = [int]$r.StatusCode }
  } catch {
    return [pscustomobject]@{ Ok = $false; Status = -1 }
  }
}

$ProjectBase = Normalize-ProjectBase -p $ProjectBase

# output path
if ([string]::IsNullOrWhiteSpace($OutPath)) {
  $auditDir = Join-Path $RepoRoot 'assets\audit\live_checklist'
  New-Item -ItemType Directory -Force -Path $auditDir | Out-Null
  $OutPath = Join-Path $auditDir ('live_checklist_' + (Get-Date).ToString('yyyyMMdd-HHmmss') + '.md')
} else {
  $parent = Split-Path -Parent $OutPath
  if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
}

# gather allowlist files
$files = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Force |
  Where-Object {
    ($_.Extension -in @('.md','.markdown')) -and
    ((($_.FullName.Replace('\','/')) -notlike '*/_site/*')) -and
(($_.FullName.Replace('\','/')) -notlike '*/assets/audit/*') -and
    ((($_.FullName.Replace('\','/')) -notlike '*/_audit/*')) -and
((($_.FullName.Replace('\','/')) -notlike '*/_local/*'))
(($_.FullName.Replace('\','/')) -like '*/seiten/*' -or (($_.FullName.Replace('\','/')) -like '*/pillar/*'))
  }

$rows = New-Object System.Collections.Generic.List[object]
foreach ($f in $files) {
  $rel = $f.FullName.Substring($RepoRoot.Length).TrimStart('\','/').Replace('\','/')
  $txt = [IO.File]::ReadAllText($f.FullName, [Text.UTF8Encoding]::new($false))
  $pl = Get-FrontmatterPermalink -Text $txt
  if ([string]::IsNullOrWhiteSpace($pl)) { $pl = Derive-PermalinkFromPath -RelPath $rel }
  $url = $null
  if (-not [string]::IsNullOrWhiteSpace($pl)) { $url = Make-LiveUrl -Permalink $pl -BaseUrl $BaseUrl -ProjectBase $ProjectBase }

  $rows.Add([pscustomobject]@{
    RelPath = $rel
    Permalink = $pl
    LiveUrl = $url
  }) | Out-Null
}

# sort, dedupe by LiveUrl
$sorted = $rows | Where-Object { -not [string]::IsNullOrWhiteSpace($_.LiveUrl) } | Sort-Object LiveUrl -Unique

$out = New-Object System.Collections.Generic.List[string]
$out.Add('# Live-Checkliste (EGO) – pro Seite') | Out-Null
$out.Add('') | Out-Null
$out.Add(('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))) | Out-Null
$out.Add(('BaseUrl: ' + $BaseUrl)) | Out-Null
$out.Add(('ProjectBase: ' + $ProjectBase)) | Out-Null
$out.Add(('ALLOWLIST: seiten + pillar')) | Out-Null
$out.Add('') | Out-Null

$out.Add('## Globaler Preflight (einmal pro Release)') | Out-Null
$out.Add('') | Out-Null
$out.Add('- [ ] Lokal: `pwsh -NoProfile -File tools/klaus-run.ps1` -> alles PASS') | Out-Null
$out.Add('- [ ] GitHub Actions: letzter Run gruen') | Out-Null
$out.Add('- [ ] Live Startseite Inkognito + Strg+F5: `https://gluecklich-tools.github.io/einfach-geld-ordnen/`') | Out-Null
$out.Add('- [ ] Stichprobe 3–5 Kernseiten klickbar, keine 404') | Out-Null
$out.Add('') | Out-Null

$out.Add(('## Seitenliste (' + ($sorted | Measure-Object).Count + ')')) | Out-Null
$out.Add('') | Out-Null

foreach ($r in $sorted) {
  $url = $r.LiveUrl
  $rel = $r.RelPath

  $httpLine = ''
  if ($DoHttp200) {
    $h = Try-Http200 -Url $url
    $httpLine = (' (HTTP ' + $h.Status + ')')
  }

  $out.Add('---') | Out-Null
  $out.Add(('### [ ] Seite: ' + $url + $httpLine)) | Out-Null
  $out.Add(('Datei: `' + $rel + '`')) | Out-Null
  $out.Add('') | Out-Null

  $out.Add('#### Erreichbarkeit & Status') | Out-Null
  $out.Add('- [ ] Laedt ohne Fehler') | Out-Null
  $out.Add('- [ ] HTTP 200 (Network/Invoke-WebRequest)') | Out-Null
  $out.Add('') | Out-Null

  $out.Add('#### Rendering / Frontmatter') | Out-Null
  $out.Add('- [ ] Kein Frontmatter im sichtbaren HTML') | Out-Null
  $out.Add('- [ ] Layout/Styling ok') | Out-Null
  $out.Add('') | Out-Null

  $out.Add('#### MVP-02 Navigation (ohne Sackgassen)') | Out-Null
  $out.Add('- [ ] `## Weiter` vorhanden') | Out-Null
  $out.Add('- [ ] Genau 3 interne Links im Weiter-Block') | Out-Null
  $out.Add('- [ ] Alle 3 Links fuehren auf existierende Seiten') | Out-Null
  $out.Add('- [ ] No-Sackgasse-Footer vorhanden') | Out-Null
  $out.Add('') | Out-Null

  $out.Add('#### Link-Qualitaet (Killer)') | Out-Null
  $out.Add('- [ ] Keine `.md` Links') | Out-Null
  $out.Add('- [ ] Kein Trailing-Slash-Link auf interne Seiten') | Out-Null
  $out.Add('- [ ] Interne Links baseurl + `.html`') | Out-Null
  $out.Add('- [ ] Keine TODO/Platzhalterlinks') | Out-Null
  $out.Add('') | Out-Null

  $out.Add('#### Inhalt & UX') | Out-Null
  $out.Add('- [ ] H1 passt, Einleitung klar') | Out-Null
  $out.Add('- [ ] Naechster Schritt vorhanden (Download/Rechner/Checkliste)') | Out-Null
  $out.Add('- [ ] Mobilansicht ok (DevTools)') | Out-Null
  $out.Add('') | Out-Null

  $out.Add('#### Ergebnis') | Out-Null
  $out.Add('- [ ] PASS') | Out-Null
  $out.Add('- [ ] FAIL (Grund): __________________________') | Out-Null
  $out.Add('') | Out-Null
}

[IO.File]::WriteAllText($OutPath, ($out.ToArray() -join "`n"), [Text.UTF8Encoding]::new($false))
"OK: wrote " + $OutPath