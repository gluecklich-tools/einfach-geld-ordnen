param(
  [Parameter(Mandatory = $true)]
  [string] $RepoPath,
  [ValidateSet('Plan','Apply')]
  [string] $Mode = 'Plan'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$impl = Join-Path $PSScriptRoot 'weiter-fix.ps1'
if (-not (Test-Path -LiteralPath $impl)) {
  throw ("Missing implementation script: " + $impl)
}
if ($Mode -eq 'Apply') {
  & $impl -RepoPath $RepoPath -Apply
}
else {
  & $impl -RepoPath $RepoPath
}