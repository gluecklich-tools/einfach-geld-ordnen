param(
  [Parameter(Mandatory=$true)][string]$NamePrefix
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

function Get-RepoRoot {
  $p = (& git rev-parse --show-toplevel 2>$null)
  if (-not $p) { Fail "RepoRoot konnte nicht bestimmt werden (git rev-parse)." }
  return (Resolve-Path -LiteralPath $p).Path
}

function New-Dir([string]$p){
  if ($p -and -not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

function Write-Utf8NoBomLf {
  param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$Text)
  $dir = Split-Path -Parent $Path
  New-Dir $dir
  $t = $Text -replace "
","
"
  $t = $t -replace "
","
"
  if (-not $t.EndsWith("
")) { $t += "
" }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $t, $enc)
}

$RepoRoot = Get-RepoRoot
$Scratch = Join-Path $RepoRoot "_local\_scratch"
New-Dir $Scratch

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$path = Join-Path $Scratch ("{0}_{1}.ps1" -f $NamePrefix, $ts)

# minimal stub with allowlist placeholder (user FULLSWAP replaces)
$stub = "# STEP
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$EGO_STEP_WRITE_ALLOWLIST = @(
  '_local\_reports\'
)

# TODO: FULLSWAP
"
Write-Utf8NoBomLf -Path $path -Text $stub

$path
