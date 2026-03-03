#requires -Version 7.0
param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

# Resolve repo root
$repo = $null
try {
  $t = (git rev-parse --show-toplevel 2>$null)
  if($t){ $repo = (Resolve-Path -LiteralPath $t).Path }
} catch {}
if(-not $repo){ $repo = (Resolve-Path -LiteralPath $RepoRoot).Path }

# Scope: content files only
$dirs = @("seiten","pillar","rechner","downloads")
$files = New-Object System.Collections.Generic.List[string]

foreach($d in $dirs){
  $p = Join-Path $repo $d
  if(Test-Path -LiteralPath $p -PathType Container){
    Get-ChildItem -LiteralPath $p -Recurse -File -Include *.md,*.html | ForEach-Object { $files.Add($_.FullName) | Out-Null }
  }
}
# Root index files (if present)
foreach($f in @("index.md","index.html")){
  $p = Join-Path $repo $f
  if(Test-Path -LiteralPath $p -PathType Leaf){ $files.Add((Resolve-Path -LiteralPath $p).Path) | Out-Null }
}

$files = $files | Sort-Object -Unique

function RelPath([string]$abs){
  $r = $abs.Substring($repo.Length).TrimStart('\','/')
  return ($r -replace '\\','/')
}

# Mojibake markers (conservative)
$patterns = @(
  "ÔÇô",   # UTF8-as-ANSI dash
  "├╝",    # typical box-drawing mojibake for ü
  "├ñ",    # typical box-drawing mojibake for ä
  "├£",    # Ü
  "Ã",     # UTF8-as-ANSI prefix (ä/ö/ü etc.)
  "�"      # replacement char
)

$hits = New-Object System.Collections.Generic.List[string]

foreach($abs in $files){
  $text = [IO.File]::ReadAllText($abs, $utf8)
  foreach($pat in $patterns){
    if($text.Contains($pat)){
      # collect a few line-level contexts
      $ms = Select-String -InputObject $text -Pattern [regex]::Escape($pat) -AllMatches
      foreach($m in $ms){
        $hits.Add(("{0}:{1}: {2}" -f (RelPath $abs), $m.LineNumber, $pat)) | Out-Null
        if($hits.Count -ge 200){ break }
      }
    }
    if($hits.Count -ge 200){ break }
  }
  if($hits.Count -ge 200){ break }
}

if($hits.Count -gt 0){
  "=== MOJIBAKE GATE FAIL ==="
  $hits | Select-Object -First 200
  Fail ("MOJIBAKE markers found: {0} (showing up to 200). Fix encoding/content." -f $hits.Count)
}

"PASS: gate-no-mojibake (no mojibake markers)"