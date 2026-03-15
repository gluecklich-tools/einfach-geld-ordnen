param()

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

$RepoRoot = (Get-Location).Path

function IsExcluded {
  param([Parameter(Mandatory = $true)][string]$FullPath)

  $n = $FullPath.Replace('/','\').ToLowerInvariant()

  if ($n -like '*\.git\*') { return $true }
  if ($n -like '*\_local\*') { return $true }
  if ($n -like '*\node_modules\*') { return $true }
  if ($n -like '*\_site\*') { return $true }
  if ($n -like '*\vendor\bundle\*') { return $true }
  if ($n -like '*\bin\*') { return $true }
  if ($n -like '*\obj\*') { return $true }

  return $false
}

$gitArgs = @(
  '-C'
  $RepoRoot
  'ls-files'
  '--'
  '*.md'
  '*.html'
  '*.yml'
  '*.yaml'
  '*.json'
  '*.js'
  '*.css'
  '*.txt'
  '*.xml'
  '*.ps1'
)

$trackedRelPaths = @(& git @gitArgs)
if ($LASTEXITCODE -ne 0) {
  throw 'git ls-files failed.'
}

$targets = @(
  foreach ($rel in $trackedRelPaths) {
    if ([string]::IsNullOrWhiteSpace($rel)) { continue }
    $full = Join-Path $RepoRoot ($rel -replace '/', '\')
    if ((Test-Path -LiteralPath $full -PathType Leaf) -and (-not (IsExcluded -FullPath $full))) {
      Get-Item -LiteralPath $full
    }
  }
)

if ($targets.Count -eq 0) {
  'PASS: gate-no-emoji (no tracked files in scope)'
  exit 0
}

$emojiRegex = [regex]::new('([\u2600-\u27BF]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDEFF]|[\uD83E][\uDD00-\uDEFF])', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$hits = New-Object System.Collections.Generic.List[object]

foreach ($file in $targets) {
  $lineNumber = 0
  foreach ($line in Get-Content -LiteralPath $file.FullName -Encoding UTF8) {
    $lineNumber++
    if ([string]::IsNullOrEmpty($line)) { continue }

    $m = $emojiRegex.Match($line)
    if ($m.Success) {
      $hits.Add([pscustomobject]@{
        File  = $file.FullName
        Line  = $lineNumber
        Emoji = $m.Value
        Text  = $line.Trim()
      })
    }
  }
}

if ($hits.Count -gt 0) {
  'FAIL: gate-no-emoji'
  foreach ($h in $hits | Select-Object -First 200) {
    '{0}:L{1}: emoji={2} :: {3}' -f @($h.File, $h.Line, $h.Emoji, $h.Text)
  }
  exit 2
}

'PASS: gate-no-emoji'
exit 0
