#requires -Version 7.0
[CmdletBinding()]
param(
  # Repo root; default derived from git
  [string]$RepoRoot = "",
  # One or more repo-relative globs; default tools/*.ps1
  [string[]]$Include = @("tools/*.ps1"),
  # Repo-relative prefixes to exclude
  [string[]]$Exclude = @(),
  # Report-only
  [switch]$WhatIf
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Resolve-RepoRoot([string]$RepoRoot){
  if($RepoRoot -and $RepoRoot.Trim().Length -gt 0){
    return (Resolve-Path -LiteralPath $RepoRoot).Path
  }
  try { return (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path }
  catch { throw "RepoRoot not found." }
}

function To-RepoRel([string]$repo,[string]$full){
  $rp = [System.IO.Path]::GetFullPath($repo)
  $fp = [System.IO.Path]::GetFullPath($full)
  if($fp.StartsWith($rp,[System.StringComparison]::OrdinalIgnoreCase)){
    $rel = $fp.Substring($rp.Length).TrimStart('\','/')
    return $rel.Replace('\','/')
  }
  return $full
}

function Get-FilesFromGlob([string]$repo,[string]$glob){
  $g = $glob.Replace('\','/')
  $dir = Split-Path -Parent $g
  if([string]::IsNullOrWhiteSpace($dir)){ $dir="." }
  $dirFull = Join-Path $repo $dir
  if(!(Test-Path -LiteralPath $dirFull)){ return @() }

  $pattern = Split-Path -Leaf $g
  $recurse = $g.Contains("**/")
  if($recurse){
    $pattern = $pattern.Replace("**/","")
    return Get-ChildItem -LiteralPath $dirFull -File -Recurse -Filter $pattern -ErrorAction Stop
  } else {
    return Get-ChildItem -LiteralPath $dirFull -File -Filter $pattern -ErrorAction Stop
  }
}

function Has-CRLF([string]$text){ return $text.Contains("`r`n") }

function Ensure-Dir([string]$path){
  $dir = Split-Path -Parent $path
  if($dir -and !(Test-Path -LiteralPath $dir)){
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
}

function Write-Utf8NoBomLF([string]$path,[string]$text){
  Ensure-Dir $path
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $t = $text.Replace("`r`n","`n")
  [System.IO.File]::WriteAllText($path,$t,$utf8)
}

$repo = Resolve-RepoRoot $RepoRoot

# Build file set (de-dupe)
$all = New-Object System.Collections.Generic.List[string]
foreach($g in $Include){
  foreach($f in (Get-FilesFromGlob $repo $g)){
    $all.Add($f.FullName)
  }
}
$files = $all | Sort-Object -Unique

# Apply excludes (prefix match on repo-rel)
$ex = @($Exclude | ForEach-Object { ($_.Replace('\','/')).TrimStart('/') })
$filtered = @()
foreach($f in $files){
  $rel = To-RepoRel $repo $f
  $skip = $false
  foreach($e in $ex){
    if($e.Length -gt 0 -and $rel.StartsWith($e,[System.StringComparison]::OrdinalIgnoreCase)){
      $skip = $true; break
    }
  }
  if(-not $skip){ $filtered += $f }
}

$changed = New-Object System.Collections.Generic.List[object]
foreach($f in $filtered){
  $raw = [System.IO.File]::ReadAllText($f,[System.Text.UTF8Encoding]::new($false))
  if(Has-CRLF $raw){
    $rel = To-RepoRel $repo $f
    if($WhatIf){
      $changed.Add([pscustomobject]@{ file=$rel; action="would-fix" })
    } else {
      Write-Utf8NoBomLF $f $raw
      $changed.Add([pscustomobject]@{ file=$rel; action="fixed" })
    }
  }
}

if($changed.Count -eq 0){
  Write-Output "OK: EOL normalize: no changes"
} else {
  Write-Output ("OK: EOL normalize: changed=" + $changed.Count)
  foreach($c in $changed){
    Write-Output (" - " + $c.action + ": " + $c.file)
  }
}