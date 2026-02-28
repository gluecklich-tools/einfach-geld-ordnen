param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){
  Write-Error $m
  exit 1
}

Set-Location -LiteralPath $RepoRoot

$ps1 = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter *.ps1 |
  Where-Object {
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\node_modules\\' -and
    $_.FullName -notmatch '\\_local\\' -and
    $_.FullName -notmatch '\\_INTERN\\'
  }

$bad = New-Object System.Collections.Generic.List[string]

foreach($f in $ps1){
  $lines = @(Get-Content -LiteralPath $f.FullName -Encoding UTF8)
  for($i=0; $i -lt @($lines).Count; $i++){
    if($lines[$i] -match '^\s*@"\s*$'){
      $start = [Math]::Max(0, $i-3)
      $ctx = ($lines[$start..$i] -join "`n")
      if($ctx -notmatch 'EGO_ALLOW_HEREDOC_INTERPOLATION'){
        $bad.Add(("{0}:{1}: unsafe double-quoted heredoc AT-QUOTE without allow-marker" -f $f.FullName, ($i+1)))
      }
    }
  }
}

if($bad.Count -gt 0){
  "UNSAFE_HEREDOC_FOUND:"
  $bad | ForEach-Object { $_ }
  Fail "STOP: unsafe double-quoted heredoc detected. Use @' '@ or add # EGO_ALLOW_HEREDOC_INTERPOLATION"
}

"OK: gate-no-unsafe-heredoc PASS"
exit 0
