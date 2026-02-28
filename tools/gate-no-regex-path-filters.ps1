$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo = (Get-Location).Path

function IsExcluded([string]$full){
  $p = $full.ToLowerInvariant()
  if($p -like "*\.git\*"){ return $true }
  if($p -like "*\_local\*"){ return $true }
  if($p -like "*\node_modules\*"){ return $true }
  if($p -like "*\_site\*"){ return $true }
  return $false
}

$files = Get-ChildItem -LiteralPath $repo -Recurse -File -Include "*.ps1","*.yml","*.yaml" | Where-Object { -not (IsExcluded $_.FullName) }
$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $files){
  $ln = 0
  foreach($line in [IO.File]::ReadAllLines($f.FullName, [Text.UTF8Encoding]::new($false))){
    $ln++
    if($line -match "(\-notmatch|\-match)"){
      # No $_ tokens in strings; no regex with \_ ; only safe substring heuristics
      $isPathish = $false
      if($line.Contains("FullName")){ $isPathish = $true }
      if($line.Contains(".git")){ $isPathish = $true }
      if($line.Contains("_local")){ $isPathish = $true }
      if($line.Contains("_site")){ $isPathish = $true }
      if($line.Contains("node_modules")){ $isPathish = $true }
      if($isPathish){
        $bad.Add(("{0}:L{1}: forbidden regex path filter: {2}" -f $f.FullName, $ln, $line.Trim()))
      }
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: NO_REGEX_PATH_FILTERS"
  $bad | ForEach-Object { " - $_" }
  exit 2
}
"OK: gate-no-regex-path-filters PASS"
exit 0
