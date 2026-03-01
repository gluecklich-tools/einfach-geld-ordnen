param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$ReportsRel = "_local/reports",
  [int]$Take = 50
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$dir = Join-Path $RepoRoot $ReportsRel
if(!(Test-Path -LiteralPath $dir)){
  "PASS: REPORTS_NO_ERRORS (no reports dir)"
  exit 0
}

$files = Get-ChildItem -LiteralPath $dir -File -Force -Filter *.md |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First $Take

$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $files){
  $lines = $null
  try{ $lines = [IO.File]::ReadAllLines($f.FullName, $enc) }catch{ continue }

  for($i=0; $i -lt $lines.Length; $i++){
    $ln = $lines[$i]
    if($null -eq $ln){ continue }
    $t = $ln.Trim()

    # harte Marker
    if($t.StartsWith("FAIL:", [StringComparison]::OrdinalIgnoreCase) -or
       $t.StartsWith("STOP:", [StringComparison]::OrdinalIgnoreCase) -or
       $t.StartsWith("PARSER_FAIL:", [StringComparison]::OrdinalIgnoreCase) -or
       $t.StartsWith("Exception:", [StringComparison]::OrdinalIgnoreCase)){
      $bad.Add("$($f.Name):$($i+1) :: $t")
      continue
    }

    # "Error:" ist oft im PS-Output, wir nehmen es nur, wenn es nicht eindeutig PASS-Kontext ist
    if($t.StartsWith("Error:", [StringComparison]::OrdinalIgnoreCase)){
      $bad.Add("$($f.Name):$($i+1) :: $t")
      continue
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: REPORTS_NO_ERRORS"
  $bad | ForEach-Object { " - $_" }
  exit 3
}

"PASS: REPORTS_NO_ERRORS"
exit 0