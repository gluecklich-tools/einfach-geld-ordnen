param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo=(Get-Location).Path
$root = Join-Path $repo "_local\_scratch"
if(!(Test-Path -LiteralPath $root)){
  "OK: gate-no-literal-n-newlines PASS (no _local/_scratch)"
  return
}

$targets = Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'step_*.ps1' -ErrorAction SilentlyContinue
$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $arr = @(Get-Content -LiteralPath $f.FullName -Encoding UTF8)
  $ln=0
  foreach($s in $arr){
    $ln++
    $t = ($s + '')
    if($t -like '*nexit 0*' -or $t -like '*"nexit*' -or $t -like "*'nexit*"){
      $bad.Add(("{0}:L{1}: suspicious literal 'n' newline; use backtick-n or here-string: {2}" -f $f.FullName,$ln,$t.TrimEnd()))
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: NO_LITERAL_N_NEWLINES"
  $bad | ForEach-Object { " - " + $_ }
  throw "STOP: literal-n newline mistakes detected"
}

"OK: gate-no-literal-n-newlines PASS"
return
