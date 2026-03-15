param(
  [string]$RepoRoot = 'C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen',
  [string]$BaseUrl  = 'https://gluecklich-tools.github.io/einfach-geld-ordnen',
  [string]$SSOTRoot = $env:EGO_SSOT_ROOT,
  [switch]$ReportOnly
)



# AUTO_FINDING_TRAP_V1
# Purpose: On ANY terminating error, write SSOT finding automatically (idempotent per error signature), then rethrow.
trap {
  try {
    $tool = Join-Path $PSScriptRoot 'ssot-finding-add.ps1'
    if(Test-Path -LiteralPath $tool){
      $msg = if($_ -and $_.Exception){ $_.Exception.Message } else { $_.ToString() }
      $typ = if($_ -and $_.Exception){ $_.Exception.GetType().FullName } else { 'UnknownException' }

      $flat = ($typ + '|' + ($msg -replace '\s+',' ')).Trim()
      if($flat.Length -gt 200){ $flat = $flat.Substring(0,200) }

      $sha1  = [System.Security.Cryptography.SHA1]::Create()
      $bytes = [Text.Encoding]::UTF8.GetBytes($flat)
      $hash  = ($sha1.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join ''
      $id    = 'AUTO_FLOW_GATE_EXCEPTION_' + $hash.Substring(0,12)

      pwsh -NoProfile -File $tool `
        -Id $id `
        -Title 'flow-quality-gate: Exception Auto-Finding' `
        -Problem ("Type: " + $typ + "`nMessage: " + $msg) `
        -Fix 'Fehler beheben; wenn wiederkehrend: Guard/Policy ergänzen. Dieser Eintrag wurde automatisch erzeugt.' `
        -AntiPattern 'Exception ignorieren oder nur lokal fixen ohne SSOT-Update.' `
        -Tags 'powershell,auto,finding,flow-quality-gate'
    }
  } catch {
    # never block the original failure
  }
  throw
}
# /AUTO_FINDING_TRAP_V1
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$enc=[Text.UTF8Encoding]::new($false)

if([string]::IsNullOrWhiteSpace($SSOTRoot)){ $SSOTRoot='C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance' }
if(!(Test-Path -LiteralPath $RepoRoot)){ throw ('STOP: RepoRoot missing: ' + $RepoRoot) }
if(!(Test-Path -LiteralPath $SSOTRoot)){ throw ('STOP: SSOTRoot missing: ' + $SSOTRoot) }

$draft=Join-Path $RepoRoot '_local\flow\FLOWMAP_DRAFT.tsv'
$flowmap=Join-Path $SSOTRoot 'FLOWMAP_INTERNAL.md'
if(!(Test-Path -LiteralPath $draft)){ throw ('STOP: missing draft TSV: ' + $draft) }

$allowNoIntendedNext = @(
  'seiten/audit.md','seiten/changelog.md','seiten/governance.md'
)


# FLOW_QUALITY_ALLOWLIST_V1
# Roles where intended_next is optional by default (policy)
$rolesIntendedNextOptional = @('governance','download_hub')

# Pages where intended_next is optional (explicit)
$pagesIntendedNextOptional = @(
  'seiten/rechner-index.md',
  'seiten/rechner-uebersicht.md',
  'seiten/rechner.md',
  'seiten/downloads.md',
  'seiten/download.md',
  'seiten/download-hub-index.md',
  'seiten/index.md'
)
function DropQuery([string]$u){
  if([string]::IsNullOrWhiteSpace($u)){ return '' }
  $x=$u.Trim()
  $q=$x.IndexOf('?'); if($q -ge 0){ $x=$x.Substring(0,$q) }
  $h=$x.IndexOf('#'); if($h -ge 0){ $x=$x.Substring(0,$h) }
  return $x
}
function NormRel([string]$p){
  if([string]::IsNullOrWhiteSpace($p)){ return '' }
  ($p -replace '\\','/').Trim().TrimStart('/')
}
function RelFromUrl([string]$u,[string]$base){
  $x=DropQuery $u
  if([string]::IsNullOrWhiteSpace($x)){ return '' }
  if($x -notmatch '^https?://'){ return (NormRel $x) }
  $b=(DropQuery $base).TrimEnd('/') + '/'
  if($x.StartsWith($b,[StringComparison]::OrdinalIgnoreCase)){ $x=$x.Substring($b.Length) }
  $x=NormRel $x
  if($x -eq '' -or $x -eq '/'){ return 'index.md' }
  if($x.EndsWith('/',[StringComparison]::Ordinal)){ return ($x.TrimEnd('/') + '/index.md') }
  if($x -match '\.html$'){ return ($x -replace '\.html$','.md') }
  return $x
}
function HtmlFromAny([string]$x,[string]$base){
  $r=RelFromUrl $x $base
  if([string]::IsNullOrWhiteSpace($r)){ return '' }
  $r=NormRel $r
  if($r -eq 'index.md'){ return 'index.html' }
  if($r -match '\.md$'){ return ($r -replace '\.md$','.html') }
  if($r -match '\.html$'){ return $r }
  return $r
}

$rows=Get-Content -LiteralPath $draft -Encoding UTF8 | Where-Object { $_ -and $_.Trim() -ne '' }

$errors=New-Object 'System.Collections.Generic.List[string]'
$warns =New-Object 'System.Collections.Generic.List[string]'

foreach($line in $rows){
  $raw=$line -split "`t"

  # Header skip: idx url role intended_next notes
  if($raw.Count -ge 2 -and ($raw[0].Trim().ToLower() -eq 'idx') -and ($raw[1].Trim().ToLower() -eq 'url')){ continue }

  # Layout autodetect:
  # A) idx<TAB>url<TAB>role<TAB>intended_next<TAB>...
  # B) url<TAB>role<TAB>intended_next<TAB>...
  # C) rel_path<TAB>role<TAB>intended_next<TAB>...
  $url='' ; $role='' ; $int='' ; $rel=''
  if($raw.Count -ge 2 -and ($raw[0] -match '^\d+$') -and ($raw[1] -match '^https?://')){
    $url =$raw[1].Trim()
    $role=if($raw.Count -ge 3){ $raw[2].Trim() } else { '' }
    $int =if($raw.Count -ge 4){ $raw[3].Trim() } else { '' }
    $rel =RelFromUrl $url $BaseUrl
  } elseif($raw.Count -ge 1 -and ($raw[0] -match '^https?://')){
    $url =$raw[0].Trim()
    $role=if($raw.Count -ge 2){ $raw[1].Trim() } else { '' }
    $int =if($raw.Count -ge 3){ $raw[2].Trim() } else { '' }
    $rel =RelFromUrl $url $BaseUrl
  } else {
    $rel =NormRel (if($raw.Count -ge 1){ $raw[0] } else { '' })
    $role=if($raw.Count -ge 2){ $raw[1].Trim() } else { '' }
    $int =if($raw.Count -ge 3){ $raw[2].Trim() } else { '' }
  }

  if([string]::IsNullOrWhiteSpace($rel)){ continue }

  $abs=Join-Path $RepoRoot ($rel -replace '/', [string][IO.Path]::DirectorySeparatorChar)
  if(!(Test-Path -LiteralPath $abs)){
    $errors.Add(('MISSING_PAGE_FILE: ' + $rel + '  src_url=' + (DropQuery $url)))
    continue
  }

  $hasInt = -not [string]::IsNullOrWhiteSpace($int)
  if(-not $hasInt){
  $r0 = ($role ?? '').Trim().ToLower()
  if(($rolesIntendedNextOptional -contains $r0) -or ($pagesIntendedNextOptional -contains $rel) -or ($allowNoIntendedNext -contains $rel)){
    continue
  }
  $warns.Add(('NO_INTENDED_NEXT: ' + $rel + ' role=' + $role))
  continue
}

  $targetHtml = HtmlFromAny $int $BaseUrl
  if([string]::IsNullOrWhiteSpace($targetHtml)){
    $errors.Add(('INTENDED_NEXT_EMPTY: ' + $rel))
    continue
  }
  $targetLeaf = [IO.Path]::GetFileName($targetHtml)

  $body=[IO.File]::ReadAllText($abs,$enc)
  $ok = $false
  if($body -match ([Regex]::Escape('/' + $targetHtml))){ $ok=$true }
  elseif($body -match ([Regex]::Escape('/seiten/' + $targetLeaf))){ $ok=$true }
  elseif($body -match ([Regex]::Escape('{{ site.baseurl }}/' + $targetHtml))){ $ok=$true }

  if(-not $ok){
    $errors.Add(('INTENDED_NEXT_NOT_LINKED: ' + $rel + ' -> ' + $targetHtml))
  }

  if($role -match 'pillar' -and $targetHtml -notmatch '^seiten/' ){
    $warns.Add(('ROLE_NEXT_SUSPECT: ' + $rel + ' role=' + $role + ' next=' + $targetHtml))
  }
}

$flowmapState = if(Test-Path -LiteralPath $flowmap){ ' (present)' } else { ' (missing)' }
'=== FLOW QUALITY GATE ==='
'DRAFT=' + $draft
'FLOWMAP_INTERNAL=' + $flowmap + $flowmapState
'ERRORS=' + $errors.Count
'WARNS=' + $warns.Count
'---'
if($warns.Count -gt 0){ 'WARNINGS:'; $warns | Sort-Object | ForEach-Object { $_ } ; '---' }
if($errors.Count -gt 0){ 'ERRORS:'; $errors | Sort-Object | ForEach-Object { $_ } ; '---' }
# EGO_DEFER_REPORTONLY_EXIT_V1 (defer exit until after outputs)
$EGO_DEFER_REPORTONLY_EXIT = $true
if($errors.Count -gt 0){ exit 2 }
# EGO_DEFER_EXIT_RETURN_FORCE_CSV_V1 (defer exit 0)
$script:EGO_DEFER_EXIT0 = $true
# ---------------------------------------------------------------------
# EGO_FLOW_WARN_CSV_HEADER_V1
# Ensure flow_warns_v2.csv is always a valid CSV (header even when 0 rows).
# ---------------------------------------------------------------------
function EGO_WriteFlowWarnCsv {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][object[]]$Rows
  )
  # Define canonical columns (must match the objects we export)
  $cols = @('kind','reason','from_file','to_file','from_url','to_url','href','line')
  if (-not $Rows -or @($Rows).Count -eq 0) {
    # header-only
    $header = ($cols -join ',') + "
"
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $header, $enc)
# EGO_DEFER_EXIT_RETURN_FORCE_CSV_V1 (defer return)
$script:EGO_DEFER_RETURN = $true
  }
  # Normal export
  $Rows | Select-Object $cols | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
}

# ---------------------------------------------------------------------
# EGO_FLOW_WARN_CSV_FINAL_GUARD_V1
# Guarantee flow_warns_v2.csv is a valid CSV (header even when 0 warns).
# ---------------------------------------------------------------------
try {
  # Try common variable names; fallback to run_meta.json
  $__runDir = $null
  if (Get-Variable -Name RunDir -Scope Script -ErrorAction SilentlyContinue) { $__runDir = [string]$script:RunDir }
  if (-not $__runDir -and (Get-Variable -Name runDir -Scope Script -ErrorAction SilentlyContinue)) { $__runDir = [string]$script:runDir }

  if (-not $__runDir) {
    # last resort: locate meta in current folder
    $__here = Split-Path -Parent $(Get-Variable -Name MyInvocation -Scope Script).Value.MyCommand.Path
    $__meta = Join-Path $__here "run_meta.json"
    if (Test-Path -LiteralPath $__meta) {
      $__j = Get-Content -LiteralPath $__meta -Raw | ConvertFrom-Json
      if ($__j.run_dir) { $__runDir = [string]$__j.run_dir }
    }
  }

  if ($__runDir) {
    $__csv = Join-Path $__runDir "flow_warns_v2.csv"
    if (Test-Path -LiteralPath $__csv) {
      $__len = (Get-Item -LiteralPath $__csv).Length
      if ($__len -lt 20) {
        $__header = "kind,reason,from_file,to_file,from_url,to_url,href,line
"
        $__enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($__csv, $__header, $__enc)
      }
    }
  }
} catch { }

# ---------------------------------------------------------------------
# EGO_DEFER_REPORTONLY_EXIT_V1 (final)
# ---------------------------------------------------------------------
try {
  if (Get-Variable -Name EGO_DEFER_REPORTONLY_EXIT -Scope Script -ErrorAction SilentlyContinue) {
    if ($EGO_DEFER_REPORTONLY_EXIT -and $ReportOnly) { exit 0 }
  }
} catch { }

# ---------------------------------------------------------------------
# EGO_DEFER_EXIT_RETURN_FORCE_CSV_V1 (final guard)
# ---------------------------------------------------------------------
try {
  # resolve run dir robustly
  $__runDir = $null
  if (Get-Variable -Name RunDir -Scope Script -ErrorAction SilentlyContinue) { $__runDir = [string]$script:RunDir }
  if (-not $__runDir -and (Get-Variable -Name runDir -Scope Script -ErrorAction SilentlyContinue)) { $__runDir = [string]$script:runDir }

  if (-not $__runDir) {
    # try meta beside script output (best effort)
    # (if run_dir is tracked elsewhere, this still won't break)
    $__meta = Join-Path (Split-Path -Parent $(Get-Variable -Name MyInvocation -Scope Script).Value.MyCommand.Path) "run_meta.json"
    if (Test-Path -LiteralPath $__meta) {
      $__j = Get-Content -LiteralPath $__meta -Raw | ConvertFrom-Json
      if ($__j.run_dir) { $__runDir = [string]$__j.run_dir }
    }
  }

  if ($__runDir) {
    $__csv = Join-Path $__runDir "flow_warns_v2.csv"
    if (Test-Path -LiteralPath $__csv) {
      $__len = (Get-Item -LiteralPath $__csv).Length
      if ($__len -lt 20) {
        $__header = "kind,reason,from_file,to_file,from_url,to_url,href,line
"
        $__enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($__csv, $__header, $__enc)
      }
    }
  }
} catch { }

# execute deferred exits at the very end
try {
  if (Get-Variable -Name EGO_DEFER_EXIT0 -Scope Script -ErrorAction SilentlyContinue) {
    if ($script:EGO_DEFER_EXIT0) { exit 0 }
  }
  if (Get-Variable -Name EGO_DEFER_RETURN -Scope Script -ErrorAction SilentlyContinue) {
    if ($script:EGO_DEFER_RETURN) { return }
  }
} catch { }

# ---------------------------------------------------------------------
# EGO_FLOW_WARN_CSV_FINAL_GUARD_V2
# Derive RepoRoot via git and always ensure flow_warns_v2.csv has header.
# ---------------------------------------------------------------------
try {
  $__repo = (& git rev-parse --show-toplevel 2>$null)
  if ($__repo) {
    $__repo = (Resolve-Path -LiteralPath $__repo).Path
    $__base = Join-Path $__repo "_local\flow_quality"
    if (Test-Path -LiteralPath $__base) {
      $__run = Get-ChildItem -LiteralPath $__base -Directory |
        Where-Object { $_.Name -like "run_*" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
      if ($__run) {
        $__csv = Join-Path $__run.FullName "flow_warns_v2.csv"
        if (Test-Path -LiteralPath $__csv) {
          $__len = (Get-Item -LiteralPath $__csv).Length
          if ($__len -lt 20) {
            $__header = "kind,reason,from_file,to_file,from_url,to_url,href,line
"
            $__enc = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($__csv, $__header, $__enc)
          }
        }
      }
    }
  }
} catch { }
