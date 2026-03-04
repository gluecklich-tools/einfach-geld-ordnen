#requires -Version 7.0
param(
  [int]$MaxCommits = 50
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ConfirmPreference="None"
$ProgressPreference="SilentlyContinue"

function Write_Utf8NoBomLF([string]$Path,[string]$Text){
  $Text = $Text.Replace("`r`n","`n").Replace("`r","`n")
  [System.IO.File]::WriteAllText($Path,$Text,[System.Text.UTF8Encoding]::new($false))
}
function Read_Utf8Raw([string]$Path){ Get-Content -LiteralPath $Path -Raw -Encoding UTF8 }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$GovDir = Join-Path $ProjectRoot "_INTERN\governance"
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"
$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"

if(!(Test-Path -LiteralPath $GovDir -PathType Container)){ throw "Missing GOV dir: $GovDir" }
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){ throw "Missing marker: $marker" }

$sinceIso = (Get-Content -LiteralPath $marker -Raw -Encoding UTF8).Trim()
if([string]::IsNullOrWhiteSpace($sinceIso)){ $sinceIso = "1970-01-01T00:00:00Z" }

# Collect commit summaries since marker
$log = git log --since=$sinceIso --max-count=$MaxCommits --pretty=format:"%h|%cI|%s" 2>$null
$items = @()
if(-not [string]::IsNullOrWhiteSpace($log)){
  $items = $log -split "`n"
}

# Build delta text
$ts = [DateTimeOffset]::Now.ToString("yyyy-MM-dd HH:mm:ss zzz")
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## AUTOLOG " + $ts)
[void]$sb.AppendLine("- MarkerSince: " + $sinceIso)
[void]$sb.AppendLine("- Repo: " + $RepoRoot)
[void]$sb.AppendLine("")
[void]$sb.AppendLine("### Commits")
if($items.Count -eq 0){
  [void]$sb.AppendLine("- (none since marker)")
} else {
  foreach($it in $items){
    [void]$sb.AppendLine("- " + $it)
  }
}

# Also include last changed files (last commit)
$last = git rev-parse HEAD 2>$null
if(-not [string]::IsNullOrWhiteSpace($last)){
  $files = git diff-tree --no-commit-id --name-only -r $last 2>$null
  [void]$sb.AppendLine("")
  [void]$sb.AppendLine("### Files in HEAD")
  if([string]::IsNullOrWhiteSpace($files)){
    [void]$sb.AppendLine("- (none)")
  } else {
    foreach($f in ($files -split "`n")){ if($f.Trim().Length -gt 0){ [void]$sb.AppendLine("- " + $f.Trim()) } }
  }
}

# Upsert into INTERN docs (append-only, deterministic)
$targets = @(
  Join-Path $GovDir "LEARNINGS_INTERNAL.md",
  Join-Path $GovDir "QA_GATE_INTERNAL.md",
  Join-Path $GovDir "GOVERNANCE_INTERNAL.md"
)

foreach($p in $targets){
  if(Test-Path -LiteralPath $p -PathType Leaf){
    $old = Read_Utf8Raw $p
    $new = $old + $sb.ToString()
    Write_Utf8NoBomLF $p $new
  }
}

"PASS: brain-docs-upsert"