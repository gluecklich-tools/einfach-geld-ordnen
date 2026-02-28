param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function AsString([object]$v){
  if($null -eq $v){ return '' }
  return [string]$v
}

function Fail([string]$m){
  Write-Error ("STOP: " + $m)
  exit 1
}

function GateError([string]$m){
  Write-Error ("GATE_ERROR: " + $m)
  exit 2
}

Set-Location -LiteralPath $RepoRoot
if(!(Test-Path -LiteralPath (Join-Path $RepoRoot '.git'))){ GateError "not a git repo root: $RepoRoot" }

$files = @(git ls-files)
if(@($files).Count -eq 0){ Fail "no tracked files found" }

$skipExt = @('.png','.jpg','.jpeg','.gif','.webp','.ico','.pdf','.zip','.7z','.exe','.dll','.pdb')
function IsSkip([string]$p){
  $e = [IO.Path]::GetExtension($p).ToLowerInvariant()
  return $skipExt -contains $e
}

$patterns = @(
  @{ Name = 'ABS_WIN_USER_PATH';   Rx = '(?i)[A-Z]:\\Users\\[^\\]+\\' },
  @{ Name = 'ABS_WIN_DOCSETTINGS'; Rx = '(?i)[A-Z]:\\Dokumente und Einstellungen\\[^\\]+\\' },
  @{ Name = 'ABS_MAC_USERS';       Rx = '(?i)/Users/USER/]+/' },
  @{ Name = 'ABS_LINUX_HOME';      Rx = '(?i)/home/USER/]+/' },
  @{ Name = 'INTERN_TOKEN';        Rx = '(?i)\b_INTERN\b' },
  @{ Name = 'INTERNALTOOLSROOT_HARDCODE'; Rx = '(?i)InternalToolsRoot\s*=\s*[''"][A-Z]:\\Users\\' },
  @{ Name = 'EMAIL'; Rx = '(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b' },
  @{ Name = 'PHONE'; Rx = '(?x)(?:\+49|0)\s*(?:\(?\d{2,5}\)?)[\s\/-]*\d{3,}[\s\/-]*\d{3,}' }
)

$hits = New-Object System.Collections.Generic.List[string]

foreach($rel in $files){
  if(IsSkip $rel){ continue }
  $full = Join-Path $RepoRoot $rel
  if(!(Test-Path -LiteralPath $full)){ continue }

  $txt = ''
  try{
    $txt = Get-Content -LiteralPath $full -Encoding UTF8 -Raw -ErrorAction Stop
  } catch {
    continue
  }

  $txt = AsString $txt

  foreach($p in $patterns){
    $rx = AsString $p.Rx
    if([string]::IsNullOrWhiteSpace($rx)){ continue }
    $m = [regex]::Match((AsString $txt), $rx)
    if($m.Success){
      $prefix = $txt.Substring(0, $m.Index)
      $line = 1 + ([regex]::Matches($prefix, "`n")).Count
      $hits.Add(("{0} | {1}:{2}" -f $p.Name,$rel,$line))
    }
  }
}

if($hits.Count -gt 0){
  "=== PUBLIC LEAK GATE FAIL ==="
  $hits | Sort-Object | Get-Unique | ForEach-Object { $_ }
  Fail ("public leak patterns found: " + $hits.Count)
}

"OK: gate-public-leaks PASS"
exit 0