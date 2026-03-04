#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

# P0 gate: block placeholder-like regex patterns in *gate* scripts.
# Heuristic: look for "<...>" inside regex literals or -match patterns in tools/gate-*.ps1

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$gates = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "tools") -File -Filter "gate-*.ps1" -ErrorAction SilentlyContinue

$hits = New-Object System.Collections.Generic.List[string]
foreach($f in $gates){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  # placeholder angle brackets inside common regex contexts
  if($raw -match "(?ms)(-match\s+['`"])([^'`"]*<[^>]+>[^'`"]*)(['`"])" ){
    $hits.Add($f.FullName)
  }
  if($raw -match "(?ms)\[regex\]::(Match|Matches|IsMatch)\([^,]+,\s*['`"][^'`"]*<[^>]+>[^'`"]*['`"]"){
    $hits.Add($f.FullName)
  }
}

$hits = @($hits | Sort-Object -Unique)
if($hits.Count -gt 0){
  Fail ("FAIL: NO_PLACEHOLDER_REGEX_IN_GATES`nFound placeholder-like <...> in:`n - " + ($hits -join "`n - "))
}

"PASS: gate-no-placeholder-regex-in-gates"