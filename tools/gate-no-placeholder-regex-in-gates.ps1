param()

. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1')

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ENTERPRISE_LAW:
# - file-first
# - git-tracked-only target collection
# - scan only tracked gate files
# - NEVER self-flag this gate file

# Fails if any gate script contains placeholder regex inside -match / -replace
# patterns, e.g. "<...>", "<foo>", "(?<name>...)" misuse in placeholder form.
# AST-based, so normal text "<...>" does not trigger.

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$SelfPath = (Resolve-Path -LiteralPath $PSCommandPath).Path

$gates = New-Object System.Collections.Generic.List[string]

$trackedGateFiles = @(
  git -C $RepoRoot ls-files -- 'tools/gate-*.ps1'
)

foreach($rel in $trackedGateFiles){
  if([string]::IsNullOrWhiteSpace($rel)){ continue }
  $full = Join-Path $RepoRoot $rel
  if(-not (Test-Path -LiteralPath $full)){ continue }
  $resolved = (Resolve-Path -LiteralPath $full).Path
  if($resolved -ieq $SelfPath){ continue }
  $gates.Add($resolved) | Out-Null
}

$gates = @($gates | Sort-Object -Unique)

$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $gates){
  $tokens = $null
  $errors = $null
  $ast = [System.Management.Automation.Language.Parser]::ParseFile($f, [ref]$tokens, [ref]$errors)
  if($errors -and $errors.Count -gt 0){
    $bad.Add(("PARSE_ERROR: {0}" -f $f)) | Out-Null
    continue
  }

  $cmds = $ast.FindAll({
    param($n)
    $n -is [System.Management.Automation.Language.BinaryExpressionAst] -and
    ($n.Operator -eq [System.Management.Automation.Language.TokenKind]::Ireplace -or
     $n.Operator -eq [System.Management.Automation.Language.TokenKind]::Creplace -or
     $n.Operator -eq [System.Management.Automation.Language.TokenKind]::Imatch   -or
     $n.Operator -eq [System.Management.Automation.Language.TokenKind]::Cmatch)
  }, $true)

  foreach($b in $cmds){
    $rhs = $b.Right
    if($rhs -isnot [System.Management.Automation.Language.StringConstantExpressionAst]){ continue }
    $pat = [string]$rhs.Value

    if($pat -match '<[^>]+>' -or $pat -match '\(\?<[^>]+>\.\.\.\)'){
      $bad.Add(("{0}:{1} :: {2}" -f $f, $rhs.Extent.StartLineNumber, $pat)) | Out-Null
    }
  }
}

if($bad.Count -gt 0){
  Write-Host 'FAIL: placeholder regex found in gate scripts:'
  $bad | ForEach-Object { Write-Host (' - ' + $_) }
  throw ('FAIL: EXIT_ONLY_REWRITE_V1: tools/gate-no-placeholder-regex-in-gates.ps1 line 70')
}

Write-Host 'PASS: no placeholder regex in gate scripts'
exit 0