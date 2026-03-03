#requires -Version 7.0
[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$RootPath,

  [Parameter(Mandatory=$false)]
  [string]$KeepTsv
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

# EGO_P0_PROJECTROOT_DERIVE
# Derive project root (two levels above repo root) to avoid hardcoded user paths
$RepoRoot = $null
try { $RepoRoot = (git rev-parse --show-toplevel 2>$null) } catch {}
if([string]::IsNullOrWhiteSpace($RepoRoot)){ throw "RepoRoot not found (git rev-parse failed)." }
$ProjectRoot = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "..\..")).Path
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

function Is-Placeholder([string]$s){
  if([string]::IsNullOrWhiteSpace($s)){ return $false }
  return ($s -match '^\s*<[^>]+>\s*$')
}

function Write-Utf8NoBom([string]$p,[string]$s){
  [IO.File]::WriteAllText($p,$s,$utf8)
}

function Read-Utf8NoBom([string]$p){
  [IO.File]::ReadAllText($p,$utf8)
}

trap {
  Write-Host ""
  Write-Host "=== project-keep-scan ERROR ==="
  Write-Host $_.Exception.Message
  if ($_.InvocationInfo) { Write-Host $_.InvocationInfo.PositionMessage }
  throw
}

function Get-RepoRootOrFail(){
  $r = (git rev-parse --show-toplevel 2>$null)
  if([string]::IsNullOrWhiteSpace($r)){ Fail "RootPath missing and auto-detect failed (git rev-parse)." }
  return $r
}

function Find-KeepTsvCandidates([string[]]$roots){
  $c = @()
  foreach($root in $roots){
    if([string]::IsNullOrWhiteSpace($root)){ continue }
    if(-not (Test-Path -LiteralPath $root)){ continue }
    $c += Get-ChildItem -LiteralPath $root -Recurse -File -Include "*keep*.tsv","*KEEP*.tsv" -ErrorAction SilentlyContinue
  }
  $c | Sort-Object LastWriteTime -Descending
}

function Find-AnyTsvCandidates([string]$root){
  if([string]::IsNullOrWhiteSpace($root)){ return @() }
  if(-not (Test-Path -LiteralPath $root)){ return @() }
  Get-ChildItem -LiteralPath $root -Recurse -File -Include "*.tsv" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 20 -ExpandProperty FullName
}

# --- Proaktiv Defaults ---
if(Is-Placeholder $RootPath){ Fail "RootPath is a placeholder. Provide a real path." }
if(Is-Placeholder $KeepTsv){ Fail "KeepTsv is a placeholder. Provide a real file path." }

if([string]::IsNullOrWhiteSpace($RootPath)){
  $RootPath = Get-RepoRootOrFail
}
$RootPath = (Resolve-Path -LiteralPath $RootPath).Path

if([string]::IsNullOrWhiteSpace($KeepTsv)){
  # preferred SSOT governance paths (relative + absolute)
  $p1 = Join-Path $RootPath "..\..\_INTERN\governance"
  $p2 = $env:EGO_SSOT_GOV_DIR
if([string]::IsNullOrWhiteSpace($p2)){
  # fallback: repoRoot -> ..\..\_INTERN\governance (project root)
  $p2 = Join-Path $RootPath "..\..\_INTERN\governance"
}
  # also allow broader _INTERN fallback
  $p3 = Join-Path $RootPath "..\..\_INTERN"
  $cand = Find-KeepTsvCandidates @($p1,$p2,$p3) | Select-Object -First 1
  if($cand){ $KeepTsv = $cand.FullName }
}

if([string]::IsNullOrWhiteSpace($KeepTsv)){
  $hint = (Find-AnyTsvCandidates $RootPath) -join "`n"
  Fail ("KeepTsv missing (auto-detect failed). Provide -KeepTsv <path>. Top TSV candidates:`n" + $hint)
}
$KeepTsv = (Resolve-Path -LiteralPath $KeepTsv).Path

# --- Helpers ---
function Read-KeepPaths([string]$p){
  $lines = Get-Content -LiteralPath $p -Encoding UTF8
  if(@($lines).Count -lt 2){ return @() }

  # Header -> find path column index (case-insensitive)
  $header = $lines[0].Split("`t")
  $idx = -1
  for($i=0; $i -lt $header.Count; $i++){
    $h = ([string]$header[$i]).Trim().ToLowerInvariant()
    if($h -in @("path","filepath","file","filename","fullpath","relpath","relativepath")){
      $idx = $i
      break
    }
  }

  if($idx -lt 0){
    $h = ($header -join ", ")
    Fail ("Keep TSV has no path column. Expected one of: path/filepath/file/filename/fullpath/relpath. Header=" + $h)
  }

  $out = New-Object 'System.Collections.Generic.List[string]'
  for($r=1; $r -lt $lines.Count; $r++){
    if([string]::IsNullOrWhiteSpace($lines[$r])){ continue }
    $cols = $lines[$r].Split("`t")
    if($cols.Count -le $idx){ continue }
    $val = ([string]$cols[$idx]).Trim()
    if($val){ $out.Add($val) | Out-Null }
  }
  return $out
}

function Add-Finding($list, [string]$severity, [string]$rule, [string]$path, [string]$detail){
  $list.Add([pscustomobject]@{ severity=$severity; rule=$rule; path=$path; detail=$detail }) | Out-Null
}

function Looks-Mojibake([string]$s){
  if($null -eq $s -or $s.Length -eq 0){ return $false }
  if([regex]::IsMatch($s, "\uFFFD")){ return $true }
  if([regex]::IsMatch($s, "\u00C3\u00A4|\u00C3\u00B6|\u00C3\u00BC|\u00C3\u009F")){ return $true }
  if([regex]::IsMatch($s, "\u00E2\u20AC\u2013|\u00E2\u20AC\u2014|\u00E2\u20AC\u201E|\u00E2\u20AC\u201C|\u00E2\u20AC\u201D")){ return $true }
  return $false
}

function Has-AbsPathLeak([string]$s){
  if($s -match "C:\\Users\\"){ return $true }
  if($s -match "C:/Users/"){ return $true }
  if($s -match "/Users/"){ return $true }
  if($s -match "/home/"){ return $true }
  return $false
}

function Is-AbsPathLeakRelevant([string]$filePath){
  # Ignore non-public artifacts; enforce for repo scope + tools
  if($filePath -match "\\Brain_EGO_Dateien\\"){ return $false }
  if($filePath -match "\\_INTERN\\"){ return $false }
  if($filePath -match "\\latest\\"){ return $false }
  if($filePath -match "\\snapshots\\"){ return $false }
  if($filePath -match "\\_reports\\"){ return $false }
  if($filePath -match "\\GitHub_Clone_Dateien\\"){ return $true }
  if($filePath -match "\\einfach-geld-ordnen\\tools\\"){ return $true }
  return $false
}

# --- Run ---
$reports = Join-Path $RootPath "_reports"
New-Item -ItemType Directory -Path $reports -Force | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$outTsv = Join-Path $reports ("KEEP_FINDINGS_{0}.tsv" -f $ts)
$outMd  = Join-Path $reports ("KEEP_FINDINGS_{0}.md"  -f $ts)

$paths = Read-KeepPaths $KeepTsv
$findings = New-Object 'System.Collections.Generic.List[object]'

foreach($p in $paths){
  if(-not (Test-Path -LiteralPath $p -PathType Leaf)){
    Add-Finding $findings "P0" "MISSING_FILE" $p "Listed in KEEP TSV but missing on disk."
    continue
  }

  $len = (Get-Item -LiteralPath $p).Length
  if($len -eq 0){
    Add-Finding $findings "P1" "ZERO_BYTES" $p "File size is 0 bytes."
    continue
  }

  $ext = ([IO.Path]::GetExtension($p) ?? "").ToLowerInvariant()
  $isText = $ext -in @(".md",".txt",".ps1",".json",".tsv",".csv",".yml",".yaml",".html",".xml",".ndjson")
  $text = $null
  if($isText -and $len -le 25MB){
    try { $text = Read-Utf8NoBom $p } catch { $text = $null }
  }

  if($text){
    if(Looks-Mojibake $text){
      Add-Finding $findings "P1" "MOJIBAKE_SUSPECT" $p "Contains replacement char or typical mojibake sequences."
    }
    if(Has-AbsPathLeak $text -and (Is-AbsPathLeakRelevant $p)){    # Exempt detector/pattern strings in tools to avoid false positives
    if($p -match "(?i)(^|[\\/])tools[\\/].+"){
      $lines = $text -split "`r?`n"
      $hasRealLeak = $false
      foreach($ln in $lines){
        if($ln -match "(?i)(C:\\\\Users\\\\(?!USER\\\\)[^\\\\\r\n]+\\\\|C:/Users/(?!USER/)[^/\r\n]+/|/Users/(?!USER/)[^/\r\n]+/|/home/(?!USER/)[^/\r\n]+/)"){
          # Detector heuristics: regex tables / gates / patterns
          if($ln -match "\bRx\b\s*=" -or $ln -match "\b-match\b" -or $ln -match "\b-like\b" -or $ln -match "regex" -or $ln -match "\bUSER\b" -or $ln -match "\bABS_" -or $ln -match "INTERNALTOOLSROOT" -or $ln -match "pattern"){
            continue
          }
          $hasRealLeak = $true
          break
        }
      }
      if($hasRealLeak){
        Add-Finding $findings "P0" "ABS_PATH_LEAK" $p "Contains absolute path leak patterns (public scope)."
      }
    } else {
      Add-Finding $findings "P0" "ABS_PATH_LEAK" $p "Contains absolute path leak patterns (public scope)."
    }}
  }

  if($ext -eq ".json" -and $len -le 25MB){
    try {
      $raw = $text
      if(-not $raw){ $raw = Get-Content -LiteralPath $p -Raw -Encoding UTF8 }
      $null = $raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
      Add-Finding $findings "P1" "JSON_INVALID" $p $_.Exception.Message
    }
  }

  if($ext -eq ".tsv" -and $len -le 25MB){
    try {
      $first = (Get-Content -LiteralPath $p -TotalCount 1 -Encoding UTF8)
      if($first -notmatch "`t"){
        # Allow single-column keep TSV (header "path") without tabs
if($first -notmatch "`t"){
  if(($first ?? "").Trim() -ieq "path"){
    # ok: one-column path list TSV
  } else {
    Add-Finding $findings "P2" "TSV_NO_TABS" $p "First line has no tab; might not be TSV."
  }
}
      }
    } catch {}
  }

  if($len -gt 200MB){
    Add-Finding $findings "P2" "VERY_LARGE_FILE" $p ("Large file: {0} bytes" -f $len)
  }
}

# TSV
$cols = @("severity","rule","path","detail")
$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add(($cols -join "`t")) | Out-Null
foreach($f in $findings){
  $vals = @(
    [string]$f.severity,
    [string]$f.rule,
    ([string]$f.path).Replace("`t"," "),
    ([string]$f.detail).Replace("`t"," ")
  )
  $lines.Add(($vals -join "`t")) | Out-Null
}
Write-Utf8NoBom $outTsv (($lines -join "`r`n") + "`r`n")

# MD summary
$p0 = @($findings | Where-Object { $_.severity -eq "P0" }).Count
$p1 = @($findings | Where-Object { $_.severity -eq "P1" }).Count
$p2 = @($findings | Where-Object { $_.severity -eq "P2" }).Count

$md = @()
$md += "# KEEP Findings"
$md += ""
$md += "* Root: $RootPath"
$md += "* Keep TSV: $KeepTsv"
$md += "* Findings: P0=$p0, P1=$p1, P2=$p2"
$md += ""
$md += "## Next"
$md += "- Fix P0 first (abs path leaks, missing files)."
$md += "- Then P1 (invalid JSON, mojibake)."
$md += ""
Write-Utf8NoBom $outMd (($md -join "`r`n") + "`r`n")

"OK: keep-scan done"
"FINDINGS_TSV: $outTsv"
"FINDINGS_MD:  $outMd"