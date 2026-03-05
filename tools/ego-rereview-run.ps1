param(
  [string]$Root = ".",
  [string]$OutPath = ".\_local\reports\rereview_report.txt"
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

if(-not (Test-Path -LiteralPath ".\tools\ego-rereview-lib.ps1")){
  throw "Missing: tools\ego-rereview-lib.ps1"
}

. .\tools\ego-rereview-lib.ps1

function Get-MdFiles([string]$base){
  $list = New-Object System.Collections.Generic.List[System.IO.FileInfo]
  $p = Resolve-Path $base

  if(Test-Path -LiteralPath (Join-Path $p.Path "index.md")){
    [void]$list.Add((Get-Item (Join-Path $p.Path "index.md")))
  }
  if(Test-Path -LiteralPath (Join-Path $p.Path "seiten")){
    Get-ChildItem -LiteralPath (Join-Path $p.Path "seiten") -Recurse -File -Filter "*.md" | ForEach-Object { [void]$list.Add($_) }
  }
  if(Test-Path -LiteralPath (Join-Path $p.Path "pillar")){
    Get-ChildItem -LiteralPath (Join-Path $p.Path "pillar") -Recurse -File -Filter "*.md" | ForEach-Object { [void]$list.Add($_) }
  }

  return $list.ToArray()
}

$files = Get-MdFiles $Root

$allHits = New-Object System.Collections.Generic.List[string]
foreach($f in $files){
  $rel = $f.FullName
  try {
    $content = Get-Content -LiteralPath $f.FullName
    $hits = Body-Scan -body $content -relPath $rel
    foreach($h in $hits){ [void]$allHits.Add($h) }
  } catch {
    [void]$allHits.Add(("{0}:ERR:{1}" -f @($rel, $_.Exception.Message)))
  }
}

# normalize & write report
$lines = @()
$lines += "REREVIEW_REPORT"
$lines += ("Files: {0}" -f $files.Count)
$lines += ("Hits : {0}" -f $allHits.Count)
$lines += ""
$lines += $allHits.ToArray()

Write-Report -path $OutPath -lines $lines
"PASS: ego-rereview-run"