param([string]$RepoRoot=(git rev-parse --show-toplevel).Trim(),[switch]$WithAsciiCheck,[switch]$WithDupCheck)
$ErrorActionPreference="Stop"; Set-StrictMode -Version Latest
$p=Join-Path $RepoRoot "tools/policy/THEMA_ALIAS_MAP.json"; if(!(Test-Path -LiteralPath $p)){throw "STOP: missing THEMA_ALIAS_MAP.json"}
$raw=[IO.File]::ReadAllText($p,[Text.Encoding]::UTF8); if([string]::IsNullOrWhiteSpace($raw)){throw "STOP: empty THEMA_ALIAS_MAP.json"}
$j=$raw|ConvertFrom-Json -EA Stop
$pairs=New-Object System.Collections.Generic.List[object]
if($j -is [System.Collections.IDictionary]){ foreach($k in $j.Keys){ $pairs.Add(@([string]$k,$j[$k])) } }
else{ $props=@($j.PSObject.Properties); if($props.Count -eq 0){throw "STOP: JSON root must be an object."}; foreach($p2 in $props){ $pairs.Add(@([string]$p2.Name,$p2.Value)) } }
$map=@{}
foreach($pair in $pairs){ $k=[string]$pair[0]; $v=$pair[1]; if([string]::IsNullOrWhiteSpace($k)){throw "STOP: empty key"}; if($v -is [string]){ $t=[string]$v; if(!$t){throw "STOP: empty theme for alias '$k'"}; if(!$map.ContainsKey($t)){$map[$t]=New-Object System.Collections.Generic.List[string]}; $map[$t].Add($k) } else { if(!$map.ContainsKey($k)){$map[$k]=New-Object System.Collections.Generic.List[string]}; foreach($a in @($v)){ if($a){$map[$k].Add(([string]$a).Trim())} } } }
$rx='^[\x00-\x7F]+$'
if($WithAsciiCheck){ foreach($t in $map.Keys){ if($t -notmatch $rx){throw "STOP: non-ASCII theme '$t'"}; foreach($a in $map[$t]){ if($a -and $a -notmatch $rx){throw "STOP: non-ASCII alias '$a' (theme '$t')"} } } }
if($WithDupCheck){ $seen=@{}; foreach($t in $map.Keys){ foreach($a in $map[$t]){ if(!$a){continue}; if(!$seen.ContainsKey($a)){$seen[$a]=New-Object System.Collections.Generic.List[string]}; $seen[$a].Add($t) } }; $dups=@($seen.GetEnumerator()|?{$_.Value.Count -gt 1}); if($dups.Count){ $m=""; foreach($d in $dups){ $m+="- $($d.Key): $($d.Value -join ', ')"+"`n" }; throw ("STOP: duplicate aliases across themes:`n"+$m) } }
"PASS: THEMA_ALIAS_MAP.json valid"