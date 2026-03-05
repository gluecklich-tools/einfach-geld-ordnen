#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][string]$RepoRoot,
  [Parameter(Mandatory=$true)][string]$StepPath,
  [Parameter(Mandatory=$true)][string[]]$ChangedPaths
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$NL = [Environment]::NewLine
function Fail([string]$m){ throw $m }

$repo = (Resolve-Path -LiteralPath $RepoRoot).Path
$step = (Resolve-Path -LiteralPath $StepPath).Path

# Read step content (file-first)
$content = [System.IO.File]::ReadAllText($step,[System.Text.Encoding]::UTF8)

# Extract allowlist block (must exist)
$m = [regex]::Match($content,"(?s)\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\((.*?)\)\s*")
if(-not $m.Success){ Fail ("FAIL: STEP_WRITE_ALLOWLIST_MISSING in step: {0}" -f $step) }
$body = $m.Groups[1].Value

# Literal-only: allow only single-quoted string literals inside the block
$matches = [regex]::Matches($body,"'([^']+)'")
if(@($matches).Count -lt 1){ Fail ("FAIL: STEP_WRITE_ALLOWLIST_EMPTY in step: {0}" -f $step) }

# If the block contains anything besides whitespace, commas, and single-quoted strings -> NOT literal-only
$scrub = [regex]::Replace($body,"'([^']*)'","")
$scrub = [regex]::Replace($scrub,"[\s,]","")
if($scrub.Length -gt 0){ Fail ("FAIL: STEP_WRITE_ALLOWLIST_NOT_LITERAL_ONLY in step: {0}" -f $step) }

function Norm([string]$p){
  if([string]::IsNullOrWhiteSpace($p)){ return "" }
  $x = $p -replace "/","\"
  $x = $x.Trim()
  $x = $x.TrimEnd("\")
  $x.ToLowerInvariant()
}

# Build allowed sets (files + dirs)
$allowedRaw = @()
foreach($mm in $matches){ $allowedRaw += $mm.Groups[1].Value }
$allowedFiles = @()
$allowedDirs  = @()
foreach($a in $allowedRaw){
  $isDir = $a.EndsWith("\")
  $full = $a
  if(-not [System.IO.Path]::IsPathRooted($full)){ $full = Join-Path $repo $full }
  try { $full = (Resolve-Path -LiteralPath $full).Path } catch { $full = [System.IO.Path]::GetFullPath($full) }
  $n = Norm $full
  $allowedFiles += $n
  if($isDir){ $allowedDirs += $n }
}

# Normalize changed paths (repo-relative -> full -> norm)
$viol = @()
foreach($c in @($ChangedPaths)){
  if([string]::IsNullOrWhiteSpace($c)){ continue }
  $rel = ($c -replace "/","\")
  $full = Join-Path $repo $rel
  try { $full = (Resolve-Path -LiteralPath $full).Path } catch { $full = [System.IO.Path]::GetFullPath($full) }
  $cn = Norm $full
  $ok = $false
  if($allowedFiles -contains $cn){ $ok = $true }
  if(-not $ok){
    foreach($d in $allowedDirs){ if($cn.StartsWith($d)){ $ok = $true; break } }
  }
  if(-not $ok){ $viol += $rel }
}

if(@($viol).Count -gt 0){
  $msg=@()
  $msg += "FAIL: STEP_WRITE_ALLOWLIST_VIOLATION"
  $msg += "Allowed:"
  $msg += ($allowedRaw | ForEach-Object { "  " + $_ })
  $msg += "Changed:"
  $msg += ($ChangedPaths | ForEach-Object { "  " + $_ })
  $msg += "Violations:"
  $msg += ($viol | ForEach-Object { "  " + $_ })
  Fail ($msg -join $NL)
}

"OK: gate-step-write-allowlist"
exit 0
