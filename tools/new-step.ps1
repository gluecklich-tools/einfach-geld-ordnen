param(
  [Parameter(Mandatory=$true)][string]$NamePrefix
)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$repo = (& git rev-parse --show-toplevel 2>$null)
if (-not $repo) { throw "RepoRoot konnte nicht bestimmt werden." }
$repo = (Resolve-Path -LiteralPath $repo).Path
$tool = Join-Path $repo "tools\step-new.ps1"
& pwsh -NoProfile -ExecutionPolicy Bypass -File $tool -NamePrefix $NamePrefix
