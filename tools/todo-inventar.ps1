param(
  [string]$RepoRoot = (git rev-parse --show-toplevel).Trim(),
  [string]$SsotRoot = $env:EGO_SSOT_ROOT
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{Remove-Module PSReadLine -EA SilentlyContinue}catch{}
try{chcp 65001|Out-Null}catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$ts = "{0}_{1}" -f (Get-Date).ToString("yyyyMMdd_HHmmss_fff"), (Get-Random -Minimum 1000 -Maximum 9999)
$outDir = Join-Path $RepoRoot 'tools/_reports'
if(!(Test-Path -LiteralPath $outDir)){ New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$out = Join-Path $outDir ("TODO_INVENTAR_{0}.md" -f $ts)
# Matches TODO/FIXME/... but ignores frontmatter keys next:/prev:/hub:
$rx = '(?im)^\s*(?!\s*(?:next|prev|hub)\s*:)\s*(?:[-*]\s*)?(TODO|FIXME|HACK|XXX|OFFEN|NEXT|WIP)\b.*$'
$exts = @('.md','.ps1','.yml','.yaml','.json')
$skipLike = @('*/_ARCHIVE/*','*/tools/_reports/*')
function Get-Hits([string]$Root,[string]$Tag){
  $files = Get-ChildItem -LiteralPath $Root -Recurse -File -EA SilentlyContinue | Where-Object {`n    $p = ($_.FullName -replace '\','/')
    $p = ($_.FullName -replace '\','/')
    ($exts -contains $_.Extension) -and ($p -notlike $skipLike[0]) -and ($p -notlike $skipLike[1])
  }
  $m = $files | Select-String -Pattern $rx -EA SilentlyContinue
  foreach($h in @($m)){
    "- {0}: {1}:{2}  {3}" -f $Tag,$h.Path,$h.LineNumber,$h.Line.Trim()
  }
}
$repoHits = @()
foreach($p in @('seiten','pillar','tools','assets')){
  $pp = Join-Path $RepoRoot $p
  if(Test-Path -LiteralPath $pp){ $repoHits += @(Get-Hits $pp 'REPO') }
}
$ssotHits = @()
if($SsotRoot -and (Test-Path -LiteralPath $SsotRoot)){
  $ssotHits += @(Get-Hits $SsotRoot 'SSOT')
} else {
  $ssotHits += @("- SSOT: (kein Scan – EGO_SSOT_ROOT fehlt oder Pfad existiert nicht)")
}
$txt = @()
$txt += '# TODO Inventar (generiert)'
$txt += "Zeit: $ts"
$txt += "Repo: $RepoRoot"
$txt += "SSOT: $SsotRoot"
$txt += ''
$txt += '## Priorität 1 (Build/Live/Gates)'
$txt += @($repoHits + $ssotHits)
$txt += ''
[IO.File]::WriteAllText($out, ($txt -join "`n"), [Text.UTF8Encoding]::new($false))
"OK: $out"