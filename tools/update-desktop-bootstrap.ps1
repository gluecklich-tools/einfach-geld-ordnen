Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$src = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance\BOOTSTRAP_INTERNAL.md"
$dst = Join-Path $env:USERPROFILE "Desktop\EGO_BOOTSTRAP_INTERNAL.md"
if (-not (Test-Path -LiteralPath $src)) { throw "Missing source: $src" }
Copy-Item -LiteralPath $src -Destination $dst -Force
Get-Item -LiteralPath $dst | Select-Object FullName,Length,LastWriteTime