param()

function New-Utf8NoBomEncoding {
  return [Text.UTF8Encoding]::new($false)
}

function Read-Utf8NoBom([string]$p){
  $enc = New-Utf8NoBomEncoding
  return [IO.File]::ReadAllText($p,$enc)
}

function Write-Utf8NoBom([string]$p,[string]$t){
  $enc = New-Utf8NoBomEncoding
  [IO.File]::WriteAllText($p,$t,$enc)
}

function Backup-File([string]$src,[string]$bkDir){
  New-Item -ItemType Directory -Path $bkDir -Force | Out-Null
  $name = Split-Path -Leaf $src
  Copy-Item -LiteralPath $src -Destination (Join-Path $bkDir $name) -Force
}

function Find-FrontmatterEnd([string[]]$lines){
  if($lines.Length -eq 0){ return -1 }
  if($lines[0] -ne '---'){ return -1 }
  for($i=1;$i -lt $lines.Length;$i++){
    if($lines[$i] -eq '---'){ return $i }
  }
  return -1
}

function Split-Body([string[]]$lines){
  $fmEnd = Find-FrontmatterEnd $lines
  if($fmEnd -lt 0){ return @{ FmEnd=-1; Head=@(); Body=$lines } }
  $head = @()
  for($i=0;$i -le $fmEnd;$i++){ $head += $lines[$i] }
  $body = @()
  for($i=$fmEnd+1;$i -lt $lines.Length;$i++){ $body += $lines[$i] }
  return @{ FmEnd=$fmEnd; Head=$head; Body=$body }
}

function Make-Char([int]$cp){ return [char]$cp }

function Normalize-VisibleUmlauts([string]$s){
  $A = Make-Char 0x00C4
  $O = Make-Char 0x00D6
  $U = Make-Char 0x00DC
  $a = Make-Char 0x00E4
  $o = Make-Char 0x00F6
  $u = Make-Char 0x00FC
  $ss = Make-Char 0x00DF

  $s = $s.Replace('Ae',[string]$A).Replace('Oe',[string]$O).Replace('Ue',[string]$U)
  $s = $s.Replace('ae',[string]$a).Replace('oe',[string]$o).Replace('ue',[string]$u)

  # safe word-map for ss -> ß (ASCII-only source)
  $map = @(
    @('\bdass\b', ('da' + [string]$ss)),
    @('\bmuss\b', ('mu' + [string]$ss)),
    @('\bmuesste\b', ('m' + [string]$u + ('' + [string]$ss) + 'te')),
    @('\bmuessten\b', ('m' + [string]$u + ('' + [string]$ss) + 'ten')),
    @('\bgross\b', ('gro' + [string]$ss)),
    @('\bgroesser\b', ('gr' + [string]$o + ('' + [string]$ss) + 'er')),
    @('\bgroesste\b', ('gr' + [string]$o + ('' + [string]$ss) + 'te')),
    @('\bweiss\b', ('wei' + [string]$ss)),
    @('\bFuss\b', ('Fu' + [string]$ss)),
    @('\bMass\b', ('Ma' + [string]$ss)))
  foreach($r in $map){
    $s = [Text.RegularExpressions.Regex]::Replace($s,$r[0],$r[1])
  }
  return $s
}

function Replace-VisibleTextOnly([string]$line){
  # do not touch URLs in markdown links: [text](url)  -> normalize only text
  $rx = [Text.RegularExpressions.Regex]::new('(!?\[([^\]]*)\]\(([^)]+)\))')
  $ms = $rx.Matches($line)
  if($ms.Count -eq 0){ return (Normalize-VisibleUmlauts $line) }

  $out = ''
  $pos = 0
  foreach($m in $ms){
    $pre = $line.Substring($pos, $m.Index - $pos)
    $out += (Normalize-VisibleUmlauts $pre)

    $full = $m.Groups[1].Value
    $vis  = $m.Groups[2].Value
    $url  = $m.Groups[3].Value

    $prefix = ''
    if($full.StartsWith('!')){ $prefix='!' }
    $out += ($prefix + '[' + (Normalize-VisibleUmlauts $vis) + '](' + $url + ')')

    $pos = $m.Index + $m.Length
  }
  if($pos -lt $line.Length){
    $out += (Normalize-VisibleUmlauts $line.Substring($pos))
  }
  return $out
}

function Body-Scan([string[]]$body,[string]$relPath){
  $hits = New-Object System.Collections.Generic.List[string]
  $inFence = $false

  for($i=0;$i -lt $body.Length;$i++){
    $line = $body[$i]
    if($line -match '^\s*```'){ $inFence = -not $inFence; continue }
    if($inFence){ continue }

    $m1 = [Text.RegularExpressions.Regex]::Matches($line,'Ae|Oe|Ue|ae|oe|ue')
    foreach($m in $m1){ $hits.Add(("{0}:{1}:{2}" -f @($relPath, ($i+1), $m.Value)) })

    $m2 = [Text.RegularExpressions.Regex]::Matches($line,'\b(dass|muss|muesste|muessten|gross|groesser|groesste|weiss|Fuss|Mass)\b')
    foreach($m in $m2){ $hits.Add(("{0}:{1}:{2}" -f @($relPath, ($i+1), $m.Value)) })
  }

  return $hits.ToArray()
}

function Find-WeiterBlock([string[]]$body){
  # returns @{ Found=$true; Start=i; Links=@(...); HasFooter=$bool }
  $start = -1
  for($i=0;$i -lt $body.Length;$i++){
    if($body[$i] -match '^\s*##\s+Weiter\s*$'){ $start=$i; break }
  }
  if($start -lt 0){ return @{ Found=$false; Start=-1; Links=@(); HasFooter=$false } }

  $links = New-Object System.Collections.Generic.List[string]
  $hasFooter = $false

  for($j=$start+1;$j -lt $body.Length;$j++){
    $ln = $body[$j]
    if($ln -match '^\s*##\s+'){ break }
    if($ln -match 'no_sackgasse_footer'){ $hasFooter = $true }
    $m = [Text.RegularExpressions.Regex]::Match($ln,'\(([^)]+)\)')
    if($m.Success){ [void]$links.Add($m.Groups[1].Value) }
  }

  return @{ Found=$true; Start=$start; Links=$links.ToArray(); HasFooter=$hasFooter }
}

function Write-Report([string]$path,[string[]]$lines){
  $enc = New-Utf8NoBomEncoding
  [IO.File]::WriteAllLines($path,$lines,$enc)
}
