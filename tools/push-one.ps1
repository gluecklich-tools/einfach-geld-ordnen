#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)]
  [string]$Pattern,

  [Parameter(Mandatory=$false)]
  [string]$CommitMessage = "chore: run step + push-one"
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if([string]::IsNullOrWhiteSpace($RepoRoot)){ Fail "RepoRoot not found." }
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

# Repo must be clean before running a step
$dirty = @(git status --porcelain=v1)
if($dirty.Count -gt 0){
  $list = ($dirty -join "`n")
  Fail "REPO_DIRTY: make repo clean before push-one.`n$list"
}

# Run latest step by pattern (enterprise one-shot)
& (Join-Path $PSScriptRoot "step-run-latest.ps1") -Pattern $Pattern

# If step produced changes: stage+commit
$dirty2 = @(git status --porcelain=v1)
if($dirty2.Count -gt 0){
  git add -A
  git commit -m $CommitMessage
}

# Then finish (closeout + push only if ahead)
& (Join-Path $PSScriptRoot "finish-one.ps1")