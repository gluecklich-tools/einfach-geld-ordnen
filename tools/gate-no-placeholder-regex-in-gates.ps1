#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

# P0 gate: block placeholder-like <...> ONLY when it is used as a regex PATTERN.
# AST-based, so normal text "<...>" does not trigger.

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$gates = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "tools") -File -Filter "gate-*.ps1" -ErrorAction SilentlyContinue

$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $gates){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $t=$null; $e=$null
  $ast=[System.Management.Automation.Language.Parser]::ParseInput($raw,[ref]$t,[ref]$e)
  if($e -and $e.Count -gt 0){ continue } # parser gate handles real parse errors elsewhere

  # -match/-notmatch with string literal RHS
  $ast.FindAll({
    param($n)
    $n -is [System.Management.Automation.Language.BinaryExpressionAst] -and
    ($n.Operator -in @('Match','NotMatch')) -and
    ($n.Right -is [System.Management.Automation.Language.StringConstantExpressionAst])
  }, $true) | ForEach-Object {
    if($_.Right.Value -match '<[^>]+>'){ $bad.Add($f.FullName) }
  }

  # [regex]::Match|Matches|IsMatch( text, "pattern" )
  $ast.FindAll({
    param($n)
    $n -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
    $n.Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
    $n.Expression.TypeName.FullName -eq 'regex' -and
    ($n.Member.Value -in @('Match','Matches','IsMatch')) -and
    $n.Arguments.Count -ge 2 -and
    ($n.Arguments[1] -is [System.Management.Automation.Language.StringConstantExpressionAst])
  }, $true) | ForEach-Object {
    if($_.Arguments[1].Value -match '<[^>]+>'){ $bad.Add($f.FullName) }
  }
}

$bad = @($bad | Sort-Object -Unique)
if($bad.Count -gt 0){
  Fail ("FAIL: NO_PLACEHOLDER_REGEX_IN_GATES Found placeholder-like <...> in regex patterns:`n - " + ($bad -join "`n - "))
}

"PASS: gate-no-placeholder-regex-in-gates"