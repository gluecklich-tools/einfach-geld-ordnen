param(
  [string]$RepoRoot = "",
  [string]$BundleRelDir = "downloads/bundles",
  [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function StopBad([string]$msg){ throw $msg }

if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
  if([string]::IsNullOrWhiteSpace($RepoRoot)){ StopBad "STOP: RepoRoot not found via git." }
}
if(!(Test-Path -LiteralPath $RepoRoot)){ StopBad "STOP: RepoRoot path missing: $RepoRoot" }
Set-Location -LiteralPath $RepoRoot

# --- ZIP helper (no external deps) ---
try{ Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null }catch{}

function New-BundleReadme([string]$BaseName){
@"
README_START_HIER.txt

Paket: $BaseName

Inhalt:
- XLSX (Excel)
- ODS (LibreOffice)

Hinweise:
- Self-Serve: offline nutzbar, einmaliger Download.
- Keine Updates/kein Support/kein Service-Versprechen.
- Dateien lokal speichern und in deinem Programm oeffnen.

Zeilenlimits (Orientierung):
- Freebie: 5.000
- Pro:    10.000
- Voll:   20.000
"@
}

function Get-Rel([string]$abs){
  $p = [IO.Path]::GetFullPath($abs)
  $r = [IO.Path]::GetFullPath($RepoRoot)
  if(!$p.StartsWith($r, [StringComparison]::OrdinalIgnoreCase)){ return $abs }
  $rel = $p.Substring($r.Length).TrimStart('\','/')
  return ($rel -replace '\\','/')
}

# --- Find candidate spreadsheet files (.ods/.xlsx) ---
$all = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -EA Stop |
  Where-Object {
    $_.Extension -in @(".ods",".xlsx") -and
    $_.FullName -notmatch "\\.git\\" -and
    $_.FullName -notmatch "\\_local\\" -and
    $_.FullName -notmatch "\\node_modules\\"
  }

if(@($all).Count -eq 0){
  StopBad "STOP: No .ods/.xlsx found in repo (excluding _local/.git)."
}

# Pair by base name (same directory + same filename without ext)
$pairs = @{}
foreach($f in $all){
  $dir = $f.DirectoryName
  $base = [IO.Path]::GetFileNameWithoutExtension($f.Name)
  $key  = ($dir + "||" + $base)
  if(-not $pairs.ContainsKey($key)){
    $pairs[$key] = [ordered]@{
      Dir = $dir
      Base = $base
      ODS = $null
      XLSX = $null
    }
  }
  if($f.Extension -eq ".ods"){  $pairs[$key].ODS  = $f.FullName }
  if($f.Extension -eq ".xlsx"){ $pairs[$key].XLSX = $f.FullName }
}

$good = @($pairs.Values | Where-Object { $_.ODS -and $_.XLSX })
if($good.Count -eq 0){
  StopBad "STOP: Found spreadsheets, but no matching ODS+XLSX pairs with same base name in same folder."
}

# --- Bundle output dir (inside repo) ---
$bundleDirAbs = Join-Path $RepoRoot ($BundleRelDir -replace '/','\')
New-Item -ItemType Directory -Path $bundleDirAbs -Force | Out-Null

# --- Build ZIPs ---
$built = New-Object System.Collections.Generic.List[object]
foreach($p in $good){
  $zipName = ($p.Base + ".zip")
  # ASCII-only filename safety (project law)
  if($zipName -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_\-\.]*\.zip$'){
    # try to auto-sanitize (conservative)
    $san = ($p.Base -replace '[^a-zA-Z0-9_\-]','_')
    $zipName = ($san + ".zip")
  }

  $zipAbs = Join-Path $bundleDirAbs $zipName

  $odsAbs  = $p.ODS
  $xlsxAbs = $p.XLSX

  $readmeTxt = New-BundleReadme -BaseName $p.Base

  if($WhatIf){
    [pscustomobject]@{
      ZIP = Get-Rel $zipAbs
      ODS = Get-Rel $odsAbs
      XLSX = Get-Rel $xlsxAbs
      README = "README_START_HIER.txt"
    } | Out-Host
    continue
  }

  if(Test-Path -LiteralPath $zipAbs){ Remove-Item -LiteralPath $zipAbs -Force }

  $tmp = Join-Path $env:TEMP ("ego_bundle_" + [guid]::NewGuid().ToString("N"))
  New-Item -ItemType Directory -Path $tmp -Force | Out-Null

  try{
    Copy-Item -LiteralPath $odsAbs  -Destination (Join-Path $tmp ([IO.Path]::GetFileName($odsAbs)))  -Force
    Copy-Item -LiteralPath $xlsxAbs -Destination (Join-Path $tmp ([IO.Path]::GetFileName($xlsxAbs))) -Force

    $readmePath = Join-Path $tmp "README_START_HIER.txt"
    [IO.File]::WriteAllText($readmePath, $readmeTxt, [Text.UTF8Encoding]::new($false))

    [IO.Compression.ZipFile]::CreateFromDirectory($tmp, $zipAbs, [IO.Compression.CompressionLevel]::Optimal, $false) | Out-Null
  }
  finally{
    if(Test-Path -LiteralPath $tmp){ Remove-Item -LiteralPath $tmp -Recurse -Force -EA SilentlyContinue }
  }

  $built.Add([pscustomobject]@{
    ZIP = Get-Rel $zipAbs
    Base = $p.Base
    ODS = Get-Rel $odsAbs
    XLSX = Get-Rel $xlsxAbs
  }) | Out-Null
}

if($WhatIf){
  "WHATIF_DONE=1" | Out-Host
  exit 0
}

if($built.Count -eq 0){
  StopBad "STOP: No bundles built (unexpected)."
}

# --- Patch repo links: replace .ods/.xlsx links with .zip bundle links (best-effort, conservative) ---
# Build mapping by basename only (works even if links were already baseurl-based)
$map = @{}
foreach($b in $built){
  $bn = $b.Base
  $zipRel = $b.ZIP
  $map[$bn] = $zipRel
}

# target files to patch
$patchFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -EA Stop |
  Where-Object {
    $_.Extension -in @(".md",".html",".yml",".yaml") -and
    $_.FullName -notmatch "\\.git\\" -and
    $_.FullName -notmatch "\\_local\\"
  }

$enc = [Text.UTF8Encoding]::new($false)
$changed = 0

foreach($f in $patchFiles){
  $old = [IO.File]::ReadAllText($f.FullName, $enc)
  $new = $old

  foreach($bn in $map.Keys){
    $zipRel = $map[$bn] # e.g. downloads/bundles/name.zip

    # Replace occurrences of bn.ods / bn.xlsx (also in URLs)
    # We keep any path prefix intact, only swap the extension target to the bundle path if it looks like a direct file link.
    $new = $new -replace ([regex]::Escape($bn) + '\.ods\b'),  ($bn + '.zip')
    $new = $new -replace ([regex]::Escape($bn) + '\.xlsx\b'), ($bn + '.zip')

    # If the content already uses a folder path (e.g. /downloads/.../bn.zip), we also ensure it points to bundles folder (safe, only if exact filename match)
    # Replace any path ending with /bn.zip or \bn.zip to bundles location (keeps baseurl if present)
    $new = $new -replace ('([/\w\-\.\{\}\s]+?)' + [regex]::Escape('/' + $bn + '.zip')), ('$1/' + ($BundleRelDir.TrimEnd('/') + '/' + $bn + '.zip'))
    $new = $new -replace ('([\\\w\-\.\{\}\s]+?)' + [regex]::Escape('\' + $bn + '.zip')), ('$1\' + ($BundleRelDir.TrimEnd('/') -replace '/','\') + '\' + $bn + '.zip')
  }

  if($new -ne $old){
    [IO.File]::WriteAllText($f.FullName, $new, $enc)
    $changed++
  }
}

"BUILT_ZIPS={0}" -f $built.Count | Out-Host
$built | Sort-Object ZIP | Format-Table -AutoSize | Out-Host
"PATCHED_FILES={0}" -f $changed | Out-Host

# --- Done. Gates/commit/push run in wrapper block. ---