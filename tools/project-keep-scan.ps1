#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$RootPath,
  [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$KeepTsv
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Write-Utf8NoBom([string]$p,[string]$s){ [IO.File]::WriteAllText($p,$s,$utf8) }
function Read-Utf8NoBom([string]$p){ [IO.File]::ReadAllText($p,$utf8) }

trap {
  Write-Host ""
  Write-Host "=== project-keep-scan ERROR ==="
  Write-Host $_.Exception.Message
  if ($_.InvocationInfo) { Write-Host $_.InvocationInfo.PositionMessage }
  throw
}

$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
$KeepTsv  = (Resolve-Path -LiteralPath $KeepTsv).Path

$reports = Join-Path $RootPath "_reports"
New-Item -ItemType Directory -Path $reports -Force | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$outTsv = Join-Path $reports ("KEEP_FINDINGS_{0}.tsv" -f $ts)
$outMd  = Join-Path $reports ("KEEP_FINDINGS_{0}.md"  -f $ts)

function Read-KeepPaths([string]$p){
  $lines = Get-Content -LiteralPath $p -Encoding UTF8
  if(@($lines).Count -lt 2){ return @() }
  $out = New-Object 'System.Collections.Generic.List[string]'
  for($i=1;$i -lt $lines.Count;$i++){
    $cols = $lines[$i].Split("`t")
    if($cols.Count -ge 1 -and $cols[0]){ $out.Add($cols[0]) }
  }
  return $out
}

function Add-Finding($list, [string]$severity, [string]$rule, [string]$path, [string]$detail){
  $list.Add([pscustomobject]@{ severity=$severity; rule=$rule; path=$path; detail=$detail }) | Out-Null
}

function Looks-Mojibake([string]$s){
  if($null -eq $s -or $s.Length -eq 0){ return $false }
  # U+FFFD replacement char
  if([regex]::IsMatch($s, "\uFFFD")){ return $true }
  # Common mojibake sequences using unicode escapes only
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
    if(Looks-Mojibake $text){ Add-Finding $findings "P1" "MOJIBAKE_SUSPECT" $p "Contains replacement char or typical mojibake sequences." }
    if(Has-AbsPathLeak $text){ Add-Finding $findings "P0" "ABS_PATH_LEAK" $p "Contains absolute path leak patterns." }
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
      if($first -notmatch "`t"){ Add-Finding $findings "P2" "TSV_NO_TABS" $p "First line has no tab; might not be TSV." }
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