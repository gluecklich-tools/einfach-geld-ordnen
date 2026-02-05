param()
$ErrorActionPreference='Stop'; Set-StrictMode -Version Latest
try{Remove-Module PSReadLine -ErrorAction SilentlyContinue}catch{}
try{if($IsWindows){chcp 65001|Out-Null}}catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$repo=(git rev-parse --show-toplevel 2>$null).Trim()
if([string]::IsNullOrWhiteSpace($repo)){ throw "STOP: repo root not found." }
Set-Location -LiteralPath $repo

$md = Get-ChildItem seiten,pillar -Recurse -File -Filter *.md -EA SilentlyContinue
if(@($md).Count -eq 0){ throw "STOP: no md files in seiten/pillar." }

function CanonUrlFromRel([string]$rel){
  $r=$rel.Replace('\','/').ToLowerInvariant()
  if($r -match '^seiten/(.+)\.md$'){ return "{{ site.baseurl }}/seiten/$($matches[1]).html" }
  if($r -match '^pillar/(.+)\.md$'){ return "{{ site.baseurl }}/pillar/$($matches[1]).html" }
  return $null
}

$U_Start15 = "{{ site.baseurl }}/seiten/start_in_15_minuten.html"
$U_Rechner = "{{ site.baseurl }}/seiten/rechner-uebersicht.html"
$U_Downlds = "{{ site.baseurl }}/seiten/downloads.html"
$U_PillarI = "{{ site.baseurl }}/pillar/index.html"

$rxBlock = [regex]'(?ims)^\s*##\s+Weiter\s*$.*?(?=^\s*##\s+|\z)'
$rxLink  = [regex]'(?im)^\s*-\s*\[([^\]]+)\]\(([^)]+)\)\s*$'

$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $md){
  $rel = $f.FullName.Substring($repo.Length).TrimStart('\','/')
  $txt = [IO.File]::ReadAllText($f.FullName,[Text.UTF8Encoding]::new($false))
  $m = $rxBlock.Match($txt)
  if(-not $m.Success){ continue }

  $block = $m.Value
  $links = $rxLink.Matches($block)
  $issues = New-Object System.Collections.Generic.List[string]
  $selfUrl = CanonUrlFromRel $rel

  if($links.Count -ne 3){ $issues.Add(("Nicht genau 3 Links (Count={0})" -f $links.Count)) | Out-Null }

  $targets = New-Object System.Collections.Generic.List[string]
  foreach($lm in $links){
    $t=($lm.Groups[1].Value).Trim()
    $u=($lm.Groups[2].Value).Trim()
    $targets.Add($u) | Out-Null

    if($t -match '^\s*Weiter\s*$'){ $issues.Add("Linktext ist 'Weiter' (Platzhalter)") | Out-Null }
    if(-not [string]::IsNullOrWhiteSpace($selfUrl) -and $u -eq $selfUrl){ $issues.Add("Self-Link im Weiter-Block") | Out-Null }
  }

  $dup = $targets | Group-Object | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name
  foreach($d in $dup){ $issues.Add(("Doppeltes Ziel: {0}" -f $d)) | Out-Null }

  if($block -notmatch '\{\%\s*include\s+no_sackgasse_footer\.html\s*\%\}'){ $issues.Add("Footer include fehlt direkt nach Weiter") | Out-Null }

  $r = $rel.Replace('\','/').ToLowerInvariant()
  if($r -eq 'pillar/index.md'){
    $want = @($U_Start15,$U_Rechner,$U_Downlds)
    if($targets.Count -eq 3){
      for($i=0;$i -lt 3;$i++){ if($targets[$i] -ne $want[$i]){ $issues.Add("pillar/index Weiter-Reihenfolge/Targets nicht policy-konform") | Out-Null; break } }
    } else { $issues.Add("pillar/index hat nicht 3 Targets") | Out-Null }
  }

  if($issues.Count -gt 0){
    $bad.Add(("{0} :: {1}" -f $rel, ($issues -join '; '))) | Out-Null
  }
}

if($bad.Count -gt 0){
  "FAIL: Weiter UX Policy Gate verletzt (Bad={0})" -f $bad.Count
  $bad | Select-Object -First 120 | ForEach-Object { " - $_" }
  throw "STOP: Weiter UX Policy Gate failed."
}

"PASS: Weiter UX Policy Gate ok."

# Policy file must exist (repo SSOT)
$pol = Join-Path $repo 'tools/policy/WEITER_NAV_POLICY.md'
if(-not (Test-Path -LiteralPath $pol)){ throw 'STOP: Missing tools/policy/WEITER_NAV_POLICY.md' }
