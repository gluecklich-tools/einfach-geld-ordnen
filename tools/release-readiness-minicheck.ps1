param([switch]$LinkScan)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Host ("[FAIL] {0}" -f $m); exit 1 }

# 1) Git clean?
$dirty = git status --porcelain=v1
if(@($dirty).Count -ne 0){
  Write-Host '[WARN] Repo is DIRTY:'
  $dirty | ForEach-Object { Write-Host ('  ' + $_) }
  Fail 'Working tree not clean'
}
Write-Host '[OK] Git clean'

# 2) Preflight (intern)
$preflight = 'C:\Users\USER\USER\USER\Projekte\Einfach-Geld-Ordnen\_INTERN\tools\ego-preflight-gates-run.ps1'
if(!(Test-Path -LiteralPath $preflight)){ Fail ("Missing preflight: $preflight") }
& pwsh -NoProfile -File $preflight
if($LASTEXITCODE -ne 0){ Fail ("Preflight failed (exit=$LASTEXITCODE)") }
Write-Host '[OK] Preflight PASS'

# 3) Optional: Link-Scan (repo tool)
if($LinkScan){
  $ls = Join-Path (Get-Location).Path 'tools\link-scan.ps1'
  if(!(Test-Path -LiteralPath $ls)){ Fail ("Missing link-scan tool: $ls") }
  & pwsh -NoProfile -File $ls
  if($LASTEXITCODE -ne 0){ Fail ("Link-Scan failed (exit=$LASTEXITCODE)") }
  Write-Host '[OK] Link-Scan PASS'
}

Write-Host '[OK] Release-Readiness MINICHECK PASS'
exit 0