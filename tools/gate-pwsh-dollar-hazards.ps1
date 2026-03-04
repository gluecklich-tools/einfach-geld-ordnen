# ALLOW_REGEX_PATCH (temporary; must be removed when refactored to literal/AST patching)
param(
  [string]$RepoRoot = '',
  [string]$InternRoot = '',
  [switch]$IncludeNonTools
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }

function GetRootOrThrow([string]$p,[string]$label){
  if([string]::IsNullOrWhiteSpace($p) -or !(Test-Path -LiteralPath $p)){
    throw ("STOP: {0} missing: {1}" -f @($label,$p))
  }
  return (Resolve-Path -LiteralPath $p).Path
}

if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $RepoRoot=(git rev-parse --show-toplevel 2>$null).Trim()
}
$RepoRoot = GetRootOrThrow $RepoRoot 'RepoRoot'


$self = (Resolve-Path -LiteralPath $PSCommandPath).Path
if([string]::IsNullOrWhiteSpace($InternRoot)){
  # expect InternRoot passed as ...\INTERN_REDACTED
  $InternRoot = ''
}
if(-not [string]::IsNullOrWhiteSpace($InternRoot)){
  $InternRoot = GetRootOrThrow $InternRoot 'InternRoot'
}

# Collect targets
$files = New-Object 'System.Collections.Generic.List[string]'

$repoTools = Join-Path $RepoRoot 'tools'
if(Test-Path -LiteralPath $repoTools){
  Get-ChildItem -LiteralPath $repoTools -File -Recurse -Filter *.ps1 | ForEach-Object { $files.Add($_.FullName) }
}
if(-not [string]::IsNullOrWhiteSpace($InternRoot)){
  $internTools = Join-Path $InternRoot 'tools'
  if(Test-Path -LiteralPath $internTools){
    Get-ChildItem -LiteralPath $internTools -File -Recurse -Filter *.ps1 | ForEach-Object { $files.Add($_.FullName) }
  }
}

if($IncludeNonTools){
  # optional: scan more ps1, but keep default tight to avoid noise
  Get-ChildItem -LiteralPath $RepoRoot -File -Recurse -Filter *.ps1 |
    Where-Object { $_.FullName -notlike "*\_local\*" } |
    ForEach-Object { $files.Add($_.FullName) }

  if(-not [string]::IsNullOrWhiteSpace($InternRoot)){
    Get-ChildItem -LiteralPath $InternRoot -File -Recurse -Filter *.ps1 |
      Where-Object { $_.FullName -notlike "*\_patch_backups\*" } |
      ForEach-Object { $files.Add($_.FullName) }
  }
}

# Dedup
$uniq = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$scan = @()
foreach($f in $files){ if($uniq.Add($f)){ $scan += $f } }

if($scan.Count -eq 0){
  "OK: no files to scan."
  exit 0
}

# Rules
# R1: expanding here-string starts: @"  (we also flag @" anywhere)
$reHereStart = '(?m)^\s*@\"'
# R2: -replace " ... $ ... " (double-quoted pattern contains $)
$reReplaceDQDollar = '(?im)\-replace\s+\"[^\"\r\n]*\$[^\"\r\n]*\"'
# R3: [regex]::Replace(" ... $ ... "  -> pattern double-quoted with $
$reRegexReplaceDQDollar = '(?im)\[regex\]::Replace\s*\(\s*\"[^\"\r\n]*\$[^\"\r\n]*\"'

$hits = @()
foreach($p in $scan){ if($p -ieq $self){ continue }
  $t = ReadUtf8 $p

  if([regex]::IsMatch($t,$reHereStart)){
    $hits += [pscustomobject]@{ file=$p; rule='HERESTRING_EXPAND_@"'; match='found @" (expandierend)'; }
  }
  if([regex]::IsMatch($t,$reReplaceDQDollar)){
    $hits += [pscustomobject]@{ file=$p; rule='REPLACE_DQ_WITH_$'; match='-replace " ...$... " (Interpolation Hazard)'; }
  }
  if([regex]::IsMatch($t,$reRegexReplaceDQDollar)){
    $hits += [pscustomobject]@{ file=$p; rule='REGEXREPLACE_DQ_WITH_$'; match='[regex]::Replace(" ...$... " (Interpolation Hazard)'; }
  }
}

if($hits.Count -gt 0){
  "FAIL: PowerShell $-Interpolation Hazards detected."
  ""
  $csvOut = Join-Path $RepoRoot ("_local\reports\gate_pwsh_dollar_hazards_hits_{0}.csv" -f @(("{0}_{1}" -f @((Get-Date).ToString("yyyyMMdd_HHmmss_fff"), (Get-Random -Minimum 1000 -Maximum 9999))))
  $dir = Split-Path -Parent $csvOut
  if($dir -and !(Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $hits | Sort-Object file, rule | Export-Csv -LiteralPath $csvOut -NoTypeInformation -Encoding UTF8

  # print without truncation
  foreach($h in ($hits | Sort-Object file, rule)){
    ("HIT`t{0}`t{1}`t{2}" -f @($h.rule, $h.file, $h.match) | Write-Host)
  }
  ""
  "WROTE: $csvOut"
  ""
  "RULE: use single quotes / @' '@ here-strings or escape/double $."
  exit 2
}

"PASS: No $-Interpolation hazards in scanned tools."
exit 0
