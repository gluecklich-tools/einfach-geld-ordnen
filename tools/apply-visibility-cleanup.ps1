param(
  [Parameter(Mandatory=$false)][string]$Root = (Get-Location).Path
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Write-Utf8NoBom([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}
function Remove-VisibilityBlock([string]$Text) {
  # Remove everything from <!-- VISIBILITY_START --> up to <!-- VISIBILITY_END --> (inclusive)
  $pattern = '(?s)\r?\n?<!--\s*VISIBILITY_START\s*-->\r?\n.*?\r?\n<!--\s*VISIBILITY_END\s*-->\r?\n?'
  return ([regex]::Replace($Text, $pattern, "`r`n"))
}
$targets = @()
$targets += Get-ChildItem -LiteralPath (Join-Path $Root 'seiten') -Filter '*.md' -File -Recurse -ErrorAction SilentlyContinue
$targets += Get-ChildItem -LiteralPath (Join-Path $Root 'pillar') -Filter '*.md' -File -Recurse -ErrorAction SilentlyContinue
$changed = @()
foreach ($f in $targets) {
  $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $new = Remove-VisibilityBlock $raw
  if ($new -ne $raw) {
    Write-Utf8NoBom -Path $f.FullName -Text $new
    $changed += $f.FullName
  }
}
"APPLY_VISIBILITY_CLEANUP_CHANGED=" + @($changed).Count
if (@($changed).Count -gt 0) {
  "CHANGED_FILES:"
  $changed | ForEach-Object { $_.Replace($Root + '\','') }
} else {
  "NO_CHANGES"
}