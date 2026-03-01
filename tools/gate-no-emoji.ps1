param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = (git rev-parse --show-toplevel).Trim()
if([string]::IsNullOrWhiteSpace($repo)){ throw "STOP: could not resolve repo root via git." }
Set-Location -LiteralPath $repo

$rx = '(?:[\u2600-\u27BF]|\uFE0F|\u200D|[\uD83C-\uDBFF][\uDC00-\uDFFF])'

$files = Get-ChildItem -LiteralPath $repo -Recurse -File | Where-Object {
  ($_.Extension -in @('.md','.html')) -and
(($_.FullName -replace '\','/') -notlike '*/_audit/*') -and (($_.FullName -replace '\','/') -notlike '*/_local/*') -and (($_.FullName -replace '\','/') -notlike '*/_internal/*') -and
(($_.FullName -replace '\','/') -notlike '*/00_*') -and
(($_.FullName -replace '\','/') -notlike '*/01_*')
}

$hits = New-Object System.Collections.Generic.List[string]
foreach($f in $files){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  if([regex]::IsMatch($raw,$rx)){
    $rel = $f.FullName.Substring($repo.Length).TrimStart('\','/')
    $hits.Add($rel) | Out-Null
  }
}

if($hits.Count -gt 0){
  Write-Host ("FAIL: Emojis found in {0} file(s):" -f $hits.Count)
  $hits | Sort-Object | ForEach-Object { Write-Host (" - {0}" -f $_) }
  throw "Emoji gate failed."
}
Write-Host "PASS: Emoji gate (no emojis in repo content)."