#requires -Version 7.0
param(
  [string]$RepoRoot = (Get-Location).Path
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
function Build-MojibakeMarkerSet {
  $rep = [char]0xFFFD
  $pat_Ae  = -join @([char]0x00C3,[char]0x00A4)
  $pat_Oe  = -join @([char]0x00C3,[char]0x00B6)
  $pat_Ue  = -join @([char]0x00C3,[char]0x00BC)
  $pat_ss  = -join @([char]0x00C3,[char]0x009F)
  $pat_en  = -join @([char]0x00E2,[char]0x20AC,[char]0x2013)
  $pat_em  = -join @([char]0x00E2,[char]0x20AC,[char]0x2014)
  $pat_ldq = -join @([char]0x00E2,[char]0x20AC,[char]0x201C)
  $pat_rdq = -join @([char]0x00E2,[char]0x20AC,[char]0x201D)
  return @{ Rep=$rep; Markers=@($rep,$pat_Ae,$pat_Oe,$pat_Ue,$pat_ss,$pat_en,$pat_em,$pat_ldq,$pat_rdq) }
}

# BEGIN_MOJIBAKE_MARKERS_ASCII_ONLY
# ASCII-only: build mojibake marker strings at runtime (no embedded replacement char).
$mjb = Build-MojibakeMarkerSet
$rep = $mjb.Rep
$markers = $mjb.Markers
# END_MOJIBAKE_MARKERS_ASCII_ONLY
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

# Mojibake markers from Build-MojibakeMarkerSet: use $markers

$hits = New-Object System.Collections.Generic.List[string]

foreach($abs in $files){
  $text = [IO.File]::ReadAllText($abs, $utf8)
  foreach($pat in $markers){
    if($text.Contains($pat)){
      $ms = Select-String -InputObject $text -Pattern ([regex]::Escape($pat)) -AllMatches
      foreach($m in $ms){
        $hits.Add(("{0}:{1}: {2}" -f @((RelPath $abs), $m.LineNumber, $pat))) | Out-Null
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
