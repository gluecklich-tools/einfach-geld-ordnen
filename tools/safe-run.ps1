# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Find-RepoRoot {
  $cur = (Get-Location).Path
  for ($i=0; $i -lt 15; $i++) {
    if (Test-Path -LiteralPath (Join-Path $cur '.git')) { return $cur }
    $parent = Split-Path -Parent $cur
    if (-not $parent -or $parent -eq $cur) { break }
    $cur = $parent
  }
  throw "RepoRoot not found."
}

function Get-WeiterBlock {
  param([string]$Text)
  $n = $Text -replace "`r`n","`n" -replace "`r","`n"
  $m = [regex]::Match($n, '(?is)##\s+Weiter\s*\n(?<b>.*?)(?=\n##\s+|\z)')
  if (-not $m.Success) { return $null }
  return $m.Groups['b'].Value
}

function Get-TrackedMarkdownFiles {
  param([string]$RepoRoot)

  $files = New-Object System.Collections.Generic.List[string]
  $tracked = @(
    git -C $RepoRoot ls-files -- 'seiten/*.md' 'seiten/*.markdown' 'pillar/*.md' 'pillar/*.markdown'
  )

  foreach($rel in $tracked){
    if([string]::IsNullOrWhiteSpace($rel)){ continue }
    $full = Join-Path $RepoRoot $rel
    if(-not (Test-Path -LiteralPath $full -PathType Leaf)){ continue }
    $files.Add((Resolve-Path -LiteralPath $full).Path) | Out-Null
  }

  return @($files | Sort-Object -Unique)
}

function Get-EligibleMarkdownFiles {
  param([string]$RepoRoot)

  $items = New-Object System.Collections.Generic.List[System.IO.FileInfo]
  $trackedFiles = @(Get-TrackedMarkdownFiles -RepoRoot $RepoRoot)

  foreach($full in $trackedFiles){
    $ext = [System.IO.Path]::GetExtension($full)
    if($ext -notin @('.md','.markdown')){ continue }
    $items.Add((Get-Item -LiteralPath $full)) | Out-Null
  }

  return @($items | Sort-Object FullName -Unique)
}

$RepoRoot = Find-RepoRoot
Set-Location -LiteralPath $RepoRoot

$auditDir = Join-Path $RepoRoot 'assets\audit\weiter_links'
New-Item -ItemType Directory -Force -Path $auditDir | Out-Null

try {
  $reportPath = Join-Path $auditDir 'weiter_scan_report.md'
  $mdFiles = @(Get-EligibleMarkdownFiles -RepoRoot $RepoRoot)

  $rows = New-Object System.Collections.Generic.List[object]
  foreach ($f in $mdFiles) {
    $text = [IO.File]::ReadAllText($f.FullName, [Text.UTF8Encoding]::new($false))
    $wb = Get-WeiterBlock -Text $text
    $rel = $f.FullName.Substring($RepoRoot.Length).TrimStart('\','/')

    $mdc = 0
    $htmlc = 0
    $refc = 0

    if ($wb) {
      $mdc = ([regex]::Matches($wb, '(?m)^\s*-\s*\[[^\]]+\]\((?!https?://)(?!mailto:)(?!#)[^)]+\)', 'IgnoreCase')).Count
      $htmlc = ([regex]::Matches($wb, '\]\((?!https?://)(?!mailto:)(?!#)[^)]+\.html(?:#.*)?\)', 'IgnoreCase')).Count
      $refc = ([regex]::Matches($wb, '\{\{\s*site\.baseurl\s*\}\}', 'IgnoreCase')).Count
    }

    $rows.Add([pscustomobject]@{
      RelativePath = $rel
      MdLinks      = $mdc
      HtmlLinks    = $htmlc
      BaseurlRefs  = $refc
      HasWeiter    = [bool]$wb
    }) | Out-Null
  }

  $out = New-Object System.Collections.Generic.List[string]
  $out.Add('# Weiter Scan Report (ALLOWLIST: seiten + pillar)') | Out-Null
  $out.Add('') | Out-Null
  $out.Add('RepoRoot: ' + $RepoRoot) | Out-Null
  $out.Add('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) | Out-Null
  $out.Add('Tracked files: ' + $mdFiles.Count) | Out-Null
  $out.Add('') | Out-Null
  $out.Add('| Datei | Weiter | md-Links | html-Links | baseurl-Refs |') | Out-Null
  $out.Add('|---|---:|---:|---:|---:|') | Out-Null

  foreach ($r in $rows | Sort-Object RelativePath) {
    $out.Add(('| {0} | {1} | {2} | {3} | {4} |' -f $r.RelativePath, ([int]$r.HasWeiter), $r.MdLinks, $r.HtmlLinks, $r.BaseurlRefs)) | Out-Null
  }

  [IO.File]::WriteAllText($reportPath, ($out.ToArray() -join "`n"), [Text.UTF8Encoding]::new($false))
  Write-Host ('OK: ' + $reportPath)
}
catch {
  Write-Error $_
  exit 1
}

try {
  $debugPath = Join-Path $auditDir 'weiter_debug_zero_samples.md'
  $mdFiles = @(Get-EligibleMarkdownFiles -RepoRoot $RepoRoot)

  $rows = New-Object System.Collections.Generic.List[object]
  foreach ($f in $mdFiles) {
    $text = [IO.File]::ReadAllText($f.FullName, [Text.UTF8Encoding]::new($false))
    $wb = Get-WeiterBlock -Text $text
    $rel = $f.FullName.Substring($RepoRoot.Length).TrimStart('\','/')

    $mdc = 0; $htmlc = 0; $refc = 0
    if ($wb) {
      $mdc = ([regex]::Matches($wb, '(?m)^\s*-\s*\[[^\]]+\]\((?!https?://)(?!mailto:)(?!#)[^)]+\)', 'IgnoreCase')).Count
      $htmlc = ([regex]::Matches($wb, '\]\((?!https?://)(?!mailto:)(?!#)[^)]+\.html(?:#.*)?\)', 'IgnoreCase')).Count
      $refc = ([regex]::Matches($wb, '\{\{\s*site\.baseurl\s*\}\}', 'IgnoreCase')).Count
    }

    if (($mdc + $htmlc + $refc) -eq 0) {
      $rows.Add([pscustomobject]@{
        RelativePath = $rel
        HasWeiter    = [bool]$wb
      }) | Out-Null
    }
  }

  $out = New-Object System.Collections.Generic.List[string]
  $out.Add('# Weiter Debug - Zero Samples (ALLOWLIST: seiten + pillar)') | Out-Null
  $out.Add('') | Out-Null
  $out.Add('RepoRoot: ' + $RepoRoot) | Out-Null
  $out.Add('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) | Out-Null
  $out.Add('Tracked files: ' + $mdFiles.Count) | Out-Null
  $out.Add('Zero rows: ' + $rows.Count) | Out-Null
  $out.Add('') | Out-Null

  foreach ($r in $rows | Sort-Object RelativePath) {
    $out.Add(('- {0} | HasWeiter={1}' -f $r.RelativePath, ([int]$r.HasWeiter))) | Out-Null
  }

  [IO.File]::WriteAllText($debugPath, ($out.ToArray() -join "`n"), [Text.UTF8Encoding]::new($false))
  Write-Host ('OK: ' + $debugPath)
}
catch {
  Write-Error $_
  exit 1
}

exit 0