param(
  [Parameter(Mandatory=$true)][string]$File,
  [Parameter(Mandatory=$true)][string]$RR,
  [ValidateSet('plan','apply')][string]$Mode = 'plan',
  [string]$RepoRoot = ''
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

if([string]::IsNullOrWhiteSpace($RepoRoot)){
  $RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
}
if([string]::IsNullOrWhiteSpace($RepoRoot)){ throw 'STOP: repo root not found.' }
if(!(Test-Path -LiteralPath $RepoRoot)){ throw "STOP: repo root missing: $RepoRoot" }

. (Join-Path $RepoRoot 'tools\ego-rereview-lib.ps1')

$full = $File
if(!(Test-Path -LiteralPath $full)){ throw "STOP: missing file: $full" }

$rel = $full.Replace(($RepoRoot.TrimEnd('\') + '\'),'')
$txt = Read-Utf8NoBom $full
$lines = $txt -split "`n",0,'SimpleMatch'
$lines = $lines | ForEach-Object { $_.TrimEnd("`r") }

$parts = Split-Body $lines
$head = $parts.Head
$body = $parts.Body

# only SAFE auto fixes:
# 1) normalize visible umlauts in body (not in code fences, not in URLs of markdown links)
# 2) do not invent Weiter/footer/links automatically -> STOP if missing/wrong (manual)
$w = Find-WeiterBlock $body
if(!$w.Found){ throw "STOP: cannot auto-fix: Weiter missing (RR=$RR, FILE=$rel)" }
if($w.Links.Length -ne 3){ throw "STOP: cannot auto-fix: Weiter must have exactly 3 links (found=$($w.Links.Length))" }
if(!$w.HasFooter){ throw "STOP: cannot auto-fix: footer include missing inside Weiter block" }

$inFence = $false
$newBody = New-Object System.Collections.Generic.List[string]
for($i=0;$i -lt $body.Length;$i++){
  $ln = $body[$i]
  if($ln -match '^\s*```'){ $inFence = -not $inFence; [void]$newBody.Add($ln); continue }
  if($inFence){ [void]$newBody.Add($ln); continue }
  [void]$newBody.Add((Replace-VisibleTextOnly $ln))
}

$newLines = @()
if($head.Count -gt 0){ $newLines += $head }
$newLines += $newBody.ToArray()
$newText = ($newLines -join "`n")
$oldText = ($lines -join "`n")

if($newText -eq $oldText){
  "APPLY=NO_CHANGES"
  return
}

if($Mode -eq 'plan'){
  "PLAN=CHANGES_DETECTED"
  "FILE=" + $rel
  return
}

$ts = (Get-Date).ToString('yyyyMMdd_HHmmss')
$bk = Join-Path $RepoRoot ("_local\patch_backups\rereview_{0}_{1}_{2}" -f $RR,($rel -replace '[\\\/:\s]','_'),$ts)
Backup-File $full $bk
Write-Utf8NoBom $full $newText

"APPLY=CHANGED"
"BACKUP=" + $bk
"FILE=" + $rel