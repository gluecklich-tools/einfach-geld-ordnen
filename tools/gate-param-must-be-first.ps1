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

function Strip-AllowedPreamble([string]$s){
  if([string]::IsNullOrEmpty($s)){ return "" }

  # remove BOM if present
  if($s.Length -gt 0 -and [int]$s[0] -eq 0xFEFF){ $s = $s.Substring(1) }

  # remove block comments <# #>
  while($true){
    $a = $s.IndexOf("<#", [StringComparison]::Ordinal)
    if($a -lt 0){ break }
    $b = $s.IndexOf("#>", $a + 2, [StringComparison]::Ordinal)
    if($b -lt 0){ break }
    $s = $s.Remove($a, ($b + 2) - $a)
  }

  # remove full-line # comments
  $lines = $s -split "
?
"
  $kept = New-Object System.Collections.Generic.List[string]
  foreach($ln in $lines){
    $t = $ln.Trim()
    if($t.StartsWith("#")){ continue }
    $kept.Add($ln)
  }
  $s = ($kept -join "
")

  # remove leading whitespace
  $s = $s.TrimStart()

  # remove leading using statements (multiple)
  while($true){
    $trim = $s.TrimStart()
    if($trim.Length -eq 0){ return "" }
    if(-not $trim.StartsWith("using ", [StringComparison]::OrdinalIgnoreCase)){ break }

    $nl = $trim.IndexOf("
", [StringComparison]::Ordinal)
    if($nl -lt 0){ return "" }
    $s = $trim.Substring($nl + 1)
  }

  # remove leading attribute blocks: [ ... ] (balanced brackets), repeated
  while($true){
    $s = $s.TrimStart()
    if($s.Length -eq 0){ return "" }
    if($s[0] -ne '['){ break }

    $depth = 0
    $i = 0
    for(; $i -lt $s.Length; $i++){
      $ch = $s[$i]
      if($ch -eq '['){ $depth++ }
      elseif($ch -eq ']'){
        $depth--
        if($depth -eq 0){
          # consume trailing whitespace/newlines after attribute
          $i++
          while($i -lt $s.Length){
            $c2 = $s[$i]
            if([char]::IsWhiteSpace($c2)){ $i++ } else { break }
          }
          $s = $s.Substring($i)
          break
        }
      }
    }
    if($depth -ne 0){ break } # malformed; stop stripping
    continue
  }

  return $s.TrimStart()
}

$hits = New-Object System.Collections.Generic.List[object]

Get-ChildItem -LiteralPath (Join-Path $RepoRoot "tools") -File -Force -Filter *.ps1 |
  ForEach-Object {
    $p = $_.FullName

    $tokens = $null
    $errors = $null
    $ast = $null
    try{
      $ast = [System.Management.Automation.Language.Parser]::ParseFile($p, [ref]$tokens, [ref]$errors)
    }catch{ return }
    if($errors.Count -gt 0){ return }

    if($null -eq $ast.ParamBlock){ return } # only script-level paramblock

    # check preamble text before paramblock
    $txt = $null
    try{ $txt = [IO.File]::ReadAllText($p, $enc) }catch{ return }
    if([string]::IsNullOrEmpty($txt)){ return }

    $pbStart = $ast.ParamBlock.Extent.StartOffset
    if($pbStart -lt 0 -or $pbStart -gt $txt.Length){ return }

    $pre = $txt.Substring(0, $pbStart)
    $rest = Strip-AllowedPreamble $pre

    if($rest.Length -gt 0){
      # first offending non-empty fragment -> best-effort line number
      $line = 1
      try{
        $line = ($pre -split "
?
").Length
      }catch{}
      $snippet = $rest
      if($snippet.Length -gt 80){ $snippet = $snippet.Substring(0,80) }
      $hits.Add([pscustomobject]@{ Path=$p; Line=$line; Text=$snippet })
    }
  }

if($hits.Count -gt 0){
  "FAIL: PARAM_MUST_BE_FIRST"
  $hits | ForEach-Object { " - $($_.Path):$($_.Line) :: $($_.Text)" }
  exit 3
}

"PASS: PARAM_MUST_BE_FIRST"
exit 0
