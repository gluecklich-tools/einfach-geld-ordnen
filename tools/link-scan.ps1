# EGO_SSOT_GUARD_V1
# Optional: SSOT guard (only if EGO_INTERNAL_DIR is set and ssot-guard exists)

param(
  [string]$OutFile = ".\tools\link-scan-report.txt"
)

$internalRoot = $env:EGO_INTERNAL_DIR
if ($internalRoot) {
  $guard = Join-Path $internalRoot ('tools' + [char]92 + 'ssot-guard.ps1')
  if (Test-Path -LiteralPath $guard) { & $guard -RequireCleanRepo }
}


$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repo = (Get-Location).Path

$targets = Get-ChildItem -Path $repo -Recurse -File | Where-Object {
  $_.Extension -in @(".md",".html",".yml",".yaml")
}

$patterns = @(
  @{ Name="MD root links /seiten";   Re='\]\(/seiten/'; },
  @{ Name="MD root links /pillar";   Re='\]\(/pillar/'; },
  @{ Name="MD root links /index";    Re='\]\(/index\.html\)'; },
  @{ Name="HTML href root";          Re='href="/'; },
  @{ Name="HTML src root";           Re='src="/'; },
  @{ Name="Hardcoded domain root";   Re='https://gluecklich-tools\.github\.io/(index\.html)?'; },
  @{ Name="Body has site.baseurl";   Re='\{\{\s*site\.baseurl\s*\}\}'; }
)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("LINK SCAN REPORT")
$lines.Add(("Generated: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")))
$lines.Add(("Repo: {0}" -f $repo))
$lines.Add("")

foreach ($p in $patterns) {
  $lines.Add(("== {0} ==" -f $p.Name))
  $hits = @()

  foreach ($f in $targets) {
    $m = Select-String -Path $f.FullName -Pattern $p.Re -SimpleMatch:$false -AllMatches -ErrorAction SilentlyContinue
    if ($m) { $hits += $m }
  }

  if (-not $hits -or $hits.Count -eq 0) {
    $lines.Add("OK: no matches")
    $lines.Add("")
    continue
  }

  foreach ($h in $hits) {
    $rel = $h.Path.Substring($repo.Length).TrimStart("\","/")
    $lines.Add(("{0}:{1}: {2}" -f $rel, $h.LineNumber, $h.Line.Trim()))
  }
  $lines.Add("")
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
# DEFAULT_OUTFILE_LINKSCAN_V1
try{
  $v = Get-Variable -Name OutFile -ErrorAction SilentlyContinue
  if(-not $v -or -not $v.Value){
    $script:OutFile = Join-Path $repo '_local\link_scan\link-scan-report.txt'
  }
}catch{
  $script:OutFile = Join-Path $repo '_local\link_scan\link-scan-report.txt'
}
# /DEFAULT_OUTFILE_LINKSCAN_V1
# ENSURE_OUTDIR_LINKSCAN_V1
try{
  $v = Get-Variable -Name OutFile -ErrorAction SilentlyContinue
  if($v -and $v.Value){
    $outDir = Split-Path -Parent $v.Value
    if($outDir -and -not (Test-Path -LiteralPath $outDir)){
      New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }
  }
}catch{}
# /ENSURE_OUTDIR_LINKSCAN_V1
[System.IO.File]::WriteAllLines($OutFile, $lines.ToArray(), $utf8NoBom)

Write-Host ("Wrote: {0}" -f $OutFile)