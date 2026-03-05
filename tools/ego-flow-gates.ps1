$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

if(-not (Test-Path -LiteralPath ".\_config.yml")){ Fail "Not in repo root (missing _config.yml)." }

# Gate 1: tools parser ok
$tools = Get-ChildItem -LiteralPath ".\tools" -File -Filter "*.ps1" -ErrorAction Stop
foreach($f in $tools){
  $t=$null; $e=$null
  [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$t, [ref]$e)
  if($e -and $e.Count -gt 0){
    Fail ("ParserError in tools file: {0} | {1}" -f $f.Name, $e[0].Message)
  }
}

# Gate 2: basic md scan for local absolute paths (keep minimal, safe)
$md = @()
if(Test-Path -LiteralPath ".\index.md"){ $md += Get-Item ".\index.md" }
if(Test-Path -LiteralPath ".\seiten"){ $md += Get-ChildItem ".\seiten" -Recurse -File -Filter "*.md" }
if(Test-Path -LiteralPath ".\pillar"){ $md += Get-ChildItem ".\pillar" -Recurse -File -Filter "*.md" }

foreach($f in $md){
  $raw = Get-Content -LiteralPath $f.FullName -Raw
  if($raw -match '(?i)[A-Z]:\\Users\\'){ Fail ("LocalPath leak in md: {0}" -f $f.FullName) }
  if($raw -match '(?i)C:\\Users\\'){ Fail ("LocalPath leak in md: {0}" -f $f.FullName) }
}

"PASS: ego-flow-gates (minimal parser-safe)"