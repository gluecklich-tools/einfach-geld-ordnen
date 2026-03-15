#requires -Version 7.0
param(
  [Parameter(Mandatory=$false)][string]$SsotRoot,
  [Parameter(Mandatory=$false)][string]$FindingsPath,
  [Parameter(Mandatory=$false)][string]$OutPath
)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try{ if($IsWindows){ chcp 65001 > $null } }catch{}
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
# Stub behavior:
# - contract-safe (accepts SsotRoot)
# - no mutation yet
$didWork = $false
$count = 0
if($FindingsPath -and (Test-Path -LiteralPath $FindingsPath)){
  $didWork = $true
  $lines = Get-Content -LiteralPath $FindingsPath -ErrorAction Stop
  $count = @($lines).Count
}
[pscustomobject]@{
  Ok = $true
  Tool = "ego-findings-upsert"
  SsotRoot = $SsotRoot
  DidWork = $didWork
  FindingsPath = $FindingsPath
  Count = $count
  OutPath = $OutPath
}
