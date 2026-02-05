param([string]$RepoRoot=(git rev-parse --show-toplevel).Trim())
$ErrorActionPreference="Stop"; Set-StrictMode -Version Latest
$rxKey='(?im)^\s*(next|prev|hub)\s*:\s*(.+?)\s*$'
$rxVal='^\{\{\s*site\.baseurl\s*\}\}/[a-z0-9/_\-]+\.html$'
$hits=New-Object System.Collections.Generic.List[string]
$files=Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'seiten'),(Join-Path $RepoRoot 'pillar') -Recurse -File -Filter *.md -EA SilentlyContinue
foreach($f in @($files)){
  $lines=[IO.File]::ReadAllLines($f.FullName,[Text.Encoding]::UTF8)
  if($lines.Length -lt 3){ continue }
  if($lines[0] -ne '---'){ continue }
  $end=-1; for($i=1;$i -lt [Math]::Min($lines.Length,120);$i++){ if($lines[$i] -eq '---'){ $end=$i; break } }
  if($end -lt 0){ continue }
  for($i=1;$i -lt $end;$i++){
    $m=[regex]::Match($lines[$i],$rxKey); if(!$m.Success){ continue }
    $k=$m.Groups[1].Value.ToLowerInvariant(); $v=$m.Groups[2].Value.Trim()
    if($v -notmatch $rxVal){
      $hits.Add(("{0}:{1}  {2}: {3}" -f $f.FullName,($i+1),$k,$v))
    }
  }
}
if(@($hits).Count){ throw ("STOP: frontmatter next/prev/hub invalid:`n" + (@($hits) -join "`n")) }
"PASS: frontmatter next/prev/hub ok"