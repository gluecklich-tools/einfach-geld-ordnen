param(
  [string]$EnterpriseRun = 'C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools\enterprise-run.ps1'
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

if(!(Test-Path -LiteralPath $EnterpriseRun)){
  throw "STOP: missing enterprise-run: $EnterpriseRun"
}

& pwsh -NoProfile -File $EnterpriseRun
