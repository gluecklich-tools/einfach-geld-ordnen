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

function Is-ExcludedPath([string]$rel){
  $r = ($rel -replace '\\','/').TrimStart('/')
  if($r.StartsWith('.git/')){ return $true }
  if($r.StartsWith('_local/')){ return $true }
  if($r.StartsWith('_site/')){ return $true }
  if($r.StartsWith('vendor/')){ return $true }
  if($r.StartsWith('node_modules/')){ return $true }
  return $false
}

function Is-ValidPlaceholderChar([char]$c){
  return ([char]::IsDigit($c) -or $c -eq ':' -or $c -eq ',' -or $c -eq '-' -or $c -eq ' ')
}

function Has-FormatBraceTrap([string]$s){
  if([string]::IsNullOrEmpty($s)){ return $false }

  for($i=0; $i -lt $s.Length; $i++){
    $ch = $s[$i]

    if($ch -eq '{'){
      if($i+1 -lt $s.Length -and $s[$i+1] -eq '{'){ $i++; continue }
      if($i+1 -ge $s.Length){ return $true }
      $n = $s[$i+1]
      if(-not [char]::IsDigit($n)){ return $true }

      $j = $i+2
      for(; $j -lt $s.Length; $j++){
        $c = $s[$j]
        if($c -eq '}'){ break }
        if(-not (Is-ValidPlaceholderChar $c)){ return $true }
      }
      if($j -ge $s.Length){ return $true }
      $i = $j
      continue
    }

    if($ch -eq '}'){
      if($i+1 -lt $s.Length -and $s[$i+1] -eq '}'){ $i++; continue }
      return $true
    }
  }

  return $false
}

$files = New-Object System.Collections.Generic.List[string]
$git = Get-Command git -ErrorAction SilentlyContinue

if($null -ne $git){
  Push-Location -LiteralPath $RepoRoot
  try{
    $ls = & git ls-files 2>$null
    foreach($rel in $ls){
      if([string]::IsNullOrWhiteSpace($rel)){ continue }
      if(Is-ExcludedPath $rel){ continue }
      if([IO.Path]::GetExtension($rel).ToLowerInvariant() -ne '.ps1'){ continue }
      $full = Join-Path $RepoRoot $rel
      if(Test-Path -LiteralPath $full){ $files.Add($full) }
    }
  } finally { Pop-Location }
} else {
  Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'tools') -Recurse -File -Force -Filter *.ps1 |
    ForEach-Object { $files.Add($_.FullName) }
}

$hits = New-Object System.Collections.Generic.List[object]

foreach($p in $files){
  $tokens=$null; $errors=$null
  $ast=$null
  try{ $ast = [System.Management.Automation.Language.Parser]::ParseFile($p,[ref]$tokens,[ref]$errors) }catch{ continue }
  if($errors.Count -gt 0){ continue }

  $bins = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.BinaryExpressionAst] -and $n.Operator -eq 'Format' }, $true)
  foreach($b in $bins){
    $left = $b.Left
    $s = $null
    if($left -is [System.Management.Automation.Language.StringConstantExpressionAst]){ $s = $left.Value }
    elseif($left -is [System.Management.Automation.Language.ExpandableStringExpressionAst]){ $s = $left.Value }
    else { continue }

    if(Has-FormatBraceTrap $s){
      $hits.Add([pscustomobject]@{
        Path = $p
        Line = $b.Extent.StartLineNumber
        Text = $b.Extent.Text
      })
    }
  }
}

if($hits.Count -gt 0){
  "FAIL: NO_FORMAT_BRACE_TRAPS"
  $hits | ForEach-Object { " - $($_.Path):$($_.Line) :: $($_.Text)" }
  exit 3
}

"PASS: NO_FORMAT_BRACE_TRAPS"
exit 0
