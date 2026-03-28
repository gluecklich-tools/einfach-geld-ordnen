param(
  [string]$BaseDir = "C:\Users\carst\OpenAI_Logs",
  [string]$GovRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-Utf8NoBom {
  param([string]$Path,[string]$Content)
  $dir = Split-Path -Parent $Path
  if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path,$Content,$enc)
}

function Get-FieldValue {
  param($Obj,[string[]]$Names)
  foreach ($name in $Names) {
    if ($null -ne $Obj -and $Obj.PSObject.Properties.Name -contains $name) {
      $value = $Obj.$name
      if ($null -ne $value -and "$value".Trim() -ne "") { return "$value" }
    }
  }
  return $null
}

$incFile = Join-Path $BaseDir "checks\incidents.jsonl"
if (-not (Test-Path -LiteralPath $incFile)) { throw "Missing incidents file: $incFile" }

$lines = Get-Content -LiteralPath $incFile -Encoding utf8 | Where-Object { $_.Trim() -ne "" }
$items = foreach ($line in $lines) {
  try { $line | ConvertFrom-Json -Depth 8 } catch {}
}

$relevant = $items | Where-Object {
  $null -ne $_ -and (
    (($_.PSObject.Properties.Name -contains 'type') -and ($_.type -match 'CHATGPT|OPENAI')) -or
    (($_.PSObject.Properties.Name -contains 'project') -and ($_.project -eq 'Einfach Geld ordnen'))
  )
}

$findingsDir = Join-Path $GovRoot "findings"
New-Item -ItemType Directory -Force -Path $findingsDir | Out-Null
$summaryPath = Join-Path $findingsDir "OPENAI_REGRESS_ROLLUP_LATEST.md"

$buf = @()
$buf += "# OPENAI_REGRESS_ROLLUP_LATEST"
$buf += ""
$buf += ("Stand: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
$buf += ("Treffer: {0}" -f @($relevant).Count)
$buf += ""

foreach ($r in ($relevant | Select-Object -Last 20)) {
  $ts   = Get-FieldValue -Obj $r -Names @("ts_local","timestamp","ts","date")
  $type = Get-FieldValue -Obj $r -Names @("type","kind","event")
  $msg  = Get-FieldValue -Obj $r -Names @("message","impact","note","chat_context")
  if (-not $ts)   { $ts = "<no-ts>" }
  if (-not $type) { $type = "<no-type>" }
  if (-not $msg)  { $msg = "<no-message>" }
  $buf += ("- {0} | {1} | {2}" -f $ts, $type, $msg)
}

Write-Utf8NoBom -Path $summaryPath -Content ($buf -join "`r`n")
Write-Host ("WROTE -> {0}" -f $summaryPath)