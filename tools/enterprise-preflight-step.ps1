[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string]$StepPath
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$utf8=[Text.UTF8Encoding]::new($false)
if(!(Test-Path -LiteralPath $StepPath)){ throw "STOP: missing StepPath: $StepPath" }
$txt = [IO.File]::ReadAllText($StepPath,$utf8)
# --- P0: NO_PLACEHOLDERS / NO_TODO_FILL ---
$badMarkers = @(
  '<fullpath'
  '<path'
  'TODO:'
  'FILL_ME'
  'INSERT_HERE'
  'kommt hier rein'
  'hier einfügen'
  'nimm ihn 1:1'
  'copy/paste'
)
foreach($m in @($badMarkers)){
  if($txt -match [regex]::Escape($m)){
    throw "STOP: LINT_FAIL PROACTIVE_NO_PLACEHOLDERS marker='$m' in Step: $StepPath"
  }
}
# --- P0: NO_MARKDOWN_FENCES ---
if($txt -match '```'){
  throw "STOP: LINT_FAIL NO_MARKDOWN_FENCES in Step: $StepPath"
}
# --- P0: NO_INTERACTIVE (hard ban) ---
$interactivePatterns = @(
  '\bRead-Host\b'
  '\bPromptForChoice\b'
  '\bOut-GridView\b'
  '\bPause\b'
  'Supply values for the following parameters'
)
foreach($rx in @($interactivePatterns)){
  if($txt -match $rx){
    throw "STOP: LINT_FAIL NO_INTERACTIVE_PROMPTS pattern='$rx' in Step: $StepPath"
  }
}
# --- P1: warn-level (still STOP for now; you can relax later) ---
# Mandatory param attributes in steps are okay, but often cause prompts if caller forgets args.
# We force a STOP if step text contains Parameter(Mandatory) in scripts that then call external tools without args.
if($txt -match '\[Parameter\s*\(\s*Mandatory\s*\)'){
  # Not always wrong, but in practice it causes prompt cascades. Keep as STOP until you explicitly allow.
  throw "STOP: LINT_FAIL PROACTIVE_NO_MANDATORY_PARAMS_IN_STEPS (avoid prompt risk) in Step: $StepPath"
}
"PRECHECK_OK: $StepPath"