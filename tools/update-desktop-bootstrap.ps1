Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$internalRoot = $env:EGO_INTERNAL_DIR
if (-not $internalRoot) { throw "EGO_INTERNAL_DIR not set. Set it to your internal root folder (contains governance\BOOTSTRAP_INTERNAL.md)." }
$src = Join-Path $internalRoot ('governance' + [char]92 + 'BOOTSTRAP_INTERNAL.md')
$dst = Join-Path $env:USERPROFILE "Desktop\EGO_BOOTSTRAP_INTERNAL.md"
if (-not (Test-Path -LiteralPath $src)) { throw "Missing source: $src" }
Copy-Item -LiteralPath $src -Destination $dst -Force
Get-Item -LiteralPath $dst | Select-Object FullName,Length,LastWriteTime