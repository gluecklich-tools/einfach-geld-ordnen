#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)]
  [string]$Pattern,

  [switch]$NoOpen
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
if(!(Test-Path -LiteralPath $Scratch)){ throw "Scratch dir missing: $Scratch" }

$step = Get-ChildItem -LiteralPath $Scratch -File -ErrorAction Stop |
  Where-Object Name -like $Pattern |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1 -ExpandProperty FullName

if([string]::IsNullOrWhiteSpace($step)){ throw "No step found for pattern '$Pattern' in $Scratch" }

if(-not $NoOpen){
  try { & code -g $step } catch {}
}

$step