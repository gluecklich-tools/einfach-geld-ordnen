#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ConfirmPreference="None"
$ProgressPreference="SilentlyContinue"

function Write-Utf8NoBomLF {
  param([Parameter(Mandatory)][string]$Path,[Parameter(Mandatory)][string]$Text)
  # Normalize line endings WITHOUT regex
  $Text = $Text.Replace("`r`n","`n").Replace("`r","`n")
  [System.IO.File]::WriteAllText($Path,$Text,[System.Text.UTF8Encoding]::new($false))
}

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$InternalTools = Join-Path $ProjectRoot "_INTERN\tools"
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

if(!(Test-Path -LiteralPath $InternalTools -PathType Container)){
  throw "Missing INTERN tools: $InternalTools"
}
if(!(Test-Path -LiteralPath $BrainDir -PathType Container)){
  throw "Missing Brain dir: $BrainDir"
}

$ssot = Join-Path $InternalTools "ssot-refresh-proxy.ps1"
if(!(Test-Path -LiteralPath $ssot -PathType Leaf)){
  throw "Missing ssot-refresh-proxy: $ssot"
}

Write-Host "== ROUND CLOSEOUT ==" -ForegroundColor Cyan
& pwsh -NoProfile -ExecutionPolicy Bypass -File $ssot

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
$nowUtc = [DateTimeOffset]::UtcNow.ToString("o")
Write-Utf8NoBomLF -Path $marker -Text ($nowUtc + "`n")

Write-Host ("WROTE: " + $marker + " = " + $nowUtc) -ForegroundColor Green
"PASS: round-closeout"