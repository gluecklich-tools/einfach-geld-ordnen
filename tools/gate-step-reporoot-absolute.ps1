#requires -Version 7.0
param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$ScratchDir = $(Join-Path (Resolve-Path -LiteralPath $RepoRoot).Path "_local\_scratch")
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }

$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$ScratchDir = (Resolve-Path -LiteralPath $ScratchDir).Path
if(-not (Test-Path -LiteralPath $ScratchDir)){ throw "STOP: scratch missing: $ScratchDir" }

$files = @(Get-ChildItem -LiteralPath $ScratchDir -File -Filter "step_*.ps1" -ErrorAction Stop | Sort-Object Name)
if($files.Count -eq 0){ "OK: GATE_STEP_REPOROOT_ABSOLUTE (no step files)"; exit 0 }

$bad = New-Object System.Collections.Generic.List[string]
foreach($f in $files){
  $t = ReadUtf8 $f.FullName
  if($t -notmatch "_local\\_scratch"){ continue }

  if(-not (($t -match 'Join-Path') -and ($t -match "\$RepoRoot"))){
    $bad.Add(("Step may fallthrough to HOME (missing Join-Path/RepoRoot) in {0}" -f $f.Name))|Out-Null
  }
  if($t -match "(?i)C:\\Users\\"){
    $bad.Add(("Hard-coded user path in step {0}" -f $f.Name))|Out-Null
  }
}

if($bad.Count -gt 0){ "FAIL: GATE_STEP_REPOROOT_ABSOLUTE"; $bad|%{ " - " + $_ }; exit 3 }
"OK: GATE_STEP_REPOROOT_ABSOLUTE PASS"; exit 0