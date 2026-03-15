#requires -Version 7.0
param()

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
try { if ($IsWindows) { chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

function Fail([string]$m) { throw $m }

$Repo = $null
try { $Repo = (git rev-parse --show-toplevel 2>$null).Trim() } catch {}
if (-not $Repo) { $Repo = (Resolve-Path -LiteralPath ".").Path }
$Repo = (Resolve-Path -LiteralPath $Repo).Path
Set-Location -LiteralPath $Repo

# MVP02 gate (minimal, parser-safe):
# Ziel: Preflight darf nicht am Parser scheitern.
# Inhaltlich konservativ: prüft Grundstruktur (Repo + seiten + includes) und meldet "minimal mode".

$Seiten   = Join-Path $Repo "seiten"
$Includes = Join-Path $Repo "_includes"
$Config   = Join-Path $Repo "_config.yml"

$Missing = @()
foreach ($PathItem in @($Seiten, $Includes, $Config)) {
  if (-not (Test-Path -LiteralPath $PathItem)) {
    $Missing += $PathItem
  }
}

if ($Missing.Count -gt 0) {
  "FAIL: MVP02 gate missing required repo structure:"
  $Missing
  Fail ("STOP: mvp02-gate fail (missing={0})" -f $Missing.Count)
}

$GitArgs = @(
  "-C"
  $Repo
  "ls-files"
  "--"
  "seiten/**/*.md"
  "seiten/**/*.html"
  "_includes/*"
)

$TrackedRelPaths = @(& git @GitArgs)
if ($LASTEXITCODE -ne 0) {
  Fail "STOP: mvp02-gate git ls-files failed."
}

$PageFiles = @()
$IncludeFiles = @()

foreach ($Rel in $TrackedRelPaths) {
  if ([string]::IsNullOrWhiteSpace($Rel)) { continue }

  $Full = Join-Path $Repo ($Rel -replace '/', '\')
  if (-not (Test-Path -LiteralPath $Full -PathType Leaf)) { continue }

  if ($Rel -like 'seiten/*') {
    $PageFiles += (Get-Item -LiteralPath $Full)
    continue
  }

  if ($Rel -like '_includes/*') {
    $IncludeFiles += (Get-Item -LiteralPath $Full)
    continue
  }
}

"PASS: mvp02-gate parser-safe (minimal mode). pages={0} includes={1}" -f @($PageFiles.Count, $IncludeFiles.Count)