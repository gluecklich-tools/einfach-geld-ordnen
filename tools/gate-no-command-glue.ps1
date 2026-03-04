param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$StepPath = ""
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001|Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }
function Fail([string]$m){ throw $m }

if([string]::IsNullOrWhiteSpace($StepPath)){
  "PASS: GATE_NO_COMMAND_GLUE (no StepPath)"
  return
}

$p = (Resolve-Path -LiteralPath $StepPath -ErrorAction Stop).Path
$lines = (ReadUtf8 $p) -split "
"
$hits = @()

for($i=0; $i -lt $lines.Count; $i++){
  $line = ($lines[$i]).TrimEnd("
")

  # command-glue examples we must block:
  # "REPORT: %USERPROFILE%\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen\_local\reports\p0_hard_gates_glue_regex_20260228_154250.md"pwsh -NoProfile ...
  # "OK";pwsh -NoProfile ...
  # ..."}git status...
  if($line -match '(?i)"\s*(pwsh|powershell|git|cmd|python|node)\b' -and $line -notmatch '^\s*#'){
    $hits += ("{0}:{1} :: {2}" -f @($p, ($i+1), $line.Trim()))
    continue
  }
  if($line -match '(?i)";\s*(pwsh|powershell|git|cmd|python|node)\b' -and $line -notmatch '^\s*#'){
    $hits += ("{0}:{1} :: {2}" -f @($p, ($i+1), $line.Trim()))
    continue
  }
}

if($hits.Count -gt 0){
  "FAIL: GATE_NO_COMMAND_GLUE"
  $hits | ForEach-Object { " - $_" }
  Fail "STOP: command glue detected in Step. Separate commands onto their own lines."
}

"PASS: GATE_NO_COMMAND_GLUE"
return
