#requires -Version 7.0
param([string]$RepoRoot = (Get-Location).Path)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

# Ensure mojibake marker helper is available (P0)
$__mjbLib = Join-Path $PSScriptRoot "lib\mojibake-markers.ps1"
if(-not (Get-Command -Name Build-MojibakeMarkerSet -CommandType Function -ErrorAction SilentlyContinue)){
  if(Test-Path -LiteralPath $__mjbLib){ . $__mjbLib }
}
# BEGIN_MOJIBAKE_MARKERS_ASCII_ONLY
# ASCII-only: build mojibake marker strings at runtime (no embedded replacement char).
$mjb = Build-MojibakeMarkerSet
$rep = $mjb
$markers = $mjb
# END_MOJIBAKE_MARKERS_ASCII_ONLY
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

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

$enc = [Text.UTF8Encoding]::new($false)

function WriteUtf8NoBom([string]$p,[string]$s){
  [IO.File]::WriteAllText($p,$s,$enc)
}

# Scan roots
$roots = @(
  (Join-Path $RepoRoot "seiten"),
  (Join-Path $RepoRoot "pillar")
)

# Patterns (known bug classes)
$patterns = @(
  @{ Name="FRONTMATTER_GLUED_H1"; Regex="(?m)^---#"; },
  @{ Name="MOJIBAKE_BOX";       Regex="+"; },
  @{ Name="MOJIBAKE_UTF8";      Regex="U+FFFD|U+FFFD"; },
  @{ Name="MOJIBAKE_REPLCHAR";  Regex="?"; }
)

$hits = New-Object System.Collections.Generic.List[object]

foreach($r in $roots){
  if(!(Test-Path -LiteralPath $r)){ continue }
  Get-ChildItem -LiteralPath $r -Recurse -File -Include *.md,*.html | ForEach-Object {
    $path = $_.FullName
    $rel = (Resolve-Path -LiteralPath $path).Path.Substring($RepoRoot.Length).TrimStart('\','/')
    $text = [IO.File]::ReadAllText($path, $enc)

    foreach($p in $patterns){
      $m = [regex]::Matches($text, $p.Regex)
      if($m.Count -gt 0){
        $hits.Add([pscustomobject]@{
          File    = $rel
          Finding = $p.Name
          Count   = $m.Count
        })
      }
    }
  }
}

if($hits.Count -eq 0){
  "OK: gate-repo-sanity-scan: no findings (seiten/, pillar/)"
  exit 0
}

# Write report only when findings exist (reduce noise)
$reportsDir = Join-Path $RepoRoot "_local\_scratch\_reports"
New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = Join-Path $reportsDir ("repo_sanity_scan_{0}.md" -f $stamp)

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# Repo Sanity Scan Report")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("- Timestamp: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
[void]$sb.AppendLine("- Roots: seiten/, pillar/")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Summary")

$group = $hits | Group-Object Finding | Sort-Object Name
foreach($g in $group){
  $total = ($g.Group | Measure-Object Count -Sum).Sum
  [void]$sb.AppendLine(("- {0}: files={1}, totalMatches={2}" -f $g.Name, $g.Count, $total))
}

[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Details")
$hits | Sort-Object Finding, File | ForEach-Object {
  [void]$sb.AppendLine(("- {0} | {1} | count={2}" -f $_.Finding, $_.File, $_.Count))
}

WriteUtf8NoBom $reportPath $sb.ToString()

"FAIL: gate-repo-sanity-scan: findings present. Report: $reportPath"
exit 1