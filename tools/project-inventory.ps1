#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][string]$RootPath,
  [string]$OutDir
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Write-Utf8NoBom([string]$p,[string]$s){ [IO.File]::WriteAllText($p,$s,$utf8) }

$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
if(-not $OutDir -or $OutDir.Trim() -eq ""){
  $OutDir = Join-Path $RootPath "_reports"
}
if(-not (Test-Path -LiteralPath $OutDir)){ New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
$OutDir = (Resolve-Path -LiteralPath $OutDir).Path

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$mdPath   = Join-Path $OutDir ("PROJECT_INVENTORY_{0}.md" -f $ts)
$jsonPath = Join-Path $OutDir ("PROJECT_INVENTORY_{0}.json" -f $ts)

$items = Get-ChildItem -LiteralPath $RootPath -Recurse -Force -File -ErrorAction SilentlyContinue |
  Select-Object FullName, Length, LastWriteTimeUtc, Extension

$totalCount = $items.Count
$totalBytes = (@($items) | Measure-Object -Property Length -Sum).Sum
$top = $items | Sort-Object Length -Descending | Select-Object -First 25

$json = $items | ForEach-Object {
  [pscustomobject]@{
    path = $_.FullName
    size_bytes = [int64]$_.Length
    last_write_utc = $_.LastWriteTimeUtc.ToString("o")
    ext = $_.Extension
    classify = ""
    note = ""
  }
} | ConvertTo-Json -Depth 5

$md = @()
$md += "# Project Inventory"
$md += ""
$md += "* Root: $RootPath"
$md += "* Files: $totalCount"
$md += "* Size: $totalBytes bytes"
$md += ""
$md += "## Top 25 largest files"
$md += ""
$md += "| Size (bytes) | LastWriteUtc | Path |"
$md += "|---:|---|---|"
foreach($t in $top){
  $md += ("| {0} | {1} | {2} |" -f @($t.Length, $t.LastWriteTimeUtc.ToString("o"), $t.FullName.Replace("|","\|")))
}
$md += ""
$md += "## Next"
$md += "- Run classify tool to split KEEP/ARCHIVE/TRASH."
$md += ""

Write-Utf8NoBom $jsonPath ($json + "`r`n")
Write-Utf8NoBom $mdPath   (($md -join "`r`n") + "`r`n")

"OK: wrote inventory"
"MD:   $mdPath"
"JSON: $jsonPath"
