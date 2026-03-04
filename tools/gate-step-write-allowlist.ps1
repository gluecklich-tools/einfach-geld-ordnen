#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][string]$RepoRoot,
  [Parameter(Mandatory=$true)][string]$StepPath,
  [Parameter(Mandatory=$true)][string[]]$ChangedPaths
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
function Normalize-Rel([string]$p){
  $p = $p -replace '\\','/'
  $p.TrimStart('./')
}
function Get-AllowlistFromStep([string]$stepFile){
  # P0_ALLOWLIST_AST_PARSE
  if(-not (Test-Path -LiteralPath $stepFile -PathType Leaf)){
    throw "FAIL: STEP_WRITE_ALLOWLIST_STEP_NOT_FOUND in step: $stepFile"
  }

  $raw = Get-Content -LiteralPath $stepFile -Raw -Encoding UTF8

  $tokens = $null
  $errors = $null
  $ast = [System.Management.Automation.Language.Parser]::ParseInput($raw, [ref]$tokens, [ref]$errors)
  if($null -ne $errors -and $errors.Count -gt 0){
    $e = $errors[0]
    throw ("FAIL: STEP_WRITE_ALLOWLIST_STEP_PARSERERROR in step: {0} (line {1}, col {2}): {3}" -f $stepFile,$e.Extent.StartLineNumber,$e.Extent.StartColumnNumber,$e.Message)
  }

  # Find assignment to $EGO_STEP_WRITE_ALLOWLIST where RHS is an array expression with string literals only.
  $assigns = $ast.FindAll({
    param($n)
    $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and
    $n.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
    $n.Left.VariablePath.UserPath -eq 'EGO_STEP_WRITE_ALLOWLIST'
  }, $true)

  if($assigns.Count -eq 0){
    throw "FAIL: STEP_WRITE_ALLOWLIST_MISSING in step: $stepFile"
  }

  # Use the last assignment in file (closest to runtime intent)
  $a = $assigns[-1]
  $rhs = $a.Right

  # @("a","b") is ArrayExpressionAst containing ArrayLiteralAst in SubExpression.
  $strings = New-Object System.Collections.Generic.List[string]

  $rhs.FindAll({ param($x) $x -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true) |
    ForEach-Object { $strings.Add($_.Value) }

  if($strings.Count -eq 0){
    throw "FAIL: STEP_WRITE_ALLOWLIST_EMPTY in step: $stepFile"
  }

  # Enforce literal-only: no expandable strings, no variables, no commands.
  $bad = $rhs.FindAll({
    param($x)
    ($x -is [System.Management.Automation.Language.ExpandableStringExpressionAst]) -or
    ($x -is [System.Management.Automation.Language.VariableExpressionAst]) -or
    ($x -is [System.Management.Automation.Language.CommandAst])
  }, $true)

  if($bad.Count -gt 0){
    throw "FAIL: STEP_WRITE_ALLOWLIST_NOT_LITERAL_ONLY in step: $stepFile"
  }

  return $strings.ToArray()
}
$Repo = Resolve-Path -LiteralPath $RepoRoot
$Step = Resolve-Path -LiteralPath $StepPath
$allow = Get-AllowlistFromStep $Step.Path
$changed = @($ChangedPaths) | ForEach-Object { Normalize-Rel $_ }
$viol = @()
foreach($c in $changed){
  if($allow -notcontains $c){
    $viol += $c
  }
}
if(@($viol).Count -gt 0){
  throw ("FAIL: STEP_WRITE_ALLOWLIST_VIOLATION`nAllowed: " + ($allow -join ", ") + "`nChanged: " + ($changed -join ", ") + "`nViolations: " + ($viol -join ", "))
}
"PASS: gate-step-write-allowlist (changed within allowlist)"