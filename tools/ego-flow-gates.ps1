# EGO_SSOT_GUARD_V1
# Optional: SSOT guard (only if EGO_INTERNAL_DIR is set and ssot-guard exists)
$internalRoot = $env:EGO_INTERNAL_DIR
if ($internalRoot) {
  $guard = Join-Path $internalRoot ('tools' + [char]92 + 'ssot-guard.ps1')
  if (Test-Path -LiteralPath $guard) { & $guard -RequireCleanRepo }
}

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Test-Path ".\_config.yml")) { throw "Run in repo root (missing _config.yml)." }

# Only scan: ./index.md, ./seiten/**/*.md, ./pillar/**/*.md
# Hard exclude: _site, _local, _audit (work/backup folders)
$mdFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]

if (Test-Path ".\index.md") {
  $mdFiles.Add((Get-Item ".\index.md")) | Out-Null
}

if (Test-Path ".\seiten") {
  Get-ChildItem -Path ".\seiten" -Recurse -File -Filter "*.md" | ForEach-Object { $mdFiles.Add($_) | Out-Null }
}

if (Test-Path ".\pillar") {
  Get-ChildItem -Path ".\pillar" -Recurse -File -Filter "*.md" | ForEach-Object { $mdFiles.Add($_) | Out-Null }
}

$rxExcludePath = '(?i)\\_(site|local|audit)\\'

$scanFiles = $mdFiles | Where-Object { $_.FullName -notmatch $rxExcludePath }

$rxWeiterHead = '(?im)^\s*##\s*Weiter\s*$'
$rxHeadingAny = '(?m)^\s*#'
$rxMdLink     = '\[[^\]]+\]\(([^)]+)\)'
$rxInclude    = '\{\%\s*include\s+no_sackgasse_footer\.html\s*\%\}'

function Is-CountedLink([string]$href) {
  if ([string]::IsNullOrWhiteSpace($href)) { return $false }
  $h = $href.Trim().Trim("'").Trim('"')
  $sp = $h.IndexOf(" ")
  if ($sp -gt 0) { $h = $h.Substring(0, $sp).Trim() }
  if ($h.StartsWith("#")) { return $false }
  if ($h -match "^(?i)(https?://|mailto:|tel:|ftp://)"){ return $false }
  return $true
}

$failWeiter = New-Object System.Collections.Generic.List[object]
$failFooter = New-Object System.Collections.Generic.List[object]

foreach ($f in $scanFiles) {
  $text = [System.IO.File]::ReadAllText($f.FullName)

  # Footer include gate
  if (-not [regex]::IsMatch($text, $rxInclude)) {
    $failFooter.Add([pscustomobject]@{ File=$f.FullName; Problem="Missing no_sackgasse_footer include" }) | Out-Null
  }

  # Weiter gate
  $lines = $text -split "`r?`n", 0

  $start = -1
  for ($i=0; $i -lt $lines.Count; $i++) {
    if ([regex]::IsMatch($lines[$i], $rxWeiterHead)) { $start = $i + 1; break }
  }

  if ($start -lt 0) {
    $failWeiter.Add([pscustomobject]@{ File=$f.FullName; Problem="Missing ## Weiter"; LinkCount=0; Links="" }) | Out-Null
    continue
  }

  $end = $lines.Count
  for ($j=$start; $j -lt $lines.Count; $j++) {
    if ([regex]::IsMatch($lines[$j], $rxHeadingAny)) { $end = $j; break }
  }

  $block = ($lines[$start..($end-1)] -join "`n")
  $ms = [regex]::Matches($block, $rxMdLink)

  $links = New-Object System.Collections.Generic.List[string]
  foreach ($m in $ms) {
    $href = $m.Groups[1].Value
    if (Is-CountedLink $href) {
      $h = $href.Trim().Trim("'").Trim('"')
      $sp = $h.IndexOf(" ")
      if ($sp -gt 0) { $h = $h.Substring(0, $sp).Trim() }
      $links.Add($h) | Out-Null
    }
  }

  if (@($links).Count -ne 3) {
    $failWeiter.Add([pscustomobject]@{
      File      = $f.FullName
      Problem   = "Weiter link count != 3"
      LinkCount = @($links).Count
      Links     = ($links -join " | ")
    }) | Out-Null
  }
}

if ($failWeiter.Count -gt 0 -or $failFooter.Count -gt 0) {
  if ($failWeiter.Count -gt 0) {
    "FAIL: Weiter-Block Gate (exactly 3 links)"
    $failWeiter | Sort-Object File | Format-Table -AutoSize
    ""
  }
  if ($failFooter.Count -gt 0) {
    "FAIL: Footer-Include Gate (no_sackgasse_footer.html)"
    $failFooter | Sort-Object File | Format-Table -AutoSize
    ""
  }
  exit 1
}

"PASS: Weiter-Block (3 links) + Footer-Include"

# EGO_HOOK_WEITER_GATE_V1
try {
  $wg = Join-Path $PSScriptRoot 'weiter-gate.ps1'
  if(Test-Path -LiteralPath $wg){
    Write-Host 'GATE: weiter-gate' -ForegroundColor Cyan
    & pwsh -NoProfile -File $wg
  }
} catch {
  throw
}
