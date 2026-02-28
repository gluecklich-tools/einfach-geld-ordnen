$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo = (Get-Location).Path

function IsExcluded([string]$full){
  $p = $full.ToLowerInvariant()
  if($p -like "*\.git\*"){ return $true }
  if($p -like "*\_local\*"){ return $true }
  if($p -like "*\_site\*"){ return $true }
  if($p -like "*\node_modules\*"){ return $true }
  return $false
}

$files = Get-ChildItem -LiteralPath $repo -Recurse -File -Filter "*.ps1" | Where-Object { -not (IsExcluded $_.FullName) }
$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $files){
  $inHere = $false
  $endToken = $null
  $lineNo = 0
  foreach($line in [IO.File]::ReadAllLines($f.FullName, [Text.UTF8Encoding]::new($false))){
    $lineNo++
    $t = $line.Trim()

    if(-not $inHere){
      if($t -match "^\@\x22"){ $inHere = $true; $endToken = "\x22@"; continue }
      if($t -match "^\@'"){  $inHere = $true; $endToken = "'@";  continue }
    } else {
      if($t -match "^\@\x22" -or $t -match "^\@'"){
        $bad.Add(("{0}:L{1}: nested here-string start" -f $f.FullName, $lineNo))
        continue
      }
      if($t -eq $endToken){ $inHere = $false; $endToken = $null; continue }
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: NO_HERESTRING_NESTING"
  $bad | ForEach-Object { " - $_" }
  exit 2
}
"OK: gate-no-heresting-nesting PASS"
exit 0
