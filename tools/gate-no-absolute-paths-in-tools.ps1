param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }
$git = Get-Command git -ErrorAction SilentlyContinue
if($null -eq $git){ Fail "FAIL: NO_ABSOLUTE_PATHS requires git" }

Push-Location -LiteralPath $RepoRoot
try{
  $files = & git ls-files "tools/*.ps1" 2>$null
} finally { Pop-Location }

$hits = New-Object System.Collections.Generic.List[object]

foreach($rel in $files){
  if([string]::IsNullOrWhiteSpace($rel)){ continue }
  $p = Join-Path $RepoRoot $rel
  if(!(Test-Path -LiteralPath $p)){ continue }

  $lines = $null
  try{ $lines = [IO.File]::ReadAllLines($p,$enc) }catch{ continue }

  for($i=0; $i -lt $lines.Length; $i++){
    $ln = $lines[$i]
    if($null -eq $ln){ continue }

    # hard blocks (local-only paths)
    if($ln -like "*C:\Users\*" -or
       $ln -like "*\_INTERN\*" -or
       $ln -like "*/home/runner/*"){
      $hits.Add([pscustomobject]@{ Path=$p; Line=($i+1); Text=$ln })
    }
  }
}

if($hits.Count -gt 0){
  "FAIL: NO_ABSOLUTE_PATHS_IN_TOOLS"
  $hits | ForEach-Object { " - $($_.Path):$($_.Line) :: $($_.Text)" }
  exit 3
}

"PASS: NO_ABSOLUTE_PATHS_IN_TOOLS"
exit 0