#requires -Version 7.0
param(
  [Parameter(Mandatory)][string]$Path,
  [string]$RunCommand = ""
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ConfirmPreference='None'
$ProgressPreference='SilentlyContinue'

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$full = $Path
if(-not [System.IO.Path]::IsPathRooted($full)){
  $full = Join-Path $RepoRoot $Path
}
$full = (Resolve-Path -LiteralPath $full).Path

# Determine allowlist (repo-relativ target)
$rel = $full
if($full.StartsWith($RepoRoot, [System.StringComparison]::OrdinalIgnoreCase)){
  $rel = ($full.Substring($RepoRoot.Length)).TrimStart('\','/')
  $rel = $rel -replace '\\','/'
}

$run = $RunCommand
if([string]::IsNullOrWhiteSpace($run)){
  # default: if file looks like a step -> run via ego-step
  if($rel -like "_local/_scratch/step_*.ps1" -or $full -like "*\_local\_scratch\step_*.ps1"){
    $run = 'pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\ego-step.ps1 -StepPath "' + $full + '"'
  } else {
    $run = '# RUN COMMAND HERE'
  }
}

@"
# FULLSWAPTEXT (FILE)
FILE: $full

## OPEN
code -g "$full"

## ALLOWLIST (for step files)
`$EGO_STEP_WRITE_ALLOWLIST = @(
  "$rel"
)

## REPLACE
# Define exact replace-range + paste full replacement block here.

## SAVE
# Speichern (Ctrl+S)

## RUN
$run

## STAGE+COMMIT+PUSH (wenn Repo-Datei geändert)
git add -- "$rel"
git commit -m "edit: $rel"
git push
git status --porcelain=v1
"@