param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Needle = "_local/patch_backups/"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$GitArgs = @(
  "-C"
  $RepoRoot
  "ls-files"
  "--"
  "*.md"
  "*.html"
  "*.yml"
  "*.js"
  "*.css"
)

$TrackedRelPaths = @(& git @GitArgs)
if ($LASTEXITCODE -ne 0) {
  throw "git ls-files failed."
}

$Targets = @(
  foreach ($Rel in $TrackedRelPaths) {
    if ([string]::IsNullOrWhiteSpace($Rel)) { continue }

    $Full = Join-Path $RepoRoot ($Rel -replace '/', '\')
    if (Test-Path -LiteralPath $Full -PathType Leaf) {
      Get-Item -LiteralPath $Full
    }
  }
)

$Hits = @()
foreach ($File in $Targets) {
  $Matches = Select-String -LiteralPath $File.FullName -SimpleMatch -Pattern $Needle -Encoding UTF8 -ErrorAction SilentlyContinue
  if ($Matches) {
    foreach ($Match in $Matches) {
      $Hits += [pscustomobject]@{
        File = $File.FullName
        Line = $Match.LineNumber
        Text = $Match.Line.Trim()
      }
    }
  }
}

if ($Hits.Count -gt 0) {
  Write-Host "FAIL: Found forbidden local-backup links in tracked repo content:"
  $Hits | Select-Object -First 200 | Format-Table -AutoSize | Out-String | Write-Host
  throw "Forbidden local backup links detected (_local/patch_backups)."
}

Write-Host "PASS: No _local/patch_backups links in tracked repo content."