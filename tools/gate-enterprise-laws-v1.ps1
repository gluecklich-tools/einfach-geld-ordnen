#requires -Version 7.0
[CmdletBinding()]
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try{ if($IsWindows){ chcp 65001 > $null } }catch{}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# Wrapper kept for backward compatibility. v2 is canonical.
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$v2 = Join-Path $here "gate-enterprise-laws-v2.ps1"

if(-not (Test-Path -LiteralPath $v2 -PathType Leaf)){
  throw "gate-enterprise-laws-v2.ps1 not found next to v1 wrapper: $v2"
}

& $v2