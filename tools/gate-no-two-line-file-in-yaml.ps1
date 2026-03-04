param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo = (Get-Location).Path
$wfDir = Join-Path $repo ".github\workflows"
if(!(Test-Path -LiteralPath $wfDir)){
  "OK: gate-no-two-line-file-in-yaml PASS (no workflows dir)"
  return
}

$files = Get-ChildItem -LiteralPath $wfDir -File
$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $files){
  $lines = @([IO.File]::ReadAllLines($f.FullName,[Text.UTF8Encoding]::new($false)))
  for($i=0; $i -lt ($lines.Length-1); $i++){
    $a = $lines[$i].TrimEnd()
    $b = $lines[$i+1].Trim()

    if($a -like '*-File*' -and ($b -like 'tools/*.ps1' -or $b -like 'tools\*.ps1')){
      $bad.Add(("{0}:L{1}: {2} || {3}" -f @($f.FullName,($i+1),$lines[$i].TrimEnd(),$lines[$i+1].TrimEnd())))
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: NO_TWO_LINE_FILE_IN_YAML"
  $bad | ForEach-Object { " - " + $_ }
  throw "STOP: YAML contains two-line -File continuation"
}

"OK: gate-no-two-line-file-in-yaml PASS"
return
