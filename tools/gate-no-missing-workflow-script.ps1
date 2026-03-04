param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo=(Get-Location).Path
$wfDir = Join-Path $repo ".github\workflows"
if(!(Test-Path -LiteralPath $wfDir)){
  "OK: gate-no-missing-workflow-script PASS (no workflows dir)"
  return
}

$bad = New-Object System.Collections.Generic.List[string]

$wfs = Get-ChildItem -LiteralPath $wfDir -File
foreach($wf in $wfs){
  $text = Get-Content -LiteralPath $wf.FullName -Encoding UTF8 -Raw
  $matches = [Regex]::Matches($text, 'tools\/[A-Za-z0-9_\-]+\.ps1')
  foreach($m in $matches){
    $rel = $m.Value
    $p = Join-Path $repo ($rel -replace '/','\')
    if(!(Test-Path -LiteralPath $p)){
      $bad.Add(("{0}: missing referenced script: {1}" -f @($wf.FullName,$rel)))
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: NO_MISSING_WORKFLOW_SCRIPT"
  $bad | ForEach-Object { " - " + $_ }
  throw "STOP: workflow references missing tools/*.ps1"
}

"OK: gate-no-missing-workflow-script PASS"
return
