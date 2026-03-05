$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function New-Utf8NoBomEncoding {
  return (New-Object System.Text.UTF8Encoding($false))
}

function Normalize-VisibleUmlauts([string]$s){
  if($null -eq $s){ return "" }
  # "sichtbare" Umschreibungen vereinheitlichen (minimal, deterministic)
  $x = $s
  $x = $x -replace 'Ae','Ä' -replace 'Oe','Ö' -replace 'Ue','Ü'
  $x = $x -replace 'ae','ä' -replace 'oe','ö' -replace 'ue','ü'
  return $x
}

function Normalize-MdLinksPreserveUrl([string]$line){
  if([string]::IsNullOrEmpty($line)){ return "" }

  # Match: [visible](url) or ![visible](url) – normalize only visible part
  $rx = [Text.RegularExpressions.Regex]::new('(!?)\[(.*?)\]\(([^)]+)\)')
  $ms = $rx.Matches($line)
  if($ms.Count -eq 0){ return (Normalize-VisibleUmlauts $line) }

  $out = ""
  $pos = 0
  foreach($m in $ms){
    $pre = $line.Substring($pos, ($m.Index - $pos))
    $out += (Normalize-VisibleUmlauts $pre)

    $prefix = $m.Groups[1].Value
    $vis    = $m.Groups[2].Value
    $url    = $m.Groups[3].Value

    $out += ($prefix + "[" + (Normalize-VisibleUmlauts $vis) + "](" + $url + ")")
    $pos = $m.Index + $m.Length
  }

  if($pos -lt $line.Length){
    $out += (Normalize-VisibleUmlauts $line.Substring($pos))
  }

  return $out
}

function Body-Scan([string[]]$body,[string]$relPath){
  # returns string[] hits like "relpath:line:match"
  $hits = New-Object System.Collections.Generic.List[string]
  $inFence = $false

  for($i=0; $i -lt $body.Length; $i++){
    $line = $body[$i]

    if($line -match '^\s*```'){ $inFence = -not $inFence; continue }
    if($inFence){ continue }

    # 1) visible-umlaut patterns
    $m1 = [Text.RegularExpressions.Regex]::Matches($line,'Ae|Oe|Ue|ae|oe|ue')
    foreach($m in $m1){
      [void]$hits.Add(("{0}:{1}:{2}" -f @($relPath, ($i+1), $m.Value)))
    }

    # 2) common wording patterns (minimal)
    $m2 = [Text.RegularExpressions.Regex]::Matches($line,'\b(dass|muss|muesste|muessten|gross|groesser|groesste|weiss|Fuss|Mass)\b')
    foreach($m in $m2){
      [void]$hits.Add(("{0}:{1}:{2}" -f @($relPath, ($i+1), $m.Value)))
    }
  }

  return $hits.ToArray()
}

function Find-WeiterBlock([string[]]$body){
  # returns @{ Found=bool; Start=int; Links=string[]; HasFooter=bool }
  $start = -1
  for($i=0; $i -lt $body.Length; $i++){
    if($body[$i] -match '^\s*##\s+Weiter\s*$'){ $start = $i; break }
  }
  if($start -lt 0){ return @{ Found=$false; Start=-1; Links=@(); HasFooter=$false } }

  $links = New-Object System.Collections.Generic.List[string]
  $hasFooter = $false

  for($j=$start+1; $j -lt $body.Length; $j++){
    $ln = $body[$j]
    if($ln -match '^\s*##\s+'){ break }
    if($ln -match 'no_sackgasse_footer'){ $hasFooter = $true }

    # extract first (...) occurrence (minimal, deterministic)
    $m = [Text.RegularExpressions.Regex]::Match($ln,'\(([^)]+)\)')
    if($m.Success){
      [void]$links.Add($m.Groups[1].Value)
    }
  }

  return @{ Found=$true; Start=$start; Links=$links.ToArray(); HasFooter=$hasFooter }
}

function Write-Report([string]$path,[string[]]$lines){
  $enc = New-Utf8NoBomEncoding
  $dir = Split-Path -Parent $path
  if($dir -and -not (Test-Path -LiteralPath $dir)){
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  [IO.File]::WriteAllLines($path, $lines, $enc)
}