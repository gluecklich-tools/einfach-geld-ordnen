# ALLOW_REGEX_PATCH (temporary; must be removed when refactored to literal/AST patching)
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,$enc) }
function WriteUtf8([string]$p,[string]$t){ [IO.File]::WriteAllText($p,$t,$enc) }

# RepoRoot robust: tools\..
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
if([string]::IsNullOrWhiteSpace($repo) -or !(Test-Path -LiteralPath $repo)){ throw "STOP: repo root not found via PSScriptRoot" }
Set-Location -LiteralPath $repo
$ts = "{0}_{1}" -f @((Get-Date).ToString("yyyyMMdd_HHmmss_fff"), (Get-Random -Minimum 1000 -Maximum 9999))
$bk=Join-Path $repo ("_local\patch_backups\policy_blocks_minimal_{0}" -f $ts)
New-Item -ItemType Directory -Path $bk -Force | Out-Null

function BackupFile([string]$p){
  if(!(Test-Path -LiteralPath $p)){ return }
  $rel=$p.Substring($repo.Length).TrimStart("\")
  $dst=Join-Path $bk ($rel -replace '[\\/:*?""<>|]','_')
  Copy-Item -LiteralPath $p -Destination $dst -Force
}

# 1) Include spelling fix + source of blocks
$inc=Join-Path $repo "_includes\disclaimer_finanzinfo.html"
if(!(Test-Path -LiteralPath $inc)){ throw "STOP: missing include: $inc" }
BackupFile $inc
$t=ReadUtf8 $inc
$t2=$t -replace "Aktualitaet","Aktualität"
if($t2 -ne $t){ WriteUtf8 $inc $t2; "PATCHED: _includes/disclaimer_finanzinfo.html" } else { "NOCHANGE: include" }

# 2) Gate injection in layouts/includes
$needle="{% include disclaimer_finanzinfo.html %}"
$scan=@()
$scan += Get-ChildItem -LiteralPath (Join-Path $repo "_layouts") -File -Recurse -ErrorAction SilentlyContinue
$scan += Get-ChildItem -LiteralPath (Join-Path $repo "_includes") -File -Recurse -ErrorAction SilentlyContinue
$_ -and (($_.FullName -replace '\','/') -notlike '*/_local/patch_backups/*')
$hitFiles = Select-String -Path $scan.FullName -SimpleMatch -Pattern $needle -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -Unique
if(!$hitFiles){ throw "STOP: include injection not found: $needle" }
foreach($f in $hitFiles){
  BackupFile $f
  $x=ReadUtf8 $f
  if($x -match '(?s)\{%\s*if\s+page\.policy_blocks\s*==\s*"show"\s*%\}.*?\{%\s*include\s+disclaimer_finanzinfo\.html\s*%\}.*?\{%\s*endif\s*%\}' ){
    "SKIP gated: " + ($f.Substring($repo.Length).TrimStart("\"))
    continue
  }
  $x2=[regex]::Replace(
    $x,
    '(?m)^(?<indent>\s*)\{%\s*include\s+disclaimer_finanzinfo\.html\s*%\}\s*$',
    '${indent}{% if page.policy_blocks == "show" %}' + "`r`n" +
    '${indent}{% include disclaimer_finanzinfo.html %}' + "`r`n" +
    '${indent}{% endif %}',
    1
  )
  if($x2 -eq $x){ throw ("STOP: gating patch failed in " + $f) }
  WriteUtf8 $f $x2
  "PATCHED GATE: " + ($f.Substring($repo.Length).TrimStart("\"))
}

# 3) Minimal frontmatter: show only on selected pages
function EnsureFrontmatterShow([string]$p){
  if(!(Test-Path -LiteralPath $p)){ return $false }
  BackupFile $p
  $txt=ReadUtf8 $p
  if($txt -notmatch '(?s)\A---\s*.*?\s*---\s*'){ throw ("STOP: no frontmatter: " + $p) }
  if($txt -match '(?m)^\s*policy_blocks:\s*'){ return $false }
  $m=[regex]::Match($txt,'(?s)\A---\s*(.*?)\s*---\s*')
  $body=$m.Groups[1].Value
  $lines=$body -split "`r?`n"
  $insertAt=0
  for($i=0;$i -lt $lines.Count;$i++){
    if($lines[$i] -match '^\s*permalink:\s*'){ $insertAt=$i+1; break }
    if($lines[$i] -match '^\s*title:\s*'){ $insertAt=$i+1 }
  }
  $out=@()
  for($i=0;$i -lt $lines.Count;$i++){
    $out += $lines[$i]
    if($i -eq ($insertAt-1)){ $out += "policy_blocks: show" }
  }
  if($insertAt -eq 0){ $out = @($lines[0],"policy_blocks: show") + ($lines | Select-Object -Skip 1) }
  $newFm="---`r`n" + (($out -join "`r`n").TrimEnd()) + "`r`n---"
  $rest=$txt.Substring($m.Length)
  WriteUtf8 $p ($newFm + $rest)
  return $true
}

$targets=@()
$targets += (Join-Path $repo "index.md")
$targets += (Get-ChildItem -LiteralPath (Join-Path $repo "seiten") -File -Filter "download*.md" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
$targets += @((Join-Path $repo "seiten\impressum.md"),(Join-Path $repo "seiten\datenschutz.md")) | Where-Object { Test-Path -LiteralPath $_ }
$targets=$targets | Select-Object -Unique
$cnt=0
foreach($tgt in $targets){ if(EnsureFrontmatterShow $tgt){ $cnt++; "FRONTMATTER show: " + ($tgt.Substring($repo.Length).TrimStart("\")) } }
"FRONTMATTER_CHANGED_COUNT=$cnt"
"BACKUP_DIR=$bk"
