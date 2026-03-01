param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 2 }

if(!(Test-Path -LiteralPath $RepoRoot)){ Fail "RepoRoot not found: $RepoRoot" }

$hits = New-Object System.Collections.Generic.List[object]

Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Force |
  Where-Object { $_.Extension -in @('.ps1','.psm1','.psd1','.yml','.yaml','.md','.txt') } |
  ForEach-Object {
    $p = $_.FullName
    try { $lines = [IO.File]::ReadAllLines($p, $enc) } catch { return }
    for($i=0; $i -lt $lines.Length; $i++){
      $ln = $lines[$i]
      if($ln -like "*pwsh*" -and $ln -like "*-Command '*"){
        $a = $ln.IndexOf("-Command '", [StringComparison]::Ordinal)
        if($a -ge 0){
          $rest = $ln.Substring($a + 9)
          if($rest.Contains("''")){
            $hits.Add([pscustomobject]@{ Path=$p; Line=($i+1); Text=$ln })
          }
        }
      }
    }
  }

if($hits.Count -gt 0){
  "FAIL: NO_INNER_SINGLE_QUOTES_IN_COMMAND"
  $hits | ForEach-Object { " - $($_.Path):$($_.Line) :: $($_.Text)" }
  exit 3
}

"PASS: NO_INNER_SINGLE_QUOTES_IN_COMMAND"
exit 0