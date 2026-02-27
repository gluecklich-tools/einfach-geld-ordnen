param(
  [string]$InternalToolsRoot = 'C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\tools',
  [switch]$FailIfMissing
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

if(!(Test-Path -LiteralPath $InternalToolsRoot)){
  if($FailIfMissing){ throw "STOP: internal tools missing: $InternalToolsRoot" }
  "SSOT_REFRESH: SKIP (internal tools root missing): $InternalToolsRoot"
  exit 0
}

$cands = @()
$cands += @(Get-ChildItem -LiteralPath $InternalToolsRoot -File -Filter '*ssot*refresh*proxy*.ps1' -ErrorAction SilentlyContinue)
$cands += @(Get-ChildItem -LiteralPath $InternalToolsRoot -File -Filter 'ssot-refresh*.ps1'       -ErrorAction SilentlyContinue)
$cands = @($cands | Sort-Object FullName -Unique)

if(@($cands).Count -eq 0){
  if($FailIfMissing){ throw "STOP: ssot refresh tool not found in: $InternalToolsRoot" }
  "SSOT_REFRESH: SKIP (no tool matched '*ssot*refresh*proxy*.ps1' or 'ssot-refresh*.ps1' in $InternalToolsRoot)"
  exit 0
}

$tool = ($cands | Where-Object { $_.Name -like '*proxy*' } | Select-Object -First 1)
if($null -eq $tool){ $tool = $cands[0] }

"SSOT_REFRESH: RUN $($tool.FullName)"

# capture output so we can detect embedded brain drop sync
$out = @(& pwsh -NoProfile -File $tool.FullName 2>&1)
foreach($ln in @($out)){ "$ln" }

# marker if refresh already did brain drop sync
$joined = ($out -join "`n")
if($joined -match '(?i)BRAIN_DROP_SYNC'){
  "SSOT_REFRESH: BRAIN_DONE"
}