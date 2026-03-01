#requires -Version 7.0
param(
  [string]$BrainDir = $( if($env:EGO_BRAIN_DIR){ $env:EGO_BRAIN_DIR } else { "" } )
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)
function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }
# HARD FAIL only on explicit CANON list block (no false positives)
$BrainDir = if($BrainDir){ (Resolve-Path -LiteralPath $BrainDir).Path } else { throw "STOP: BrainDir missing (set EGO_BRAIN_DIR)" }
$learn = Join-Path $BrainDir "LEARNINGS_INTERNAL.md"
if(-not (Test-Path -LiteralPath $learn)){ throw "STOP: missing: $learn" }
# find canon block
$open  = "<!-- EGO_CANON:GATE_COVERAGE -->"
$close = "<!-- /EGO_CANON:GATE_COVERAGE -->"
$t = ReadUtf8 $learn
if($t -notmatch [regex]::Escape($open)){
  throw "STOP: missing CANON block in LEARNINGS_INTERNAL.md: GATE_COVERAGE (add it via step_add_gate_learning_coverage_*)"
}
$rx = "(?s)" + [regex]::Escape($open) + ".*?" + [regex]::Escape($close)
$m = [regex]::Match($t, $rx)
if(-not $m.Success){ throw "STOP: CANON block parse failed" }
$block = $m.Value
# Expected format per line:
# - ID: <ID> | Gate: tools\<gate-script>.ps1
$lines = $block.Split("`n") | ForEach-Object { $_.TrimEnd("`r").Trim() }
$repo = $null
try{ $repo = (git rev-parse --show-toplevel 2>$null).Trim() }catch{}
if(-not $repo){ $repo = (Resolve-Path -LiteralPath ".").Path }
$repo = (Resolve-Path -LiteralPath $repo).Path
$toolsDir = Join-Path $repo "tools"
$missing = New-Object System.Collections.Generic.List[string]
foreach($ln in $lines){
  if(-not $ln.StartsWith("- ")){ continue }
  $m2 = [regex]::Match($ln, "(?i)\bGate:\s*(tools\\[A-Za-z0-9_\-\.]+\.ps1)\b")
  if(-not $m2.Success){ continue } # allow notes without Gate ref
  $rel = $m2.Groups[1].Value
  $name = [IO.Path]::GetFileName($rel)
  $p = Join-Path $toolsDir $name
  if(-not (Test-Path -LiteralPath $p)){
    $missing.Add("$ln  ==> MISSING: $p") | Out-Null
  }
}
if($missing.Count -gt 0){
  "FAIL: GATE_LEARNING_COVERAGE"
  "Missing gate scripts referenced by CANON block:"
  $missing | ForEach-Object { " - " + $_ }
  exit 3
}
"OK: GATE_LEARNING_COVERAGE (canon-only) PASS"
exit 0