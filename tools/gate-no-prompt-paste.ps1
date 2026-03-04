param()

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo=(Get-Location).Path
$root = Join-Path $repo "_local\_scratch"
if(!(Test-Path -LiteralPath $root)){
  "OK: gate-no-prompt-paste PASS (no _local/_scratch)"
  return
}

$targets = Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'step_*.ps1' -ErrorAction SilentlyContinue
$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $arr = @(Get-Content -LiteralPath $f.FullName -Encoding UTF8)
  $ln=0
  foreach($s in $arr){
    $ln++
    if($s -match '^\s*PS\s+[A-Z]:\\' -or $s -match '^\s*PowerShell\s+\d'){
      $bad.Add(('{0}:L{1}: prompt/output pasted into step file' -f @($f.FullName,$ln)))
    }
  }
}

if($bad.Count -gt 0){
  'FAIL: NO_PROMPT_PASTE'
  $bad | ForEach-Object { ' - ' + $_ }
  throw 'STOP: prompt/output paste detected in step files'
}

'OK: gate-no-prompt-paste PASS'
return
