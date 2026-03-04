param()

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo=(Get-Location).Path
$root = Join-Path $repo "_local\_scratch"
if(!(Test-Path -LiteralPath $root)){
  "OK: gate-no-fake-ok PASS (no _local/_scratch)"
  return
}

$targets = Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'step_*.ps1' -ErrorAction SilentlyContinue
$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $arr = @(Get-Content -LiteralPath $f.FullName -Encoding UTF8)
  $ln = 0
  foreach($s in $arr){
    $ln++
    $t = ($s + '').Trim()
    if($t -like 'OK: normalized 0*'){
      $bad.Add(('{0}:L{1}: forbidden fake-ok message: {2}' -f @($f.FullName,$ln,($s + '').TrimEnd())))
    }
  }
}

if($bad.Count -gt 0){
  'FAIL: NO_FAKE_OK'
  $bad | ForEach-Object { ' - ' + $_ }
  throw 'STOP: fake-OK patterns found in step files'
}

'OK: gate-no-fake-ok PASS'
return
