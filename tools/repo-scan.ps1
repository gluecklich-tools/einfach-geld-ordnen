# EGO_SSOT_GUARD_V1
# Optional: SSOT guard (only if EGO_INTERNAL_DIR is set and ssot-guard exists)
$internalRoot = $env:EGO_INTERNAL_DIR
if ($internalRoot) {
  $guard = Join-Path $internalRoot ('tools' + [char]92 + 'ssot-guard.ps1')
  if (Test-Path -LiteralPath $guard) { & $guard -RequireCleanRepo }
}

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-RepoRoot {
  $here = $PSScriptRoot
  if (-not $here) { return (Get-Location).Path }
  return (Split-Path -Parent $here)
}

function Count-BytePattern([byte[]]$data, [byte[]]$pat) {
  if (-not $data -or -not $pat -or $pat.Length -eq 0 -or $data.Length -lt $pat.Length) { return 0 }
  $count = 0
  for ($i = 0; $i -le ($data.Length - $pat.Length); $i++) {
    $ok = $true
    for ($j = 0; $j -lt $pat.Length; $j++) {
      if ($data[$i+$j] -ne $pat[$j]) { $ok = $false; break }
    }
    if ($ok) { $count++ }
  }
  return $count
}

function Is-AllAsciiDash([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return $false }
  foreach ($ch in $s.ToCharArray()) { if ($ch -ne '-') { return $false } }
  return $true
}

$repoRoot = Get-RepoRoot

$tracked = & git -C $repoRoot ls-files 2>$null
if (-not $tracked) { throw "git ls-files returned nothing. Are you in a git repo?" }

$extOk = @(".md",".html",".yml",".yaml",".js",".css")

$files = foreach ($rel in @($tracked)) {
  $ext = [System.IO.Path]::GetExtension($rel)
  if ($extOk -contains $ext) {
    $full = Join-Path $repoRoot $rel
    if (Test-Path -LiteralPath $full) { $full }
  }
}

# Blocker 1: relative_url (text regex is ASCII-only -> safe)
$relativeUrlHits = 0
$detailsRelative = New-Object System.Collections.Generic.List[string]

# Blocker 2: mojibake patterns (scan as BYTES, patterns expressed as HEX -> ASCII-only)
$mojibakeHits = 0
$detailsMoji  = New-Object System.Collections.Generic.List[string]

# Common mojibake byte sequences (UTF-8 bytes for the mojibake text tokens):
# "Ã¤" C3 83 C2 A4
# "Ã¶" C3 83 C2 B6
# "Ã¼" C3 83 C2 BC
# "ÃŸ" C3 83 C5 B8
# "Ã„" C3 83 C2 84
# "Ã–" C3 83 C2 96
# "Ãœ" C3 83 C5 92
# "â€“" E2 80 93 rendered mojibake token is often "â€“" => bytes C3 A2 E2 82 AC E2 80 9C (varies)
# Instead: detect "Ã" and "â" families via their UTF-8 bytes:
# "Ã" => C3 83
# "Â" => C3 82
# "â" => C3 A2
$pat_A_uml = [byte[]](0xC3,0x83) # "Ã"
$pat_Ahat  = [byte[]](0xC3,0x82) # "Â"
$pat_ahat  = [byte[]](0xC3,0xA2) # "â"

# Blocker 3: frontmatter delimiter must be exactly ASCII '---'
$typographyHitsFrontmatter = 0
$detailsFm = New-Object System.Collections.Generic.List[string]

foreach ($f in $files) {
  $bytes = $null
  try { $bytes = [System.IO.File]::ReadAllBytes($f) } catch { continue }
  if (-not $bytes) { continue }

  # relative_url hits
  $text = $null
  try { $text = [System.Text.Encoding]::UTF8.GetString($bytes) } catch { $text = $null }
  if ($text) {
    $rx = [regex]'\|\s*relative_url\b'
    $m = $rx.Matches($text)
    if ($m.Count -gt 0) {
      $relativeUrlHits += $m.Count
      $detailsRelative.Add(("{0} :: {1}" -f $f, $m.Count))
    }
  }

  # mojibake hits (byte patterns)
  $mh = 0
  $mh += (Count-BytePattern $bytes $pat_A_uml)
  $mh += (Count-BytePattern $bytes $pat_Ahat)
  $mh += (Count-BytePattern $bytes $pat_ahat)
  if ($mh -gt 0) {
    $mojibakeHits += $mh
    $detailsMoji.Add(("{0} :: {1}" -f $f, $mh))
  }

  # frontmatter delimiter check (first non-empty line; if it's '---' ok; if it's 3+ '-' also ok; else ignore)
  if ($text) {
    $lines = $text.Split("`n")
    $firstIdx = -1
    for ($i=0; $i -lt $lines.Count; $i++) {
      if (-not [string]::IsNullOrWhiteSpace($lines[$i])) { $firstIdx = $i; break }
    }
    if ($firstIdx -ge 0) {
      $first = $lines[$firstIdx].TrimEnd("`r").Trim()
      if ($first.Length -ge 3 -and (Is-AllAsciiDash $first)) {
        if ($first -ne "---") {
          $typographyHitsFrontmatter++
          $detailsFm.Add(("BAD_FM_DELIM_OPEN {0} :: '{1}'" -f $f, $first))
        } else {
          for ($j=$firstIdx+1; $j -lt $lines.Count; $j++) {
            $ln = $lines[$j].TrimEnd("`r").Trim()
            if ($ln -eq "---") { break }
            if ($ln.Length -ge 3 -and (Is-AllAsciiDash $ln) -and $ln -ne "---") {
              $typographyHitsFrontmatter++
              $detailsFm.Add(("BAD_FM_DELIM_CLOSE {0} :: '{1}'" -f $f, $ln))
              break
            }
          }
        }
      }
    }
  }
}

"=== REPO SCAN (BLOCKERS) ==="
"repo_root                   : $repoRoot"
"tracked_files_scanned       : {0}" -f ($files.Count)

""
"relative_url_hits           : {0}" -f $relativeUrlHits
if ($relativeUrlHits -gt 0) { $detailsRelative | Sort-Object }

""
"mojibake_hits               : {0}" -f $mojibakeHits
if ($mojibakeHits -gt 0) { $detailsMoji | Sort-Object }

""
"typography_hits_frontmatter : {0}" -f $typographyHitsFrontmatter
if ($typographyHitsFrontmatter -gt 0) { $detailsFm | Sort-Object }

""
if ($relativeUrlHits -eq 0 -and $mojibakeHits -eq 0 -and $typographyHitsFrontmatter -eq 0) {
  "RESULT: GREEN (all blockers = 0)"
  exit 0
} else {
  "RESULT: RED (blockers present)"
  exit 1
}