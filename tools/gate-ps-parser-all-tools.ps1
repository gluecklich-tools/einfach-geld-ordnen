param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 2 }
if(!(Test-Path -LiteralPath $RepoRoot)){ Fail "RepoRoot not found: $RepoRoot" }

$git = Get-Command git -ErrorAction SilentlyContinue
if($null -eq $git){ Fail "git not found (required for tracked-file scope)" }

$files = New-Object System.Collections.Generic.List[string]

Push-Location -LiteralPath $RepoRoot
try{
  $ls = & git ls-files "tools/*.ps1" 2>$null
  foreach($rel in $ls){
    if([string]::IsNullOrWhiteSpace($rel)){ continue }
    $full = Join-Path $RepoRoot $rel
    if(Test-Path -LiteralPath $full){ $files.Add($full) }
  }
} finally { Pop-Location }

$hits = New-Object System.Collections.Generic.List[object]

foreach($p in $files){
  $t=$null; $e=$null
  [void][System.Management.Automation.Language.Parser]::ParseFile($p,[ref]$t,[ref]$e)
  if($e.Count -gt 0){
    foreach($err in $e){
      $hits.Add([pscustomobject]@{
        Path = $p
        Line = $err.Extent.StartLineNumber
        Col  = $err.Extent.StartColumnNumber
        Msg  = $err.Message
      })
    }
  }
}

if($hits.Count -gt 0){
  "FAIL: GATE_PS_PARSER_ALL_TOOLS"
  $hits | ForEach-Object { " - $($_.Path):$($_.Line):$($_.Col) :: $($_.Msg)" }
  exit 3
}

"PASS: GATE_PS_PARSER_ALL_TOOLS"
exit 0
