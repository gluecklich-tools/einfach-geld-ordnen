param(
  [switch]$Apply,
  [string]$BaseUrlPath = "/einfach-geld-ordnen"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Get-Utf8TextNoBom {
  param([byte[]]$Bytes)
  # Detect UTF-8 BOM EF BB BF
  if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
    $Bytes = $Bytes[3..($Bytes.Length-1)]
  }
  return [System.Text.Encoding]::UTF8.GetString($Bytes)
}
function Write-Utf8NoBom {
  param([string]$Path, [string]$Text)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}
function Get-Frontmatter {
  param([string]$Text)
  # Must start at line 1 with ASCII ---
  if (-not $Text.StartsWith("---`n") -and -not $Text.StartsWith("---`r`n")) { return $null }
  $nl = "`n"
  $idx = $Text.IndexOf("`n---`n")
  if ($idx -lt 0) { $idx = $Text.IndexOf("`r`n---`r`n") }
  if ($idx -lt 0) { return $null }
  # Find end marker: second --- on its own line
  # We already found pattern with surrounding newlines; compute end of frontmatter block
  if ($Text.Contains("`n---`n")) {
    $endPos = $Text.IndexOf("`n---`n", 4) # after first line
    if ($endPos -lt 0) { return $null }
    $fm = $Text.Substring(0, $endPos + 5) # include "\n---\n"
    $rest = $Text.Substring($endPos + 5)
    return [pscustomobject]@{ Frontmatter = $fm; Body = $rest }
  } else {
    # CRLF path
    $endPos = $Text.IndexOf("`r`n---`r`n", 5)
    if ($endPos -lt 0) { return $null }
    $fm = $Text.Substring(0, $endPos + 8) # include "\r\n---\r\n"
    $rest = $Text.Substring($endPos + 8)
    return [pscustomobject]@{ Frontmatter = $fm; Body = $rest }
  }
}
function Get-PermalinkFromFrontmatter {
  param([string]$Frontmatter)
  # Very simple YAML line parse: permalink: /path/file.html
  $m = [regex]::Match($Frontmatter, "(?im)^[\t ]*permalink:[\t ]*([^\r\n#]+)")
  if ($m.Success) {
    $p = $m.Groups[1].Value.Trim()
    # strip quotes if present
    if (($p.StartsWith('"') -and $p.EndsWith('"')) -or ($p.StartsWith("'") -and $p.EndsWith("'"))) {
      $p = $p.Substring(1, $p.Length-2)
    }
    return $p
  }
  return $null
}
function Normalize-InternalLink {
  param(
    [string]$Target,
    [hashtable]$PermalinkSet,
    [hashtable]$PermalinkByLoose
  )
  $t = $Target.Trim()
  # Ignore anchors-only, mailto, tel, http(s)
  if ($t -match '^(#|mailto:|tel:|https?://)') { return $null }
  # Strip Liquid baseurl if already there
  $t2 = $t -replace '^\{\{\s*site\.baseurl\s*\}\}', ''
  # Strip literal baseurl path if present
  if ($BaseUrlPath -and $t2.StartsWith($BaseUrlPath)) { $t2 = $t2.Substring($BaseUrlPath.Length) }
  # Remove query/fragment for matching
  $frag = ""
  if ($t2 -match '^(?<path>[^#\?]+)(?<tail>.*)$') {
    $tPath = $Matches['path']
    $frag = $Matches['tail']
  } else {
    $tPath = $t2
  }
  $tPath = $tPath.Trim()
  # Normalize trailing slash
  if ($tPath.EndsWith("/")) { $tPath = $tPath.TrimEnd("/") }
  # Convert .md -> .html if present
  if ($tPath.EndsWith(".md")) { $tPath = $tPath.Substring(0, $tPath.Length-3) + ".html" }
  # If missing leading slash, do not guess (could be relative)
  if (-not $tPath.StartsWith("/")) { return $null }
  # Direct match
  if ($PermalinkSet.ContainsKey($tPath)) {
    return "{{ site.baseurl }}$tPath$frag"
  }
  # Loose match: allow /seiten/name or /pillar/name (without .html)
  if (-not $tPath.EndsWith(".html")) {
    $cand = "$tPath.html"
    if ($PermalinkSet.ContainsKey($cand)) {
      return "{{ site.baseurl }}$cand$frag"
    }
  }
  # Loose key map (e.g., by filename)
  if ($PermalinkByLoose.ContainsKey($tPath)) {
    $p = $PermalinkByLoose[$tPath]
    return "{{ site.baseurl }}$p$frag"
  }
  return $null
}
function Replace-MarkdownLinks {
  param(
    [string]$Text,
    [hashtable]$PermalinkSet,
    [hashtable]$PermalinkByLoose,
    [ref]$Touched,
    [ref]$UnknownLinks
  )
  # Replace markdown links: [text](target)
  $pattern = '\[(?<label>[^\]]+)\]\((?<target>[^)]+)\)'
  $out = [regex]::Replace($Text, $pattern, {
    param($m)
    $label = $m.Groups["label"].Value
    $target = $m.Groups["target"].Value
    $new = Normalize-InternalLink -Target $target -PermalinkSet $PermalinkSet -PermalinkByLoose $PermalinkByLoose
    if ($null -ne $new) {
      if ($new -ne $target) { $Touched.Value = $true }
      return "[$label]($new)"
    } else {
      # If it looks like an internal absolute link but no match, log it
      $t = $target.Trim()
      if ($t -match '^(/seiten/|/pillar/|.html)' -and $t -notmatch '^(https?://)') {
        $UnknownLinks.Value.Add($t) | Out-Null
      }
      return $m.Value
    }
  })
  return $out
}
function Ensure-IncludeFooter {
  param([string]$Text, [ref]$Touched)
  $inc = "{% include no_sackgasse_footer.html %}"
  if ($Text -notmatch [regex]::Escape($inc)) {
    $Touched.Value = $true
    if (-not $Text.EndsWith("`n")) { $Text += "`n" }
    $Text += "`n$inc`n"
  }
  return $Text
}
function Normalize-WeiterHeading {
  param([string]$Text, [ref]$Touched)
  $variants = @(
    '##\s*3\s*naechste\s*schritte\s*',
    '##\s*3\s*nächste\s*schritte\s*',
    '##\s*naechste\s*schritte\s*',
    '##\s*nächste\s*schritte\s*',
    '##\s*weiter\s*'
  )
  foreach ($v in $variants) {
    $rx = [regex]::new("(?im)^$v$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($rx.IsMatch($Text)) {
      $Text2 = $rx.Replace($Text, "## Weiter")
      if ($Text2 -ne $Text) { $Touched.Value = $true; $Text = $Text2 }
    }
  }
  return $Text
}
function Audit-WeiterSection {
  param([string]$Body)
  $result = [pscustomobject]@{
    HasWeiter = $false
    WeiterInternalLinkCount = 0
  }
  $m = [regex]::Match($Body, '(?is)\n##\s+Weiter\s*\n(?<sec>.*?)(\n##\s+|\z)')
  if ($m.Success) {
    $result.HasWeiter = $true
    $sec = $m.Groups["sec"].Value
    # Count internal links in section: markdown links whose target starts with {{ site.baseurl }} or /...
    $links = [regex]::Matches($sec, '\[[^\]]+\]\((?<t>[^)]+)\)')
    $cnt = 0
    foreach ($lm in $links) {
      $t = $lm.Groups["t"].Value.Trim()
      if ($t -match '^\{\{\s*site\.baseurl\s*\}\}/' -or $t -match '^/([a-z0-9_\-]+/)?') {
        # exclude obvious external
        if ($t -notmatch '^https?://') { $cnt++ }
      }
    }
    $result.WeiterInternalLinkCount = $cnt
  }
  return $result
}
# Collect files
$files = @()
$files += Get-ChildItem -LiteralPath (Join-Path (Get-Location) "seiten") -Filter "*.md" -File -ErrorAction SilentlyContinue
$files += Get-ChildItem -LiteralPath (Join-Path (Get-Location) "pillar") -Filter "*.md" -File -ErrorAction SilentlyContinue
if ($files.Count -eq 0) { throw "No md files found in seiten/ or pillar/ from current location." }
# Build permalink index
$permalinkSet = @{}
$permalinkByLoose = @{}
foreach ($f in $files) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $text  = Get-Utf8TextNoBom -Bytes $bytes
  $fmObj = Get-Frontmatter -Text $text
  if ($null -eq $fmObj) { continue }
  $p = Get-PermalinkFromFrontmatter -Frontmatter $fmObj.Frontmatter
  if ([string]::IsNullOrWhiteSpace($p)) { continue }
  $p = $p.Trim()
  if (-not $permalinkSet.ContainsKey($p)) { $permalinkSet[$p] = $true }
  # loose keys
  $loose1 = $p
  if ($loose1.EndsWith(".html")) { $loose2 = $loose1.Substring(0, $loose1.Length-5) } else { $loose2 = $loose1 }
  if (-not $permalinkByLoose.ContainsKey($loose2)) { $permalinkByLoose[$loose2] = $p }
  # also map /seiten/name.html -> /seiten/name.html (rare)
  if ($loose2.EndsWith("/")) {
    $loose3 = $loose2.TrimEnd("/")
    if (-not $permalinkByLoose.ContainsKey($loose3)) { $permalinkByLoose[$loose3] = $p }
  }
}
# Run
$reportLines = New-Object System.Collections.Generic.List[string]
$unknownAll  = New-Object System.Collections.Generic.List[string]
$reportLines.Add("MVP-02 batch run: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
$reportLines.Add("Apply mode: " + ($Apply.IsPresent))
$reportLines.Add("Files: " + $files.Count)
$reportLines.Add("Permalinks indexed: " + $permalinkSet.Count)
$reportLines.Add("")
$changed = 0
foreach ($f in $files | Sort-Object FullName) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $orig  = Get-Utf8TextNoBom -Bytes $bytes
  $fmObj = Get-Frontmatter -Text $orig
  if ($null -eq $fmObj) {
    $reportLines.Add("WARN no frontmatter: " + $f.FullName)
    continue
  }
  $touched = $false
  $unknown = New-Object System.Collections.Generic.List[string]
  $body = $fmObj.Body
  $body = Normalize-WeiterHeading -Text $body -Touched ([ref]$touched)
  $body = Replace-MarkdownLinks -Text $body -PermalinkSet $permalinkSet -PermalinkByLoose $permalinkByLoose -Touched ([ref]$touched) -UnknownLinks ([ref]$unknown)
  $body = Ensure-IncludeFooter -Text $body -Touched ([ref]$touched)
  $newText = $fmObj.Frontmatter + $body
  # Audit Weiter
  $audit = Audit-WeiterSection -Body $body
  if (-not $audit.HasWeiter) {
    $reportLines.Add("FAIL missing ## Weiter: " + $f.FullName)
  } elseif ($audit.WeiterInternalLinkCount -ne 3) {
    $reportLines.Add("FAIL ## Weiter links != 3 (found " + $audit.WeiterInternalLinkCount + "): " + $f.FullName)
  }
  if ($unknown.Count -gt 0) {
    $uniq = $unknown | Sort-Object -Unique
    foreach ($u in $uniq) { $unknownAll.Add(($f.FullName + " :: " + $u)) | Out-Null }
  }
  if ($touched -and $Apply) {
    Write-Utf8NoBom -Path $f.FullName -Text $newText
    $changed++
  }
}
$reportLines.Add("")
$reportLines.Add("Changed files (written): " + $changed)
if ($unknownAll.Count -gt 0) {
  $reportLines.Add("")
  $reportLines.Add("Unknown internal link targets (no permalink match):")
  foreach ($x in ($unknownAll | Sort-Object -Unique)) { $reportLines.Add("  " + $x) }
}
$reportPath = Join-Path (Get-Location) "tools/_mvp02_report.txt"
Write-Utf8NoBom -Path $reportPath -Text ($reportLines -join "`n")
"OK: report written to tools/_mvp02_report.txt"
if (-not $Apply) { "NOTE: Dry-run only. Re-run with -Apply to write changes." }