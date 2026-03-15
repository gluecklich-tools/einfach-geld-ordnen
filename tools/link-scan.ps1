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

function Get-TrackedScopeFiles {
  param([Parameter(Mandatory = $true)][string]$Root)

  $gitArgs = @(
    '-C'
    $Root
    'ls-files'
    '--'
    '*.md'
    '*.html'
    '*.yml'
    '*.yaml'
    '*.xml'
    '*.json'
    '*.js'
    '*.css'
    '*.txt'
  )

  $trackedRelPaths = @(& git @gitArgs)
  if ($LASTEXITCODE -ne 0) {
    throw 'git ls-files failed.'
  }

  $targets = @(
    foreach ($rel in $trackedRelPaths) {
      if ([string]::IsNullOrWhiteSpace($rel)) { continue }

      $full = Join-Path $Root ($rel -replace '/', '\')
      if ((Test-Path -LiteralPath $full -PathType Leaf) -and (-not (IsExcluded -FullPath $full))) {
        Get-Item -LiteralPath $full
      }
    }
  )

  return @($targets | Sort-Object FullName -Unique)
}

$files = Get-TrackedScopeFiles -Root $RepoRoot

if ($files.Count -eq 0) {
  'PASS: link-scan (no tracked files in scope)'
  exit 0
}

$linkRegex = [regex]::new('https?://[^\s\)\]"''>]+', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
$hits = New-Object System.Collections.Generic.List[object]

foreach ($file in $files) {
  $lineNumber = 0
  foreach ($line in Get-Content -LiteralPath $file.FullName -Encoding UTF8) {
    $lineNumber++
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $matches = $linkRegex.Matches($line)
    foreach ($m in $matches) {
      $url = [string]$m.Value

      if ($url -match '(?i)localhost|127\.0\.0\.1') {
        $hits.Add([pscustomobject]@{
          File = $file.FullName
          Line = $lineNumber
          Url  = $url
          Rule = 'LOCALHOST_LINK'
        })
        continue
      }

      if ($url -match '(?i)file:///') {
        $hits.Add([pscustomobject]@{
          File = $file.FullName
          Line = $lineNumber
          Url  = $url
          Rule = 'FILE_SCHEME_LINK'
        })
        continue
      }
    }
  }
}

if ($hits.Count -gt 0) {
  'FAIL: link-scan'
  foreach ($h in $hits | Select-Object -First 200) {
    '{0}:L{1}: {2} :: {3}' -f @($h.File, $h.Line, $h.Rule, $h.Url)
  }
  exit 2
}

'PASS: link-scan'
exit 0
