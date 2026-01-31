# EGO_SSOT_GUARD_V1
& "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools\ssot-guard.ps1" -RequireCleanRepo

param(
  [string]$OutFile = ".\tools\link-scan-report.txt"
)

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
[System.IO.File]::WriteAllLines($OutFile, $lines.ToArray(), $utf8NoBom)

Write-Host ("Wrote: {0}" -f $OutFile)