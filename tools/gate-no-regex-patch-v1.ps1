[CmdletBinding()]
param([Parameter(Mandatory)][string]$RepoRoot)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
if([string]::IsNullOrWhiteSpace($RepoRoot)){ throw 'STOP: RepoRoot empty' }
if(!(Test-Path -LiteralPath $RepoRoot)){ throw ('STOP: RepoRoot not found: '+$RepoRoot) }
$viol=New-Object System.Collections.Generic.List[string]
$items=Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Force | Where-Object {
  $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\_local\\' -and $_.FullName -match '\\tools\\' -and $_.Extension -in @('.ps1','.psm1')
}
foreach($f in $items){
  $t=[IO.File]::ReadAllText($f.FullName,[Text.UTF8Encoding]::new($false))
  # forbid regex patching patterns in tools unless explicitly allowed
  if(($t -match '(?i)\[regex\]::Replace' -or $t -match '(?i)\s-replace\s') -and ($t -match '(?i)\bSet-Content\b|\bAdd-Content\b|\bOut-File\b|\bWriteAllText\b|\bWriteAllLines\b|\bMove-Item\b|\bCopy-Item\b')){
    if($t -notmatch 'ALLOW_REGEX_PATCH'){ $viol.Add('NO_REGEX_PATCHING_IN_TOOLS: '+$f.FullName) }
  }
}
if($viol.Count -gt 0){
  'GATE_NO_REGEX_PATCH_V1: FAIL'
  $viol | Sort-Object | Get-Unique | ForEach-Object { ' - '+$_ }
  throw ('STOP: GATE_NO_REGEX_PATCH_V1 failed ('+$viol.Count+')')
}
'GATE_NO_REGEX_PATCH_V1: PASS'
