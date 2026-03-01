#requires -Version 7.0
param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$ScratchDir = $(Join-Path (Resolve-Path -LiteralPath $RepoRoot).Path "_local\_scratch")
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$ScratchDir = (Resolve-Path -LiteralPath $ScratchDir).Path
if(-not (Test-Path -LiteralPath $ScratchDir)){ throw "STOP: scratch missing: $ScratchDir" }

$files = @(Get-ChildItem -LiteralPath $ScratchDir -File -Filter "step_*.ps1" -ErrorAction Stop | Sort-Object Name)
if($files.Count -eq 0){ "OK: GATE_STEP_JOINPATH_ARRAYSAFE (no step files)"; exit 0 }

$bad = New-Object System.Collections.Generic.List[string]
foreach($f in $files){
  $tokens=$null; $errs=$null
  $ast=[System.Management.Automation.Language.Parser]::ParseFile($f.FullName,[ref]$tokens,[ref]$errs)
  if($errs -and $errs.Count -gt 0){ $bad.Add(("PARSER_FAIL {0}" -f $f.FullName))|Out-Null; continue }

  $cmds = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true)
  foreach($c in $cmds){
    if($c.CommandElements.Count -lt 1){ continue }
    $name = $c.CommandElements[0].Extent.Text.Trim()
    if($name -ne 'Join-Path'){ continue }

    if($c.CommandElements.Count -gt 3){
      $bad.Add(("Join-Path too many args in {0}:{1} :: {2}" -f $f.Name,$c.Extent.StartLineNumber,$c.Extent.Text.Trim()))|Out-Null
      continue
    }

    foreach($e in $c.CommandElements){
      if($e -is [System.Management.Automation.Language.ArrayLiteralAst]){
        $bad.Add(("Join-Path array-literal in {0}:{1} :: {2}" -f $f.Name,$c.Extent.StartLineNumber,$c.Extent.Text.Trim()))|Out-Null
      }
    }
  }
}

if($bad.Count -gt 0){ "FAIL: GATE_STEP_JOINPATH_ARRAYSAFE"; $bad|%{ " - " + $_ }; exit 3 }
"OK: GATE_STEP_JOINPATH_ARRAYSAFE PASS"; exit 0