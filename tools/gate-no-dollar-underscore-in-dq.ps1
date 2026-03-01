param()

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function IsExcluded([string]$full){
  $p = $full.ToLowerInvariant()

  if($p -like '*\.git\*'){ return $true }
  if($p -like '*\_local\*'){ return $true }
  if($p -like '*\node_modules\*'){ return $true }
  if($p -like '*\_site\*'){ return $true }

  # exclude THIS gate file to prevent self-trigger
  if($p -like '*\tools\gate-no-dollar-underscore-in-dq.ps1'){ return $true }

  return $false
}

# Build needles without writing dangerous sequences literally
$d = '$'
$us = '_'
$dot = '.'
$bs = '\'
$dq = '"'
$star = '*'

$needle_dq_token = ($dq + $d + $us + $dot)

$needle_like_dq  = ('-like ' + $dq + $star + $bs + $d + $us + $dot)
$needle_like_sq  = ('-like ' + "'" + $star + $bs + $d + $us + $dot)

$needle_nlike_dq = ('-notlike ' + $dq + $star + $bs + $d + $us + $dot)
$needle_nlike_sq = ('-notlike ' + "'" + $star + $bs + $d + $us + $dot)

$repo  = (Get-Location).Path
$files = Get-ChildItem -LiteralPath $repo -Recurse -File -Include '*.ps1' |
  Where-Object { -not (IsExcluded $_.FullName) }

$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $files){
  $ln = 0
  foreach($line in [IO.File]::ReadAllLines($f.FullName,[Text.UTF8Encoding]::new($false))){
    $ln++

    if($line.Contains($needle_dq_token)){
      $bad.Add(('{0}:L{1}: forbidden token (double-quote + dollar + underscore + dot)' -f $f.FullName,$ln))
    }

    if($line.Contains($needle_like_dq) -or $line.Contains($needle_like_sq)){
      $bad.Add(('{0}:L{1}: -like pattern contains backslash-dollar-underscore-dot' -f $f.FullName,$ln))
    }

    if($line.Contains($needle_nlike_dq) -or $line.Contains($needle_nlike_sq)){
      $bad.Add(('{0}:L{1}: -notlike pattern contains backslash-dollar-underscore-dot' -f $f.FullName,$ln))
    }
  }
}

if($bad.Count -gt 0){
  'FAIL: gate-no-dollar-underscore-in-dq'
  $bad | ForEach-Object { ' - ' + $_ }
  exit 2
}

'OK: gate-no-dollar-underscore-in-dq PASS'
exit 0
