#requires -Version 7.0
param([string]$RepoRoot = (Get-Location).Path)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

Set-Location -LiteralPath $RepoRoot

# Dirty check (ignore _local noise)
$st = git status --porcelain=v1
$dirty = @($st | Where-Object {
  ($_ -notmatch '^\?\?\s+_local\\') -and
  ($_ -notmatch '^\s*M\s+_local\\') -and
  ($_ -notmatch '^\s*A\s+_local\\') -and
  ($_ -notmatch '^\s*D\s+_local\\')
})

if(@($dirty).Count -eq 0){
  "OK: gate-no-inline-dirty-changes: repo clean (ignoring _local)"
  exit 0
}

$marker = Join-Path $RepoRoot "_local\_scratch\_LAST_STEP_RUN.json"
if(!(Test-Path -LiteralPath $marker)){
  Fail "STOP: DIRTY repo but no step marker. LAW NO_INLINE_STEP_EXECUTION: only changes made via enterprise-run step are allowed."
}

try{
  $raw = Get-Content -LiteralPath $marker -Encoding UTF8 -Raw
  if([string]::IsNullOrWhiteSpace($raw)){
    Fail "STOP: step marker unreadable: file is empty (_LAST_STEP_RUN.json)"
  }

  # Strip BOM if present
  if($raw.Length -gt 0 -and [int][char]$raw[0] -eq 65279){
    $raw = $raw.Substring(1)
  }

  $m = $raw | ConvertFrom-Json
  $tsText = [string]$m.timestamp
  if([string]::IsNullOrWhiteSpace($tsText)){
    Fail "STOP: step marker unreadable: timestamp missing"
  }

  $styles = [Globalization.DateTimeStyles]::RoundtripKind
  $inv = [Globalization.CultureInfo]::InvariantCulture

  $dto = [DateTimeOffset]::Parse($tsText, $inv, $styles)
  $ts = $dto.DateTime
}catch{
  Fail ("STOP: step marker unreadable: _LAST_STEP_RUN.json :: " + $_.Exception.Message)
}

$ageMin = ((Get-Date) - $ts).TotalMinutes
if($ageMin -gt 15){
  Fail ("STOP: DIRTY repo but step marker too old ({0} min). Run your step again via enterprise-run." -f ([math]::Round($ageMin,2)))
}

"OK: gate-no-inline-dirty-changes: dirty repo allowed (recent step marker)"
exit 0
