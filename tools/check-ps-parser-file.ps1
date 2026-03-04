#requires -Version 7.0
param(
  [Parameter(Mandatory)][string]$Path
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){
  Write-Error $m
  exit 1
}

if([string]::IsNullOrWhiteSpace($Path)){ Fail "STOP: -Path empty" }

$p = $Path
try{ $p = (Resolve-Path -LiteralPath $Path).Path } catch { Fail ("STOP: file not found: " + $Path) }

$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($p, [ref]$tokens, [ref]$errors)

if($errors -and $errors.Count -gt 0){
  "PARSER_FAIL: {0} error(s) in {1}" -f @($errors.Count, $p)
  foreach($e in $errors){
    ("- {0} @ {1}" -f @($e.Message, ($e.Extent.Text -replace "\r?\n"," ")))
  }
  exit 1
}

"OK: parser clean: $p"
exit 0
