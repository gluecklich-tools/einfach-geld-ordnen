#requires -Version 7.0
param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$StepPath = "",
  [string]$ScratchDir = (Join-Path (Resolve-Path -LiteralPath $RepoRoot).Path "_local\_scratch")
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }
function Fail([string]$m){ throw $m }

$targets = @()

if(-not [string]::IsNullOrWhiteSpace($StepPath)){
  $p = (Resolve-Path -LiteralPath $StepPath -ErrorAction Stop).Path
  $targets = @($p)
} else {
  if(Test-Path -LiteralPath $ScratchDir){
    $targets = Get-ChildItem -LiteralPath $ScratchDir -Filter "step_*.ps1" -File -ErrorAction SilentlyContinue |
      ForEach-Object { $_.FullName }
  }
}

if(@($targets).Count -eq 0){
  "PASS: GATE_NO_EXIT_IN_STEPS (no step targets)"
  exit 0
}

$hits = @()
foreach($file in $targets){
  $lines = (ReadUtf8 $file) -split "`n"
  for($i=0; $i -lt $lines.Count; $i++){
    $line = $lines[$i]
    if($line -match '(?i)^\s*exit(\s+[-]?\d+)?\s*$'){
      $hits += ("{0}:{1} :: {2}" -f $file, ($i+1), $line.Trim())
    }
  }
}

if(@($hits).Count -gt 0){
  "FAIL: GATE_NO_EXIT_IN_STEPS"
  $hits | ForEach-Object { " - $_" }
  Fail "STOP: Step contains 'exit'. Use 'throw' for fail, or just end script/return for success."
}

"PASS: GATE_NO_EXIT_IN_STEPS"
exit 0
