param(
  [Parameter(Mandatory=$true)][string]$NamePrefix
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

function Get-RepoRoot {
  $p = (& git rev-parse --show-toplevel 2>$null)
  if (-not $p) { Fail "RepoRoot konnte nicht bestimmt werden (git rev-parse)." }
  return (Resolve-Path -LiteralPath $p).Path
}

function New-Dir([string]$p){
  if ($p -and -not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

function Write-Utf8NoBomLf {
  param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$Text)
  $dir = Split-Path -Parent $Path
  New-Dir $dir
  $t = $Text -replace "
","
"
  $t = $t -replace "
","
"
  if (-not $t.EndsWith("
")) { $t += "
" }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $t, $enc)
}

$RepoRoot = Get-RepoRoot
$Scratch = Join-Path $RepoRoot "_local\_scratch"
New-Dir $Scratch

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$path = Join-Path $Scratch ("{0}_{1}.ps1" -f $NamePrefix, $ts)

# IMPORTANT: single-quoted stub lines -> no variable expansion ever
$stubLines = @()
$stubLines += '# STEP'
$stubLines += '$ErrorActionPreference=''Stop'''
$stubLines += 'Set-StrictMode -Version Latest'
$stubLines += ''
$stubLines += '$EGO_STEP_WRITE_ALLOWLIST = @('
$stubLines += '  ''_local\_reports\'''
$stubLines += ')'
$stubLines += '$EGO_STEP_PRESTEP_DIRTY_ALLOWLIST = @('
$stubLines += ')'
$stubLines += '$EGO_STEP_BACKUP_REQUIRED = ''YES'''
$stubLines += ''
$stubLines += '# TODO: FULLSWAP'

Write-Utf8NoBomLf -Path $path -Text (($stubLines -join "
") + "
")
$path

# EGO_MANAGED_BLOCK:APRIL03_STEPNEW:START
# Literalpfade fuer OPEN/CREATE bevorzugen; kein Vertrauen auf Session-Restzustand.
# Step-Erzeugung darf nicht in Stub-/Header-only-RUN uebergehen.
# Neuer Praeventionsstandard: mutierende Steps sollen Backup vor Aenderung und optionalen prestep dirty allowlist-scope sichtbar deklarieren.
# EGO_MANAGED_BLOCK:APRIL03_STEPNEW:END
