param()

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$repo = (Get-Location).Path
$toolsDir = Join-Path $repo 'tools'
if(!(Test-Path -LiteralPath $toolsDir)){
  "OK: gate-no-invalid-var-colon PASS (no tools dir)"
  exit 0
}
function Norm([string]$p){
  return (([IO.Path]::GetFullPath($p) -replace '\\','/').ToLowerInvariant())
}
$gateSelf = Join-Path $toolsDir 'gate-no-invalid-var-colon.ps1'
$gateSelfNorm = Norm $gateSelf
function IsExcluded([string]$full){
  $n = Norm $full
  if($n -eq $gateSelfNorm){ return $true }     # self-exclude
  if($n -like '*/.git/*'){ return $true }
  if($n -like '*/_local/*'){ return $true }
  if($n -like '*/node_modules/*'){ return $true }
  if($n -like '*/_site/*'){ return $true }
  return $false
}
function StripComment([string]$line){
  if($null -eq $line){ return '' }
  $t = ($line + '')
  $trim = $t.TrimStart()
  if($trim.StartsWith('#')){ return '' }       # full-line comment
  $hash = $t.IndexOf('#')
  if($hash -ge 0){ return $t.Substring(0,$hash) }  # inline comment tail
  return $t
}

$gitArgs = @(
  "-C"
  $repo
  "ls-files"
  "--"
  "tools/*.ps1"
)

$trackedRelPaths = @(& git @gitArgs)
if($LASTEXITCODE -ne 0){
  throw "git ls-files failed."
}

$targets = @(
  foreach($rel in $trackedRelPaths){
    if([string]::IsNullOrWhiteSpace($rel)){ continue }
    $full = Join-Path $repo ($rel -replace '/', '\')
    if((Test-Path -LiteralPath $full -PathType Leaf) -and (-not (IsExcluded $full))){
      Get-Item -LiteralPath $full
    }
  }
)

$bad = New-Object System.Collections.Generic.List[string]
foreach($f in $targets){
  $arr = @(Get-Content -LiteralPath $f.FullName -Encoding UTF8)
  $ln = 0
  foreach($s in $arr){
    $ln++
    $t = StripComment $s
    if([string]::IsNullOrWhiteSpace($t)){ continue }
    if($t -notlike '*"*'){ continue }
    # allow scoped vars
    if($t -like '*$env:*' -or $t -like '*$global:*' -or $t -like '*$script:*' -or $t -like '*$local:*' -or $t -like '*$private:*' -or $t -like '*$using:*'){ continue }
    # detect "$var:$other" in expandable strings (parser trap)
    if($t -match '\$[A-Za-z_][A-Za-z0-9_]*:\s*\$[A-Za-z_][A-Za-z0-9_]*'){
      $bad.Add(("{0}:L{1}: possible invalid var-colon-var in double quotes; use -f @(or `${{var}}: `${{other}} : {2}" -f @($f.FullName,$ln,$t.TrimEnd())))
    }
  }
}
if($bad.Count -gt 0){
  "FAIL: NO_INVALID_VAR_COLON"
  $bad | ForEach-Object { " - " + $_ }
  throw "STOP: invalid var:var pattern detected"
}
"OK: gate-no-invalid-var-colon PASS"
exit 0
