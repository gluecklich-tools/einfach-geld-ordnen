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

# Read allowlist from step: must be literal-only string array
$content = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $StepPath).Path,[System.Text.Encoding]::UTF8)
if($content -notmatch "\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\("){ Fail "FAIL: STEP_WRITE_ALLOWLIST_MISSING in step: $StepPath" }
if($content -match "JOIN-PATH|Join-Path|\$RepoRoot|\$Target|\$PSScriptRoot"){ Fail "FAIL: STEP_WRITE_ALLOWLIST_NOT_LITERAL_ONLY in step: $StepPath" }

function NormPath([string]$p){
  if([string]::IsNullOrWhiteSpace($p)){ return "" }
  $x = $p -replace "/","\"
  $x = $x.Trim()
  $x = $x.TrimEnd("\")
  return $x.ToLowerInvariant()
}

$repo = (Resolve-Path -LiteralPath $RepoRoot).Path
$repoNorm = (NormPath $repo)

# Allowed: extract single-quoted string literals inside the allowlist block
$m = [regex]::Match($content,"(?s)\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\((.*?)\)\s*")
$body = $m.Groups[1].Value
$allowedRaw = [regex]::Matches($body,"'([^']+)'") | ForEach-Object { $_.Groups[1].Value }
if(@($allowedRaw).Count -lt 1){ Fail "FAIL: STEP_WRITE_ALLOWLIST_EMPTY in step: $StepPath" }

# Normalize allowed: expand to full path if relative, keep dirs as prefix-allow
$allowedFull = @()
$allowedDirs = @()
foreach($a in $allowedRaw){
  $isDir = $a.EndsWith("\") -or (Test-Path -LiteralPath $a -PathType Container)
  $full = $a
  if(-not [System.IO.Path]::IsPathRooted($full)){ $full = Join-Path $repo $full }
  $full = (Resolve-Path -LiteralPath $full).Path
  $n = (NormPath $full)
  $allowedFull += $n
  if($isDir){ $allowedDirs += $n }
}

# Normalize changed: repo-relative -> full -> norm
$viol = @()
foreach($c in @($ChangedPaths)){
  if([string]::IsNullOrWhiteSpace($c)){ continue }
  $rel = $c -replace "/","\"
  $full = Join-Path $repo $rel
  if(-not (Test-Path -LiteralPath $full)){
    # still compare by constructed path (best-effort)
    $full = [System.IO.Path]::GetFullPath($full)
  } else {
    $full = (Resolve-Path -LiteralPath $full).Path
  }
  $cn = (NormPath $full)
  $ok = $false
  if($allowedFull -contains $cn){ $ok = $true }
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
