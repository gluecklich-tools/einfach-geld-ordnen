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

try{ Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null }catch{}

function New-BundleReadme([string]$BaseName){
  $readmeLines = @(
    'README_START_HIER.txt',
    '',
    'Paket: {{BASENAME}}',
    '',
    'Inhalt:',
    '- XLSX (Excel)',
    '- ODS (LibreOffice)',
    '',
    'Hinweise:',
    '- Self-Serve: offline nutzbar, einmaliger Download'
  )
  $readme = ($readmeLines -join "`r`n")
  $readme = $readme -replace '\{\{BASENAME\}\}', $BaseName
  return $readme
}

function Get-Rel([string]$abs){
  $p = [IO.Path]::GetFullPath($abs)
  $r = [IO.Path]::GetFullPath($RepoRoot)
  if(!$p.StartsWith($r, [StringComparison]::OrdinalIgnoreCase)){ return $abs }
  $rel = $p.Substring($r.Length).TrimStart('\','/')
  return ($rel -replace '\\','/')
}

# --- inventory ---
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

# Group globally by basename
$groups = @{}
foreach($f in $all){
  $base = [IO.Path]::GetFileNameWithoutExtension($f.Name)
  if(-not $groups.ContainsKey($base)){
    $groups[$base] = [ordered]@{ Base=$base; ODS=@(); XLSX=@() }
  }
  if($f.Extension -eq ".ods"){  $groups[$base].ODS  += $f.FullName }
  if($f.Extension -eq ".xlsx"){ $groups[$base].XLSX += $f.FullName }
}

$ok = New-Object System.Collections.Generic.List[object]
$amb = New-Object System.Collections.Generic.List[object]
$nop = New-Object System.Collections.Generic.List[object]

foreach($g in $groups.Values){
  $odsN  = @($g.ODS).Count
  $xlsxN = @($g.XLSX).Count

  if($odsN -eq 1 -and $xlsxN -eq 1){
    $ok.Add([pscustomobject]@{
      Base = $g.Base
      ODS  = $g.ODS[0]
      XLSX = $g.XLSX[0]
    }) | Out-Null
  }
  elseif($odsN -gt 0 -and $xlsxN -gt 0){
    $amb.Add([pscustomobject]@{
      Base = $g.Base
      ODS_Count  = $odsN
      XLSX_Count = $xlsxN
      ODS_List   = ($g.ODS  | ForEach-Object { Get-Rel $_ }) -join " | "
      XLSX_List  = ($g.XLSX | ForEach-Object { Get-Rel $_ }) -join " | "
    }) | Out-Null
  }
  else{
    $nop.Add([pscustomobject]@{
      Base = $g.Base
      ODS_Count  = $odsN
      XLSX_Count = $xlsxN
    }) | Out-Null
  }
}

"PAIR_OK={0}  PAIR_AMBIG={1}  ONLY_ONE_SIDE={2}" -f $ok.Count, $amb.Count, $nop.Count | Out-Host

if($WhatIf){
  if($ok.Count -gt 0){
    "=== OK PAIRS (will bundle) ===" | Out-Host
    $ok | Sort-Object Base | Select-Object Base, @{n="ODS";e={Get-Rel $_.ODS}}, @{n="XLSX";e={Get-Rel $_.XLSX}} | Format-Table -AutoSize | Out-Host
  }
  if($amb.Count -gt 0){
    "=== AMBIGUOUS (SKIP until you rename/move) ===" | Out-Host
    $amb | Sort-Object Base | Select-Object Base, ODS_Count, XLSX_Count, ODS_List, XLSX_List | Format-Table -AutoSize | Out-Host
  }
  exit 0
}

if($ok.Count -eq 0){
  StopBad "STOP: No unambiguous ODS+XLSX pairs found. Run with -WhatIf to see inventory."
}

# Output dir
$bundleDirAbs = Join-Path $RepoRoot ($BundleRelDir -replace '/','\')
New-Item -ItemType Directory -Path $bundleDirAbs -Force | Out-Null

# Build ZIPs
$built = New-Object System.Collections.Generic.List[object]
foreach($p in $ok){
  $zipBase = $p.Base
  $zipName = ($zipBase + ".zip")

  if($zipName -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_\-\.]*\.zip$'){
    $zipBase = ($zipBase -replace '[^a-zA-Z0-9_\-]','_')
    $zipName = ($zipBase + ".zip")
  }

  $zipAbs = Join-Path $bundleDirAbs $zipName
  if(Test-Path -LiteralPath $zipAbs){ Remove-Item -LiteralPath $zipAbs -Force }

  $tmp = Join-Path $env:TEMP ("ego_bundle_" + [guid]::NewGuid().ToString("N"))
  New-Item -ItemType Directory -Path $tmp -Force | Out-Null

  try{
    Copy-Item -LiteralPath $p.ODS  -Destination (Join-Path $tmp ([IO.Path]::GetFileName($p.ODS)))  -Force
    Copy-Item -LiteralPath $p.XLSX -Destination (Join-Path $tmp ([IO.Path]::GetFileName($p.XLSX))) -Force

    $readmePath = Join-Path $tmp "README_START_HIER.txt"
    [IO.File]::WriteAllText($readmePath, (New-BundleReadme -BaseName $p.Base), [Text.UTF8Encoding]::new($false))

    [IO.Compression.ZipFile]::CreateFromDirectory($tmp, $zipAbs, [IO.Compression.CompressionLevel]::Optimal, $false) | Out-Null
  }
  finally{
    if(Test-Path -LiteralPath $tmp){ Remove-Item -LiteralPath $tmp -Recurse -Force -EA SilentlyContinue }
  }

  $built.Add([pscustomobject]@{
    ZIP  = Get-Rel $zipAbs
    Base = $p.Base
    ODS  = Get-Rel $p.ODS
    XLSX = Get-Rel $p.XLSX
  }) | Out-Null
}

"BUILT_ZIPS={0}" -f $built.Count | Out-Host
$built | Sort-Object ZIP | Format-Table -AutoSize | Out-Host

# NOTE: Link-Patching intentionally NOT done in v2 (too risky without knowing current link patterns).
# We only generate bundles deterministically; you decide where to point buttons/links.