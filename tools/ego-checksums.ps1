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

function Get-TrackedTargets {
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
    '*.json'
    '*.xml'
    '*.js'
    '*.css'
    '*.txt'
    '*.ps1'
  )

  $trackedRelPaths = @(& git @gitArgs)
  if ($LASTEXITCODE -ne 0) {
    throw 'git ls-files failed.'
  }

  $targets = @(
    foreach ($rel in $trackedRelPaths | Sort-Object -Unique) {
      if ([string]::IsNullOrWhiteSpace($rel)) { continue }

      $full = Join-Path $Root ($rel -replace '/', '\')
      if ((Test-Path -LiteralPath $full -PathType Leaf) -and (-not (IsExcluded -FullPath $full))) {
        Get-Item -LiteralPath $full
      }
    }
  )

  return @($targets | Sort-Object FullName -Unique)
}

$files = Get-TrackedTargets -Root $RepoRoot

if ($files.Count -eq 0) {
  'PASS: ego-checksums (no tracked files in scope)'
  exit 0
}

$rows = New-Object System.Collections.Generic.List[string]
$rows.Add('Path`tSHA256')

foreach ($file in $files) {
  $rel = $file.FullName.Substring($RepoRoot.Length + 1).Replace('\','/')
  $hash = Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256
  $rows.Add(('{0}`t{1}' -f @($rel, $hash.Hash.ToLowerInvariant())))
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = (($rows | ForEach-Object { $_ }) -join "`n") + "`n"
[System.IO.File]::WriteAllText((Join-Path $RepoRoot '_local\reports\ego-checksums.tsv'), $content, $utf8NoBom)

'PASS: ego-checksums'
exit 0