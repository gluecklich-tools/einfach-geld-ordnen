#requires -Version 7.0
param(
  [Parameter(Mandatory)][string]$RepoRoot
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$toolsDir = Join-Path $RepoRoot "tools"

# Conservative: flag explicit relative ".\" / "..\" in obvious IO calls inside tools/
$bad = @()
$patterns = @(
  'ReadAllBytes\(\s*"\.\[\\\/]',
  'WriteAllBytes\(\s*"\.\[\\\/]',
  'Get-Content\s+.*-LiteralPath\s+"\.\[\\\/]',
  'Set-Content\s+.*-LiteralPath\s+"\.\[\\\/]',
  'Copy-Item\s+.*-LiteralPath\s+"\.\[\\\/]'
)

$files = Get-ChildItem -LiteralPath $toolsDir -Recurse -File -Filter "*.ps1"
foreach($f in $files){
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  foreach($p in $patterns){
    if([regex]::IsMatch($raw, $p)){
      $bad += ("{0} :: RELATIVE_IO_PATTERN={1}" -f @($f.FullName, $p))
    }
  }
}

if($bad.Count -gt 0){
  "FAIL: NO_RELATIVE_FILE_IO_IN_TOOLS"
  $bad | ForEach-Object { " - $_" }
  exit 3
}

"PASS: NO_RELATIVE_FILE_IO_IN_TOOLS"
exit 0
