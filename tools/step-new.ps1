#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)]
  [string]$NamePrefix
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { chcp 65001 > $null } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if([string]::IsNullOrWhiteSpace($RepoRoot)){ throw "RepoRoot not found." }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

$Scratch = Join-Path $RepoRoot "_local/_scratch"
New-Item -ItemType Directory -Force -Path $Scratch | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$fn = ("{0}_{1}.ps1" -f @($NamePrefix, $ts))
$path = Join-Path $Scratch $fn

New-Item -ItemType File -Force -Path $path | Out-Null
try { & code -g $path } catch {}

$path
