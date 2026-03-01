param(
  [Parameter(Mandatory)][string]$OutPath,
  [string]$RepoRoot = (Get-Location).Path,
  [switch]$AllowAnywhere
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

if(!(Test-Path -LiteralPath $RepoRoot)){ Fail "STOP: RepoRoot missing: $RepoRoot" }

# Normalize OutPath
$p = $OutPath
if([string]::IsNullOrWhiteSpace($p)){ Fail "STOP: OutPath empty" }
$p = $p.Trim()
$p = $p.Trim('"').Trim("'")
if(-not [IO.Path]::IsPathRooted($p)){
  $p = Join-Path $RepoRoot $p
}
$p = [IO.Path]::GetFullPath($p)

# Enforce _local\_scratch unless AllowAnywhere
if(-not $AllowAnywhere){
  $scratch = Join-Path $RepoRoot '_local\_scratch'
  if(!(Test-Path -LiteralPath $scratch)){ New-Item -ItemType Directory -Force -Path $scratch | Out-Null }
  $scratchFull = (Resolve-Path -LiteralPath $scratch).Path
  if(-not $p.StartsWith($scratchFull,[StringComparison]::OrdinalIgnoreCase)){
    Fail ("STOP: OutPath must be under _local\_scratch. Given: {0}`nAllowedRoot: {1}" -f $p,$scratchFull)
  }
}

$dir = Split-Path -Parent $p
if(!(Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Force -Path $dir | Out-Null }

$txt = Get-Clipboard
if([string]::IsNullOrWhiteSpace($txt)){ Fail "STOP: Clipboard empty" }

[IO.File]::WriteAllText($p,$txt,$enc)
"OK: wrote $($txt.Length) chars -> $p"
exit 0