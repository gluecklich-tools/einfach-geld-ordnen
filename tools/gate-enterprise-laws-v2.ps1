[CmdletBinding()]
param([Parameter(Mandatory)][string]$RepoRoot)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
if([string]::IsNullOrWhiteSpace($RepoRoot)){ throw 'STOP: RepoRoot empty' }
if(!(Test-Path -LiteralPath $RepoRoot)){ throw ('STOP: RepoRoot not found: '+$RepoRoot) }

$viol = New-Object System.Collections.Generic.List[string]

$items = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Force | Where-Object {
  $_.FullName -notmatch '*\.git\*' -and
(($_.FullName -replace '\','/') -notlike '*/_local/*') -and
  $_.Extension -in @('.ps1','.psm1','.psd1','.yml','.yaml','.md','.txt')
}

foreach($f in $items){
  $t = [IO.File]::ReadAllText($f.FullName,[Text.UTF8Encoding]::new($false))

  # NO_PLACEHOLDERS
  if($t -match '<[A-Za-z0-9_ \-]+>' -or $t -match 'EXAKTER_[A-Za-z0-9_]+' -or $t -match '\bFILL_ME\b' -or $t -match '\bINSERT_HERE\b'){
    $viol.Add(('NO_PLACEHOLDERS: '+$f.FullName))
  }

  # NO_MARKDOWN_FENCES in PS files
  if($f.Extension -in @('.ps1','.psm1','.psd1') -and $t -match '`'){
    $viol.Add(('NO_MARKDOWN_FENCES_IN_PS: '+$f.FullName))
  }

  # NO_HARDPATHS in automation files
  if(($t -match '(?i)\bC:\\\\Users\\\\' -or $t -match '(?i)\b/Users/') -and ((($f.FullName -replace '\','/') -like '*/tools/*') -or $f.FullName -match '\\\.githooks\\' -or $f.FullName -match '\\\.github\\workflows\\')){
    $viol.Add(('NO_HARDPATHS_IN_AUTOMATION: '+$f.FullName))
  }

  # NO_BIG_INLINE_COMMAND (stable heuristic: any -Command line > 220 chars OR contains multiple semicolons)
  foreach($ln in ($t -split '?
')){
    if($ln -match '(?i)\b(pwsh|powershell)\b.*\s-\s*command\b'){
      if($ln.Length -gt 220){ $viol.Add(('NO_BIG_INLINE_COMMAND(longline): '+$f.FullName)); break }
      if(($ln -split ';' ).Count -gt 6){ $viol.Add(('NO_BIG_INLINE_COMMAND(multicmd): '+$f.FullName)); break }
    }
  }

  # NO_INTERACTIVE_PROMPTS in tools
  if(((($f.FullName -replace '\','/') -like '*/tools/*')) -and ($t -match '(?i)\bRead-Host\b')){
    $viol.Add(('NO_INTERACTIVE_PROMPTS(Read-Host): '+$f.FullName))
  }
}

if($viol.Count -gt 0){
  'GATE_ENTERPRISE_LAWS_V2: FAIL'
  $viol | Sort-Object | Get-Unique | ForEach-Object { ' - '+$_ }
  throw ('STOP: GATE_ENTERPRISE_LAWS_V2 failed ('+$viol.Count+')')
}
'GATE_ENTERPRISE_LAWS_V2: PASS'
