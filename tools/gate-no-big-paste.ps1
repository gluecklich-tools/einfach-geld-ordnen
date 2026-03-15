param([string]$RepoRoot = (Get-Location).Path)

. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1')

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if (-not $PSCommandPath) { throw "Gate must be run from a file (pwsh -NoProfile -File ...)."}
if ($PSVersionTable.PSVersion.Major -lt 7) { throw "Require PowerShell 7+ (pwsh)."}
$utf8=[System.Text.UTF8Encoding]::new($false)
$tools=Join-Path $RepoRoot 'tools'
$ego=Join-Path $tools 'ego-run.ps1'
$kls=Join-Path $tools 'klaus-run.ps1'
foreach($p in @($ego,$kls)){
  if(-not(Test-Path -LiteralPath $p)){ throw "Missing runner: $p" }
  $t=[IO.File]::ReadAllText($p,$utf8)
  if($t -notmatch 'EGO_NO_BIG_PASTE_RUNNER_V1'){ throw "Runner not marked for No-Big-Paste law: $p" }
}
[pscustomobject]@{ Gate='OK'; RepoRoot=$RepoRoot; RunnersChecked=@($ego,$kls) }