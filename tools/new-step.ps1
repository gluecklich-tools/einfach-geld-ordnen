#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Name,
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  [IO.File]::WriteAllText($Path, $Content, $utf8)
}

$repo = (Resolve-Path -LiteralPath $RepoRoot).Path
Set-Location -LiteralPath $repo

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$safe = ($Name -replace '[^a-zA-Z0-9_-]','-').Trim('-')
if(-not $safe){ throw "Name became empty after sanitization." }

$stepDir  = Join-Path $repo "_local\_scratch"
$stepPath = Join-Path $stepDir ("step_{0}_{1}.ps1" -f $safe, $ts)

$stub = @"
#requires -Version 7.0
param(
  [string]`$RepoRoot = (Get-Location).Path
)

# P0: Required by tools/gate-step-write-allowlist.ps1
`$EGO_STEP_WRITE_ALLOWLIST = @(
  # "path/relative/to/repo.ext"
)

`$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if(`$IsWindows){ chcp 65001 > `$null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(`$false)
`$utf8 = [System.Text.UTF8Encoding]::new(`$false)

function WriteUtf8NoBom([string]`$p,[string]`$s){ [IO.File]::WriteAllText(`$p,`$s,`$utf8) }

# TODO: SCAN → PLAN → APPLY → VERIFY → REPORT
"@

Write-Utf8NoBom $stepPath $stub
$stepPath