param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo=(Get-Location).Path
$targets = Get-ChildItem -LiteralPath (Join-Path $repo 'tools') -Recurse -File -Filter '*.ps1' -ErrorAction SilentlyContinue

$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $targets){
  $arr = @(Get-Content -LiteralPath $f.FullName -Encoding UTF8)
  $ln = 0
  foreach($s in $arr){
    $ln++
    # Only check inside double-quoted strings heuristically: line contains "
    if($s -notlike '*"*'){ continue }

    # Skip legitimate scope patterns
    if($s -like '*$env:*' -or $s -like '*$global:*' -or $s -like '*$script:*' -or $s -like '*$local:*' -or $s -like '*$private:*' -or $s -like '*$using:*'){ continue }

    # Detect "$name: $other" / "$name:$other" like cases (common parser trap)
    if($s -match '\$[A-Za-z_][A-Za-z0-9_]*:\s*\$[A-Za-z_][A-Za-z0-9_]*'){
      $bad.Add(("{0}:L{1}: possible invalid var-colon-var in double quotes; use -f or `${{}}: `${{}} : {2}" -f $f.FullName,$ln,$s.TrimEnd()))
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: NO_INVALID_VAR_COLON"
  $bad | ForEach-Object { " - " + $_ }
  throw "STOP: invalid var:var pattern detected"
}

"OK: gate-no-invalid-var-colon PASS"
return
