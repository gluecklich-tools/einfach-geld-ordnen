param(
  [Parameter(Mandatory=$true)][string]$NamePrefix
)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$step = (& pwsh -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "step-new.ps1") -NamePrefix $NamePrefix).Trim()
code -g ("{0}:1" -f $step) | Out-Null