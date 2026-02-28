param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo=(Get-Location).Path
$root = Join-Path $repo "_local\_scratch"
if(!(Test-Path -LiteralPath $root)){
  "OK: gate-no-missing-stepfiles PASS (no _local/_scratch)"
  return
}

$targets = Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'step_*.ps1' -ErrorAction SilentlyContinue
$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $text = Get-Content -LiteralPath $f.FullName -Encoding UTF8 -Raw

  if($text -like '*<step>*' -or $text -like '*<path>*' -or $text -like '*...*'){
    $bad.Add(("{0}: placeholder detected (<step>/<path>/...) - forbidden" -f $f.FullName))
  }

  # Detect direct pwsh -File invocations of step files and ensure referenced path exists (basic)
  $ms = [Regex]::Matches($text, 'pwsh\s+.*-File\s+([^\s`"]+step_[A-Za-z0-9_\-]+\.ps1)')
  foreach($m in $ms){
    $rel = $m.Groups[1].Value.Trim()
    $p = $rel
    if($p.StartsWith('.\')){ $p = Join-Path $repo ($p.Substring(2) -replace '/','\') }
    elseif($p.StartsWith('./')){ $p = Join-Path $repo ($p.Substring(2) -replace '/','\') }
    elseif(-not [IO.Path]::IsPathRooted($p)){ $p = Join-Path $repo ($p -replace '/','\') }

    if(!(Test-Path -LiteralPath $p)){
      $bad.Add(("{0}: references missing step file: {1}" -f $f.FullName,$rel))
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: NO_MISSING_STEPFILES"
  $bad | ForEach-Object { " - " + $_ }
  throw "STOP: missing/placeholder stepfiles detected"
}

"OK: gate-no-missing-stepfiles PASS"
return
