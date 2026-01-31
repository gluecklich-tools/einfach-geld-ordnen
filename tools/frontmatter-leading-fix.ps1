param([switch]$Apply)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Get-Utf8TextNoBom {
  param([byte[]]$Bytes)
  if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) { $Bytes = $Bytes[3..($Bytes.Length-1)] }
  [System.Text.Encoding]::UTF8.GetString($Bytes)
}
function Write-Utf8NoBom {
  param([string]$Path, [string]$Text)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}
$root = Get-Location
$files = @()
$files += Get-ChildItem -LiteralPath (Join-Path $root "seiten") -Filter "*.md" -File -ErrorAction SilentlyContinue
$files += Get-ChildItem -LiteralPath (Join-Path $root "pillar") -Filter "*.md" -File -ErrorAction SilentlyContinue
$log = New-Object System.Collections.Generic.List[string]
$changed = 0
$written = 0
$checked = 0
foreach ($f in $files | Sort-Object FullName) {
  $checked++
  $txt = Get-Utf8TextNoBom -Bytes ([System.IO.File]::ReadAllBytes($f.FullName))
  if ($txt.StartsWith("---`n") -or $txt.StartsWith("---`r`n")) {
    continue
  }
  # if leading content is only whitespace/newlines before first frontmatter marker -> strip it
  $m = [regex]::Match($txt, '\A(?<lead>\s+)(?<rest>---(\r?\n).*)\z', [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($m.Success) {
    $changed++
    $log.Add("CHANGE: " + $f.FullName + " (strip leading whitespace before frontmatter)") | Out-Null
    if ($Apply) {
      Write-Utf8NoBom -Path $f.FullName -Text $m.Groups["rest"].Value
      $written++
    }
  } else {
    $log.Add("WARN: " + $f.FullName + " (frontmatter not at line 1, but not auto-fixable safely)") | Out-Null
  }
}
$report = Join-Path $root "tools/_frontmatter_leading_fix.txt"
Write-Utf8NoBom -Path $report -Text (
  "FRONTMATTER LEADING FIX - " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + "`n" +
  "Apply: " + $Apply.IsPresent + "`n" +
  "Checked: " + $checked + "`n" +
  "Changed: " + $changed + "`n" +
  "Written: " + $written + "`n`n" +
  ($log -join "`n")
)
"OK: wrote tools/_frontmatter_leading_fix.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }