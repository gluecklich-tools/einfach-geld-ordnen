param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$git = Get-Command git -ErrorAction SilentlyContinue
if($null -eq $git){ Fail "FAIL: JOINPATH_ARGCOUNT requires git" }

Push-Location -LiteralPath $RepoRoot
try{
  $rels = & git ls-files "tools/*.ps1" 2>$null
} finally { Pop-Location }

$hits = New-Object System.Collections.Generic.List[object]

foreach($rel in $rels){
  if([string]::IsNullOrWhiteSpace($rel)){ continue }
  $p = Join-Path $RepoRoot $rel
  if(!(Test-Path -LiteralPath $p)){ continue }

  $tokens=$null; $errors=$null
  $ast=$null
  try{ $ast = [System.Management.Automation.Language.Parser]::ParseFile($p,[ref]$tokens,[ref]$errors) }catch{ continue }
  if($errors.Count -gt 0){ continue }

  $cmds = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true)
  foreach($c in $cmds){
    if($c.CommandElements.Count -lt 1){ continue }
    $name = $c.CommandElements[0].Extent.Text
    if($name -ne "Join-Path"){ continue }

    # CommandElements: [0]=Join-Path, danach Parameter/Args.
    # Wir wollen mindestens 2 args (Path + ChildPath), also insgesamt >=3 Elemente ODER splatting.
    $hasSplat = $false
    foreach($ce in $c.CommandElements){
      if($ce -is [System.Management.Automation.Language.VariableExpressionAst] -and $ce.Splatted){ $hasSplat=$true; break }
    }
    if($hasSplat){ continue }

    # Grobregel: wenn weniger als 3 Elemente -> sehr wahrscheinlich "Join-Path $x" ohne ChildPath
    if($c.CommandElements.Count -lt 3){
      $hits.Add([pscustomobject]@{
        Path = $p
        Line = $c.Extent.StartLineNumber
        Text = $c.Extent.Text
      })
    }
  }
}

if($hits.Count -gt 0){
  "FAIL: JOINPATH_ARGCOUNT (Join-Path without ChildPath)"
  $hits | ForEach-Object { " - $($_.Path):$($_.Line) :: $($_.Text)" }
  exit 3
}

"PASS: JOINPATH_ARGCOUNT"
exit 0
