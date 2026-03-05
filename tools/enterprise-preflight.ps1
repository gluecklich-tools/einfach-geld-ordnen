param(
  [switch]$SkipToolParse
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

if(-not (Test-Path -LiteralPath ".\_config.yml")){ Fail "Not in repo root (missing _config.yml)." }
if(-not (Test-Path -LiteralPath ".\tools")){ Fail "Missing tools folder." }

if(-not $SkipToolParse){
  $tools = Get-ChildItem -LiteralPath ".\tools" -File -Filter "*.ps1" -ErrorAction Stop
  foreach($f in $tools){
    $t=$null; $e=$null
    [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$t, [ref]$e)
    if($e -and $e.Count -gt 0){
      Fail ("ParserError in tools file: {0} | {1}" -f $f.Name, $e[0].Message)
    }
  }
}

"ENTERPRISE_PREFLIGHT_OK"