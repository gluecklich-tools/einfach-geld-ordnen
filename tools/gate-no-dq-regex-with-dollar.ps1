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

$repo = (Resolve-Path -LiteralPath $RepoRoot).Path
$targets = New-Object System.Collections.Generic.List[string]

# tools/*.ps1 always
Get-ChildItem -LiteralPath (Join-Path $repo "tools") -Filter "*.ps1" -File -ErrorAction SilentlyContinue |
  ForEach-Object { $targets.Add($_.FullName) }

# plus current StepPath if set
if(-not [string]::IsNullOrWhiteSpace($StepPath)){
  $targets.Add((Resolve-Path -LiteralPath $StepPath -ErrorAction Stop).Path)
}

$hits=@()

foreach($file in $targets){
  $lines = (ReadUtf8 $file) -split "
"
  for($i=0; $i -lt $lines.Count; $i++){
    $line = ($lines[$i]).TrimEnd("
")

    # Block double-quoted regex patterns that contain '$' (StrictMode killer)
    # 1) -match "....$...."
    if($line -match '(?i)\-match\s+"[^"]*\$[^"]*"' -and $line -notmatch '^\s*#'){
      $hits += ("{0}:{1} :: {2}" -f @($file, ($i+1), $line.Trim()))
      continue
    }

    # 2) [Regex]::Match/Replace(..., "....$....")
    if($line -match '(?i)\[Regex\]::(Match|Replace)\s*\([^,]+,\s*"[^"]*\$[^"]*"' -and $line -notmatch '^\s*#'){
      $hits += ("{0}:{1} :: {2}" -f @($file, ($i+1), $line.Trim()))
      continue
    }
  }
}

if($hits.Count -gt 0){
  "FAIL: GATE_NO_DQ_REGEX_WITH_DOLLAR"
  $hits | ForEach-Object { " - $_" }
  Fail "STOP: double-quoted regex pattern contains '$'. Use single quotes for regex patterns, or build pattern safely."
}

"PASS: GATE_NO_DQ_REGEX_WITH_DOLLAR"
return
