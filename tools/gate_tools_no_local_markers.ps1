param()
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
# NOTE:
# This gate forbids only REAL leaks in public tools scripts:
# - hardcoded user paths (C:\Users\...)
# - SSOT/internal markers (_INTERN\...)
# It intentionally does NOT forbid "_local/..." search strings because gates may scan for them.
$patterns = @(
  '_INTERN\',
  '\_INTERN\',
  'C:\Users\',
  'C:\Users\\'
)
$toolDir = Join-Path (Resolve-Path -LiteralPath $PSScriptRoot).Path '.'
$self = $MyInvocation.MyCommand.Path
$toolFiles = Get-ChildItem -LiteralPath $toolDir -File -Filter '*.ps1' -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -ne $self }
$hits = @()
foreach ($f in $toolFiles) {
  foreach ($p in $patterns) {
    $m = Select-String -LiteralPath $f.FullName -SimpleMatch -Pattern $p -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($m) {
      foreach ($x in $m) {
        $hits += [pscustomobject]@{
          File    = $f.FullName
          Line    = $x.LineNumber
          Pattern = $p
          Text    = $x.Line.Trim()
        }
      }
    }
  }
}
if ($hits.Count -gt 0) {
  "FAIL: tools/*.ps1 contains forbidden hardpaths/SSOT markers:"
  $hits | Sort-Object File,Line,Pattern |
    Select-Object -First 200 |
    Format-List | Out-String | Write-Host
  throw "Forbidden hardpaths/SSOT markers detected in tools scripts. Fix tools/*.ps1 first."
}
"PASS: tools/*.ps1 contains no forbidden hardpaths/SSOT markers."