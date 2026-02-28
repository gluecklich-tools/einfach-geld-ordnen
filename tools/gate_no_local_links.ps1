param()
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$needle = "_local/patch_backups/"
$targets = Get-ChildItem -Recurse -File -Include *.md,*.html,*.yml,*.js,*.css |
  Where-Object {
    $_.FullName -notmatch "\\_site\\" -and
    $_.FullName -notmatch '*\.git\*' -and
(($_.FullName -replace '\','/') -notlike '*/node_modules/*') -and
(($_.FullName -replace '\','/') -notlike '*/_local/*')
  }
$hits = @()
foreach ($f in $targets) {
  $m = Select-String -LiteralPath $f.FullName -SimpleMatch -Pattern $needle -Encoding UTF8 -ErrorAction SilentlyContinue
  if ($m) {
    foreach ($x in $m) {
      $hits += [pscustomobject]@{ File=$f.FullName; Line=$x.LineNumber; Text=$x.Line.Trim() }
    }
  }
}
if ($hits.Count -gt 0) {
  "FAIL: Found forbidden local-backup links in repo content:"
  $hits | Select-Object -First 200 | Format-Table -AutoSize | Out-String | Write-Host
  throw "Forbidden local backup links detected (_local/patch_backups)."
}
"PASS: No _local/patch_backups links in repo content."