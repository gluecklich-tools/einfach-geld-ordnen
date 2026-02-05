param([string]$RepoRoot=(git rev-parse --show-toplevel).Trim(),[string]$SsotRoot=$env:EGO_SSOT_ROOT)
$ErrorActionPreference='Stop'; Set-StrictMode -Version Latest
try{Remove-Module PSReadLine -EA SilentlyContinue}catch{}; try{chcp 65001|Out-Null}catch{}; [Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$ts=(Get-Date).ToString('yyyyMMdd_HHmmss')
$outDir=Join-Path $RepoRoot 'tools/_reports'; if(!(Test-Path -LiteralPath $outDir)){New-Item -ItemType Directory -Path $outDir -Force|Out-Null}
$out=Join-Path $outDir ("TODO_INVENTAR_{0}.md" -f $ts)
$rx='(?im)^\s*(?!\s*(?:next|prev|hub)\s*:)\s*(?:[-*]\s*)?(TODO|FIXME|HACK|XXX|OFFEN|NEXT|WIP)\b.*
$exts=@('.md','.ps1','.yml','.json')
$skipRx='[\\/]_ARCHIVE[\\/]|[\\/]tools[\\/]_reports[\\/]'
function Hits([string]$root,[string]$tag){
  $files=Get-ChildItem -LiteralPath $root -Recurse -File -EA SilentlyContinue | Where-Object {
    $exts -contains $_.Extension -and $_.FullName -notmatch $skipRx
  }
  $m=$files | Select-String -Pattern $rx -EA SilentlyContinue
  foreach($h in @($m)){
    "- {0}: {1}:{2}  {3}" -f $tag,$h.Path,$h.LineNumber,$h.Line.Trim()
  }
}
$repoHits=@()
foreach($p in @('seiten','pillar','tools','assets')){
  $pp=Join-Path $RepoRoot $p
  if(Test-Path -LiteralPath $pp){ $repoHits += @(Hits $pp 'REPO') }
}
$ssotHits=@()
if($SsotRoot -and (Test-Path -LiteralPath $SsotRoot)){
  $ssotHits += @(Hits $SsotRoot 'SSOT')
} else {
  $ssotHits += @("- SSOT: (kein Scan – EGO_SSOT_ROOT fehlt oder Pfad existiert nicht)")
}
$txt = @()
$txt += "# TODO Inventar (generiert)"
$txt += "Zeit: $ts"
$txt += "Repo: $RepoRoot"
$txt += "SSOT: $SsotRoot"
$txt += ""
$txt += "## Priorität 1 (Build/Live/Gates)"
$txt += @($repoHits + $ssotHits)
$txt += ""
[IO.File]::WriteAllText($out, ($txt -join "`n"), [Text.UTF8Encoding]::new($false))
"OK: $out"
$exts=@('.md','.ps1','.yml','.json')
$skipRx='[\\/]_ARCHIVE[\\/]|[\\/]tools[\\/]_reports[\\/]'
function Hits([string]$root,[string]$tag){
  $files=Get-ChildItem -LiteralPath $root -Recurse -File -EA SilentlyContinue | Where-Object {
    $exts -contains $_.Extension -and $_.FullName -notmatch $skipRx
  }
  $m=$files | Select-String -Pattern $rx -EA SilentlyContinue
  foreach($h in @($m)){
    "- {0}: {1}:{2}  {3}" -f $tag,$h.Path,$h.LineNumber,$h.Line.Trim()
  }
}
$repoHits=@()
foreach($p in @('seiten','pillar','tools','assets')){
  $pp=Join-Path $RepoRoot $p
  if(Test-Path -LiteralPath $pp){ $repoHits += @(Hits $pp 'REPO') }
}
$ssotHits=@()
if($SsotRoot -and (Test-Path -LiteralPath $SsotRoot)){
  $ssotHits += @(Hits $SsotRoot 'SSOT')
} else {
  $ssotHits += @("- SSOT: (kein Scan – EGO_SSOT_ROOT fehlt oder Pfad existiert nicht)")
}
$txt = @()
$txt += "# TODO Inventar (generiert)"
$txt += "Zeit: $ts"
$txt += "Repo: $RepoRoot"
$txt += "SSOT: $SsotRoot"
$txt += ""
$txt += "## Priorität 1 (Build/Live/Gates)"
$txt += @($repoHits + $ssotHits)
$txt += ""
[IO.File]::WriteAllText($out, ($txt -join "`n"), [Text.UTF8Encoding]::new($false))
"OK: $out"