param(
  [string]$RepoRoot = (git rev-parse --show-toplevel).Trim()
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ chcp 65001 | Out-Null }catch{}
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
if([string]::IsNullOrWhiteSpace($RepoRoot) -or !(Test-Path -LiteralPath $RepoRoot)){
  throw "STOP: RepoRoot invalid."
}
$AliasPath = Join-Path $RepoRoot 'tools/policy/THEMA_ALIAS_MAP.json'
if(!(Test-Path -LiteralPath $AliasPath)){
  throw "STOP: missing tools/policy/THEMA_ALIAS_MAP.json"
}
$MapOut  = Join-Path $RepoRoot 'assets/audit/themen_pfade_map.md'
$GapsOut = Join-Path $RepoRoot 'assets/audit/themen_pfade_real_gaps.md'
$raw = [IO.File]::ReadAllText($AliasPath, [Text.Encoding]::UTF8)
$j = $raw | ConvertFrom-Json
# akzeptiert zwei Formen:
# A) { "thema1": ["aliasA","aliasB"], "thema2": ["..."] }
# B) { "aliasA": "thema1", "aliasB": "thema1" }
$themeToAliases = @{}
if($j -is [System.Collections.IDictionary]){
  foreach($k in $j.Keys){
    $v = $j[$k]
    if($v -is [string]){
      if(-not $themeToAliases.ContainsKey($v)){
        $themeToAliases[$v] = New-Object System.Collections.Generic.List[string]
      }
      $themeToAliases[$v].Add($k)
    } else {
      if(-not $themeToAliases.ContainsKey($k)){
        $themeToAliases[$k] = New-Object System.Collections.Generic.List[string]
      }
      foreach($a in @($v)){
        if($a){ $themeToAliases[$k].Add([string]$a) }
      }
    }
  }
} else {
  throw "STOP: JSON root must be an object."
}
$files = Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'seiten'),(Join-Path $RepoRoot 'pillar') -Recurse -File -Filter *.md -EA Stop
function Get-Permalink([string]$p){
  $t = [IO.File]::ReadAllText($p,[Text.Encoding]::UTF8)
  if($t -match "(?s)\A---\s*(.*?)\s*---"){
    $fm = $Matches[1]
    if($fm -match "(?m)^\s*permalink:\s*(.+)\s*$"){
      return ($Matches[1].Trim() -replace '["'']','')
    }
  }
  return $null
}
$themeHits = @{}
foreach($theme in $themeToAliases.Keys){
  $themeHits[$theme] = New-Object System.Collections.Generic.List[string]
}
foreach($f in $files){
  $rel = $f.FullName.Substring($RepoRoot.Length).TrimStart('\','/')
  $pl  = Get-Permalink $f.FullName
  $probe = (($rel + " " + ($pl ?? "")) .ToLowerInvariant())
  foreach($theme in $themeToAliases.Keys){
    foreach($a in $themeToAliases[$theme]){
      $aa = ([string]$a).ToLowerInvariant()
      if($aa -and $probe.Contains($aa)){
        $u = if($pl){ $pl } else { $rel }
        if(-not $themeHits[$theme].Contains($u)){
          $themeHits[$theme].Add($u)
        }
      }
    }
  }
}
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# Themen → Pfade (generiert)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Quelle: tools/policy/THEMA_ALIAS_MAP.json")
[void]$sb.AppendLine("")
foreach($theme in ($themeHits.Keys | Sort-Object)){
  $hits = $themeHits[$theme]
  [void]$sb.AppendLine("## " + $theme)
  if($hits.Count -eq 0){
    [void]$sb.AppendLine("- (keine Treffer)")
  } else {
    foreach($u in ($hits | Sort-Object)){
      [void]$sb.AppendLine("- " + $u)
    }
  }
  [void]$sb.AppendLine("")
}
$g = New-Object System.Text.StringBuilder
[void]$g.AppendLine("# Reale Gaps (keine Treffer) – generiert")
[void]$g.AppendLine("")
foreach($theme in ($themeHits.Keys | Sort-Object)){
  if($themeHits[$theme].Count -eq 0){
    [void]$g.AppendLine("- " + $theme)
  }
}
$enc = [Text.UTF8Encoding]::new($false)
$mapDir = Split-Path -Parent $MapOut
$gapDir = Split-Path -Parent $GapsOut
if(!(Test-Path -LiteralPath $mapDir)){ New-Item -ItemType Directory -Path $mapDir -Force | Out-Null }
if(!(Test-Path -LiteralPath $gapDir)){ New-Item -ItemType Directory -Path $gapDir -Force | Out-Null }
[IO.File]::WriteAllText($MapOut,  $sb.ToString(), $enc)
[IO.File]::WriteAllText($GapsOut, $g.ToString(),  $enc)
"OK: wrote {0} and {1}" -f $MapOut, $GapsOut