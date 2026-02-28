param([string]$RepoRoot=(Get-Location).Path)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001|Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }
function Fail([string]$m){ throw $m }

$repo=(Resolve-Path -LiteralPath $RepoRoot).Path
$dir = Join-Path $repo "tools"
if(!(Test-Path -LiteralPath $dir)){
  "PASS: NO_REGEX_PATH_FILTERS (no tools dir)"
  return
}

$files = Get-ChildItem -LiteralPath $dir -Filter "*.ps1" -File -ErrorAction SilentlyContinue
$hits = @()

foreach($f in $files){
  $lines = (ReadUtf8 $f.FullName) -split "`n"
  for($i=0; $i -lt $lines.Count; $i++){
    $line = ($lines[$i]).TrimEnd("`r")
    if($line -match '^\s*#'){ continue }

    # Only filesystem path properties are considered "path filters"
    if($line -match '(?i)\b(FullName|Path|DirectoryName)\b\s*-\s*(match|notmatch)\b'){
      $hits += ("{0}:L{1}: forbidden regex path filter: {2}" -f $f.FullName, ($i+1), $line.Trim())
    }
  }
}

if($hits.Count -gt 0){
  "FAIL: NO_REGEX_PATH_FILTERS"
  $hits | ForEach-Object { " - $_" }
  Fail "STOP: regex path filters found"
}

"PASS: NO_REGEX_PATH_FILTERS"
return