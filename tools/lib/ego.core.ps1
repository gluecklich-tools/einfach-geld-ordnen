Set-StrictMode -Version Latest
function Write-EgoLog([string]$msg){
  $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
  Write-Host ("[{0}] {1}" -f $ts, $msg)
}
function Resolve-EgoRepoRoot([string]$RepoRoot){
  if(!$RepoRoot){ $RepoRoot = (Get-Location).Path }
  if(!(Test-Path -LiteralPath $RepoRoot)){ throw "STOP: RepoRoot not found: $RepoRoot" }
  return (Resolve-Path -LiteralPath $RepoRoot).Path
}
function Invoke-EgoToolFile(
  [Parameter(Mandatory=$true)][string]$RepoRoot,
  [Parameter(Mandatory=$true)][string]$ToolPath,
  [hashtable]$Args = @{}
){
  $full = $ToolPath
  if(!(Test-Path -LiteralPath $full)){
    # allow relative to repo root
    $full = Join-Path $RepoRoot $ToolPath
  }
  if(!(Test-Path -LiteralPath $full)){ throw "STOP: tool missing: $ToolPath" }
  $argList = @()
  foreach($k in $Args.Keys){
    $argList += "-$k"
    $argList += [string]$Args[$k]
  }
  Write-EgoLog ("RUN: pwsh -NoProfile -File `"{0}`" {1}" -f $full, ($argList -join " "))
  & pwsh -NoProfile -File $full @argList
  $code = $LASTEXITCODE
  if($code -ne 0){ throw "STOP: tool failed (exit=$code): $ToolPath" }
}