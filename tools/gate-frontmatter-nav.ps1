param()

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
try { if ($IsWindows) { chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

$RepoRoot = (Get-Location).Path

function Get-TrackedMarkdownTargets {
  param([Parameter(Mandatory = $true)][string]$Root)

  $gitArgs = @(
    '-C'
    $Root
    'ls-files'
    '--'
    'seiten/**/*.md'
    'pillar/**/*.md'
  )

  $trackedRelPaths = @(& git @gitArgs)
  if ($LASTEXITCODE -ne 0) {
    throw 'git ls-files failed.'
  }

  $targets = @(
    foreach ($rel in $trackedRelPaths) {
      if ([string]::IsNullOrWhiteSpace($rel)) { continue }

      $full = Join-Path $Root ($rel -replace '/', '\')
      if (Test-Path -LiteralPath $full -PathType Leaf) {
        Get-Item -LiteralPath $full
      }
    }
  )

  return @($targets | Sort-Object FullName -Unique)
}

function Get-FrontmatterLines {
  param([Parameter(Mandatory = $true)][string[]]$Lines)

  if ($Lines.Count -lt 3) { return @() }
  if ($Lines[0].Trim() -ne '---') { return @() }

  $end = -1
  for ($i = 1; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i].Trim() -eq '---') {
      $end = $i
      break
    }
  }

  if ($end -lt 1) { return @() }
  return @($Lines[1..($end - 1)])
}

$files = @(Get-TrackedMarkdownTargets -Root $RepoRoot)

if ($files.Count -eq 0) {
  'PASS: gate-frontmatter-nav (no tracked markdown files in scope)'
  exit 0
}

$fail = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
  $lines = @(Get-Content -LiteralPath $file.FullName -Encoding UTF8)
  $frontmatter = @(Get-FrontmatterLines -Lines $lines)

  if ($frontmatter.Count -eq 0) {
    continue
  }

  $hasLayout = $false
  $hasTitle = $false
  $hasPermalink = $false

  foreach ($line in $frontmatter) {
    $trim = $line.Trim()
    if ($trim -match '^(?i)layout\s*:')    { $hasLayout = $true; continue }
    if ($trim -match '^(?i)title\s*:')     { $hasTitle = $true; continue }
    if ($trim -match '^(?i)permalink\s*:') { $hasPermalink = $true; continue }
  }

  $missing = @()
  if (-not $hasLayout)    { $missing += 'layout' }
  if (-not $hasTitle)     { $missing += 'title' }
  if (-not $hasPermalink) { $missing += 'permalink' }

  if ($missing.Count -gt 0) {
    $rel = $file.FullName.Substring($RepoRoot.Length + 1).Replace('\','/')
    $fail.Add(('{0}: missing frontmatter key(s): {1}' -f @($rel, ($missing -join ', '))))
  }
}

if ($fail.Count -gt 0) {
  'FAIL: gate-frontmatter-nav'
  $fail | ForEach-Object { ' - ' + $_ }
  exit 2
}

'PASS: gate-frontmatter-nav'
exit 0
