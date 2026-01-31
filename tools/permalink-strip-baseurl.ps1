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
function Split-Frontmatter {
  param([string]$Text)
  $t = $Text -replace "`r`n","`n" -replace "`r","`n"
  $m = [regex]::Match($t, '\A---\s*\n(?<fm>.*?\n)---\s*\n(?<body>.*)\z', [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { return $null }
  [pscustomobject]@{ Frontmatter="---`n" + $m.Groups["fm"].Value + "---`n"; Body=$m.Groups["body"].Value }
}
$root = Get-Location
$files = @()
$files += Get-ChildItem -LiteralPath (Join-Path $root "seiten") -Filter "*.md" -File -ErrorAction SilentlyContinue
$files += Get-ChildItem -LiteralPath (Join-Path $root "pillar") -Filter "*.md" -File -ErrorAction SilentlyContinue
$log = New-Object System.Collections.Generic.List[string]
$changed = 0
$written = 0
foreach ($f in $files | Sort-Object FullName) {
  $txt = Get-Utf8TextNoBom -Bytes ([System.IO.File]::ReadAllBytes($f.FullName))
  $fm = Split-Frontmatter -Text $txt
  if ($null -eq $fm) { continue }
  $front = $fm.Frontmatter
  $newFront = $front
  # strip liquid baseurl from permalink lines (allow whitespace/newlines inside)
  $newFront = [regex]::Replace(
    $newFront,
    '(?im)^(?<pre>\s*permalink:\s*)(?<q>["'']?)(?<p>\s*\{\{\s*site\.baseurl\s*\}\}\s*(?<rest>/[^"''\s]+)\s*)(?<q2>["'']?)\s*$',
    '${pre}${q2}${rest}${q2}'
  )
  if ($newFront -ne $front) {
    $changed++
    $log.Add("CHANGE: " + $f.FullName) | Out-Null
    if ($Apply) {
      $newText = $newFront + $fm.Body
      Write-Utf8NoBom -Path $f.FullName -Text $newText
      $written++
    }
  }
}
$report = Join-Path $root "tools/_permalink_strip_baseurl.txt"
Write-Utf8NoBom -Path $report -Text (
  "PERMALINK STRIP BASEURL - " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + "`n" +
  "Apply: " + $Apply.IsPresent + "`n" +
  "Changed: " + $changed + "`n" +
  "Written: " + $written + "`n"
)
"OK: wrote tools/_permalink_strip_baseurl.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }