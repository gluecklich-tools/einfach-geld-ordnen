param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 2 }
if(!(Test-Path -LiteralPath $RepoRoot)){ Fail "RepoRoot not found: $RepoRoot" }

function Is-RelevantExt([string]$p){
  $ext = [IO.Path]::GetExtension($p).ToLowerInvariant()
  return ($ext -in @('.ps1','.psm1','.psd1','.yml','.yaml','.md','.txt'))
}

function Is-ExcludedPath([string]$rel){
  # normalize to forward slashes
  $r = ($rel -replace '\\','/').TrimStart('/')
  if($r.StartsWith('.git/')){ return $true }
  if($r.StartsWith('_local/')){ return $true }
  if($r.StartsWith('_site/')){ return $true }
  if($r.StartsWith('vendor/')){ return $true }
  if($r.StartsWith('node_modules/')){ return $true }
  return $false
}

$files = New-Object System.Collections.Generic.List[string]

$git = Get-Command git -ErrorAction SilentlyContinue
if($null -ne $git){
  Push-Location -LiteralPath $RepoRoot
  try{
    # tracked files only
    $ls = & git ls-files 2>$null
    foreach($rel in $ls){
      if([string]::IsNullOrWhiteSpace($rel)){ continue }
      if(Is-ExcludedPath $rel){ continue }
      $full = Join-Path $RepoRoot $rel
      if(!(Test-Path -LiteralPath $full)){ continue }
      if(Is-RelevantExt $full){ $files.Add($full) }
    }
  } finally {
    Pop-Location
  }
} else {
  # fallback: file walk with excludes
  Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Force |
    ForEach-Object {
      $full = $_.FullName
      $rel = $full.Substring($RepoRoot.Length).TrimStart('\','/')
      if(Is-ExcludedPath $rel){ return }
      if(Is-RelevantExt $full){ $files.Add($full) }
    }
}

$hits = New-Object System.Collections.Generic.List[object]

foreach($p in $files){
  $lines = $null
  try{ $lines = [IO.File]::ReadAllLines($p, $enc) }catch{ continue }
  for($i=0; $i -lt $lines.Length; $i++){
    $ln = $lines[$i]
    if($null -eq $ln){ continue }

    # Heuristik: echte PS-Prompts / Continuation
    if($ln.StartsWith("PS ", [StringComparison]::Ordinal) -or
       $ln.StartsWith(">>", [StringComparison]::Ordinal)){
      $hits.Add([pscustomobject]@{ Path=$p; Line=($i+1); Text=$ln })
    }
  }
}

if($hits.Count -gt 0){
  "FAIL: NO_CONSOLE_TRANSCRIPTS"
  $hits | ForEach-Object { " - $($_.Path):$($_.Line) :: $($_.Text)" }
  exit 3
}

"PASS: NO_CONSOLE_TRANSCRIPTS"
exit 0