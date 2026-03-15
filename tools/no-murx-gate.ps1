# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$enc = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8NoBom {
  param([Parameter(Mandatory=$true)][string]$Path)
  [System.IO.File]::ReadAllText($Path, $enc)
}

function S {
  param([int[]]$a)
  -join ($a | ForEach-Object { [char]$_ })
}

$bs    = [char]92
$fs    = [char]47
$colon = [char]58
$us    = [char]95

$wDesk   = S @(68,101,115,107,116,111,112)
$wUsers  = S @(85,115,101,114,115)
$wIntern = S @(73,78,84,69,82,78)
$wHub    = S @(69,71,79,95,72,85,66,95,69,88,80,79,82,84)

$patDeskBs   = ([string]$bs) + $wDesk + ([string]$bs)
$patDeskFs   = ([string]$fs) + $wDesk + ([string]$fs)
$patInternBs = ([string]$bs) + ([string]$us) + $wIntern + ([string]$bs)
$patInternFs = ([string]$fs) + ([string]$us) + $wIntern + ([string]$fs)
$patIntern2  = ([string]$us) + $wIntern + ([string]$bs)
$patUsers    = 'C' + ([string]$colon) + ([string]$bs) + $wUsers + ([string]$bs)

$forbid = @(
  $wHub,
  $patDeskBs,
  $patDeskFs,
  $patInternBs,
  $patInternFs,
  $patIntern2,
  $patUsers
)

$gitArgs = @(
  "-C"
  $repoRoot
  "ls-files"
  "--"
  "tools/apply-*.ps1"
  "tools/ego-law-run.ps1"
  "seiten/**/*.md"
  "pillar/**/*.md"
)

$trackedRelPaths = @(& git @gitArgs)
if ($LASTEXITCODE -ne 0) {
  throw "git ls-files failed."
}

$scan = @(
  foreach ($rel in $trackedRelPaths) {
    if ([string]::IsNullOrWhiteSpace($rel)) { continue }
    $full = Join-Path $repoRoot ($rel -replace '/', '\')
    if (Test-Path -LiteralPath $full -PathType Leaf) {
      Get-Item -LiteralPath $full
    }
  }
)

$hits = @()
foreach ($f in $scan) {
  $p = $f.FullName
  $raw = Read-Utf8NoBom -Path $p
  foreach ($pat in $forbid) {
    if ($raw.IndexOf($pat, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
      $hits += [pscustomobject]@{
        file    = $p.Replace($repoRoot + ([string]$bs), '')
        pattern = $pat
      }
    }
  }
}

if ($hits.Count -gt 0) {
  "FAIL: no-murx gate hit(s):"
  $hits | Sort-Object file, pattern | Format-Table -AutoSize
  throw "NO_MURX_FAIL"
}

"PASS: no-murx gate OK."