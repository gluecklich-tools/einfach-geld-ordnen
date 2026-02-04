#requires -Version 7.0
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet('weiter-scan','weiter-debug')]
  [string]$Task
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
if ($IsWindows) { try { chcp 65001 | Out-Null } catch {} }
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Find-RepoRoot {
  $cur = (Get-Location).Path
  for ($i=0; $i -lt 15; $i++) {
    if (Test-Path -LiteralPath (Join-Path $cur '_config.yml')) { return $cur }
    if (Test-Path -LiteralPath (Join-Path $cur '.git')) { return $cur }
    $parent = Split-Path -Parent $cur
    if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $cur) { break }
    $cur = $parent
  }
  throw 'Repo root not found (expected _config.yml or .git).'
}

function Get-WeiterBlock {
  param([string]$Text)
  $lines = $Text -split "`n"
  $startIdx = -1
  for ($i=0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^\s*##\s+Weiter\s*$') { $startIdx = $i; break }
  }
  if ($startIdx -lt 0) { return [pscustomobject]@{ HasWeiter=$false; Block='' } }

  $blockLines = New-Object System.Collections.Generic.List[string]
  for ($j=$startIdx+1; $j -lt $lines.Length; $j++) {
    if ($lines[$j] -match '^\s*##\s+\S' -or $lines[$j] -match '^\s*#\s+\S') { break }
    $blockLines.Add($lines[$j]) | Out-Null
  }
  $block = ($blockLines.ToArray() -join "`n").Trim()
  [pscustomobject]@{ HasWeiter=$true; Block=$block }
}

function Count-MdLinks {
  param([string]$Block)
  if ([string]::IsNullOrWhiteSpace($Block)) { return 0 }
  @([regex]::Matches($Block, '\[[^\]]+\]\(([^)]+)\)')).Count
}

function Count-HtmlLinks {
  param([string]$Block)
  if ([string]::IsNullOrWhiteSpace($Block)) { return 0 }
  @([regex]::Matches($Block, '(?i)<a\s+[^>]*href\s*=\s*["''][^"'''']+["''][^>]*>')).Count
}

function Count-RefStyleLinks {
  param([string]$Block)
  if ([string]::IsNullOrWhiteSpace($Block)) { return 0 }
  @([regex]::Matches($Block, '(?m)(?<!\!)\[[^\]]+\]\[[^\]]+\]')).Count
}

function Get-EligibleMarkdownFiles {
  param([string]$RepoRoot)

  # ALLOWLIST: only real live content trees
  $roots = @(
    (Join-Path $RepoRoot 'seiten'),
    (Join-Path $RepoRoot 'pillar')
  )

  $files = New-Object System.Collections.Generic.List[object]
  foreach ($r in $roots) {
    if (Test-Path -LiteralPath $r) {
      Get-ChildItem -LiteralPath $r -Recurse -File -Force |
        Where-Object { $_.Extension -in @('.md','.markdown') } |
        ForEach-Object { $files.Add($_) | Out-Null }
    }
  }

  $files.ToArray()
}

$RepoRoot = Find-RepoRoot
Set-Location -LiteralPath $RepoRoot

$auditDir = Join-Path $RepoRoot 'assets\audit\weiter_links'
New-Item -ItemType Directory -Force -Path $auditDir | Out-Null

if ($Task -eq 'weiter-scan') {

  $reportPath = Join-Path $auditDir 'weiter_scan_report.md'

  if (!(Test-Path -LiteralPath $report)) {
    $d = Split-Path -Parent $report
    if (!(Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    [IO.File]::WriteAllText($report, ("# Weiter-Scan Report`n`nGenerated: " + (Get-Date).ToString("s") + "`n`nNOTE: Report was missing; created for CI determinism.`n"), [System.Text.UTF8Encoding]::new($false))
  }

  $mdFiles = @(Get-EligibleMarkdownFiles -RepoRoot $RepoRoot)

  $rows = New-Object System.Collections.Generic.List[object]
  foreach ($f in $mdFiles) {
    $text = [IO.File]::ReadAllText($f.FullName, [Text.UTF8Encoding]::new($false))
    $wb = Get-WeiterBlock -Text $text
    $rel = $f.FullName.Substring($RepoRoot.Length).TrimStart('\','/')

    $mdc = 0
    if ($wb.HasWeiter) { $mdc = Count-MdLinks -Block $wb.Block }

    $rows.Add([pscustomobject]@{ File=$rel; HasWeiter=$wb.HasWeiter; MdLinks=[int]$mdc }) | Out-Null
  }

  $all = @($rows.ToArray())

  $total   = $all.Count
  $missing = @($all | Where-Object { -not $_.HasWeiter }).Count
  $zero    = @($all | Where-Object { $_.HasWeiter -and $_.MdLinks -eq 0 }).Count
  $not3    = @($all | Where-Object { $_.HasWeiter -and $_.MdLinks -ne 3 }).Count
  $ok      = @($all | Where-Object { $_.HasWeiter -and $_.MdLinks -eq 3 }).Count

  $out = New-Object System.Collections.Generic.List[string]
  $out.Add('# Weiter Scan Report (ALLOWLIST: seiten + pillar)') | Out-Null
  $out.Add('') | Out-Null
  $out.Add('RepoRoot: ' + $RepoRoot) | Out-Null
  $out.Add('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) | Out-Null
  $out.Add('') | Out-Null
  $out.Add('## Summary') | Out-Null
  $out.Add('') | Out-Null
  $out.Add('| Metric | Value |') | Out-Null
  $out.Add('|---|---:|') | Out-Null
  $out.Add('| Total MD files | ' + $total + ' |') | Out-Null
  $out.Add('| Missing ## Weiter | ' + $missing + ' |') | Out-Null
  $out.Add('| HasWeiter + MdLinks=0 | ' + $zero + ' |') | Out-Null
  $out.Add('| HasWeiter + MdLinks!=3 | ' + $not3 + ' |') | Out-Null
  $out.Add('| HasWeiter + MdLinks=3 | ' + $ok + ' |') | Out-Null
  $out.Add('') | Out-Null

  [IO.File]::WriteAllText($reportPath, ($out.ToArray() -join "`n"), [Text.UTF8Encoding]::new($false))
  Write-Host ('OK: ' + $reportPath)
}

if ($Task -eq 'weiter-debug') {

  $debugPath = Join-Path $auditDir 'weiter_debug_zero_samples.md'
  $mdFiles = @(Get-EligibleMarkdownFiles -RepoRoot $RepoRoot)

  $rows = New-Object System.Collections.Generic.List[object]
  foreach ($f in $mdFiles) {
    $text = [IO.File]::ReadAllText($f.FullName, [Text.UTF8Encoding]::new($false))
    $wb = Get-WeiterBlock -Text $text
    $rel = $f.FullName.Substring($RepoRoot.Length).TrimStart('\','/')

    $mdc = 0; $htmlc = 0; $refc = 0
    if ($wb.HasWeiter) {
      $mdc = Count-MdLinks -Block $wb.Block
      $htmlc = Count-HtmlLinks -Block $wb.Block
      $refc = Count-RefStyleLinks -Block $wb.Block
    }

    $rows.Add([pscustomobject]@{ File=$rel; HasWeiter=$wb.HasWeiter; MdLinks=[int]$mdc; HtmlLinks=[int]$htmlc; RefLinks=[int]$refc; Block=$wb.Block }) | Out-Null
  }

  $topZero = @($rows.ToArray() | Where-Object { $_.HasWeiter -and $_.MdLinks -eq 0 } | Sort-Object File | Select-Object -First 10)

  $out = New-Object System.Collections.Generic.List[string]
  $out.Add('# Weiter Debug - Zero Samples (ALLOWLIST: seiten + pillar)') | Out-Null
  $out.Add('') | Out-Null
  $out.Add('RepoRoot: ' + $RepoRoot) | Out-Null
  $out.Add('Generated: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) | Out-Null
  $out.Add('') | Out-Null

  $out.Add('## Top 10 files where MdLinks=0 (with counts)') | Out-Null
  $out.Add('') | Out-Null
  $out.Add('| File | MdLinks | HtmlLinks | RefLinks |') | Out-Null
  $out.Add('|---|---:|---:|---:|') | Out-Null
  foreach ($r in $topZero) {
    $out.Add('| ' + $r.File.Replace('|','\|') + ' | ' + $r.MdLinks + ' | ' + $r.HtmlLinks + ' | ' + $r.RefLinks + ' |') | Out-Null
  }

  [IO.File]::WriteAllText($debugPath, ($out.ToArray() -join "`n"), [Text.UTF8Encoding]::new($false))
  Write-Host ('OK: ' + $debugPath)
}

git status --porcelain