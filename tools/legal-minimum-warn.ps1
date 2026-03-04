# EGO_LEGAL_MIN_WARN_V1
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
Set-StrictMode -Version Latest
try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
if ($PSVersionTable.PSVersion.Major -lt 7) { throw (NOT IN PWSH 7+. Current: {0} -f $PSVersionTable.PSVersion) }

$Repo = (Split-Path -Parent $PSScriptRoot)
Set-Location -LiteralPath $Repo

function Read-Utf8NoBom([string]$Path){
  [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
}

function WarnIfMissing([string]$Label, [string]$Text, [string]$Needle){
  if ($Text -notmatch $Needle) {
    Write-Output (WARN: {0} missing pattern: {1} -f @($Label, $Needle))
    return $false
  }
  return $true
}

$ok = $true

$imp = Join-Path $Repo 'seiten/impressum.md'
$dat = Join-Path $Repo 'seiten/datenschutz.md'
$tra = Join-Path $Repo 'seiten/projektbeschreibung_transparenz.md'
$dis = Join-Path $Repo '_includes/disclaimer_finanzinfo.html'

if (Test-Path -LiteralPath $imp) {
  $t = Read-Utf8NoBom $imp
  $ok = (WarnIfMissing 'impressum' $t 'DDG') -and $ok
  $ok = (WarnIfMissing 'impressum' $t 'MStV') -and $ok
} else { Write-Output 'WARN: impressum file missing'; $ok = $false }

if (Test-Path -LiteralPath $dat) {
  $t = Read-Utf8NoBom $dat
  $ok = (WarnIfMissing 'datenschutz' $t 'DSGVO') -and $ok
  $ok = (WarnIfMissing 'datenschutz' $t 'Cloudflare') -and $ok
} else { Write-Output 'WARN: datenschutz file missing'; $ok = $false }

if (Test-Path -LiteralPath $tra) {
  $t = Read-Utf8NoBom $tra
  $ok = (WarnIfMissing 'transparenz' $t 'KI') -and $ok
  $ok = (WarnIfMissing 'transparenz' $t 'keine') -and $ok
} else { Write-Output 'WARN: transparenz file missing'; $ok = $false }

if (Test-Path -LiteralPath $dis) {
  $t = Read-Utf8NoBom $dis
  $ok = (WarnIfMissing 'disclaimer' $t 'keine') -and $ok
} else { Write-Output 'WARN: disclaimer include missing'; $ok = $false }

if ($ok) { Write-Output 'PASS: legal-minimum warn-check OK.' }
else     { Write-Output 'WARN: legal-minimum warn-check has findings (non-blocking).' }

exit 0
