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
  "BRAIN_SYNC: SKIP (internal tools root missing): $InternalToolsRoot"
  exit 0
}

# deterministische Tool-Discovery: brain-drop-sync bevorzugen, sonst brain-sync
$cands = @()
$cands += @(Get-ChildItem -LiteralPath $InternalToolsRoot -File -Filter '*brain*drop*sync*.ps1' -ErrorAction SilentlyContinue)
$cands += @(Get-ChildItem -LiteralPath $InternalToolsRoot -File -Filter '*brain*sync*.ps1'      -ErrorAction SilentlyContinue)

$cands = @($cands | Sort-Object FullName -Unique)
if(@($cands).Count -eq 0){
  if($FailIfMissing){ throw "STOP: brain sync tool not found in: $InternalToolsRoot" }
  "BRAIN_SYNC: SKIP (no tool matched '*brain*drop*sync*.ps1' or '*brain*sync*.ps1' in $InternalToolsRoot)"
  exit 0
}

# prefer drop-sync if present
$tool = ($cands | Where-Object { $_.Name -like '*drop*sync*' } | Select-Object -First 1)
if($null -eq $tool){ $tool = $cands[0] }

"BRAIN_SYNC: RUN $($tool.FullName)"
& pwsh -NoProfile -File $tool.FullName