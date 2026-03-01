# EGO_LEGAL_HINTS_GATE_V1
# ALLOW_REGEX_PATCH (temporary; must be removed when refactored to literal/AST patching)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
if ($PSVersionTable.PSVersion.Major -lt 7) { throw "NOT IN PWSH 7+. Current: $($PSVersionTable.PSVersion)" }
$Repo = (Split-Path -Parent $PSScriptRoot)
Set-Location -LiteralPath $Repo
$TokenAudit = '<!-- EGO_AUDIT_UPDATE_HINT -->'
$TokenAI    = '<!-- EGO_AI_HINT -->'
$Allow = @(
  'seiten/datenschutz.md',
  'seiten/impressum.md',
  'seiten/projektbeschreibung_transparenz.md',
  '_includes/disclaimer_finanzinfo.html'
)
function Read-Utf8NoBom([string]$Path){
  [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
}
$tracked = @(git ls-files)
$bad = New-Object System.Collections.Generic.List[string]
foreach ($rel in $tracked) {
  $relNorm = ($rel -replace '\\','/').ToLowerInvariant()
  if ($relNorm -notmatch '\.(md|html)$') { continue }
  $abs = Join-Path $Repo $rel
  if (-not (Test-Path -LiteralPath $abs)) { continue }
  $txt = Read-Utf8NoBom $abs
  if ($txt -like "*$TokenAudit*" -or $txt -like "*$TokenAI*") {
    if (-not ($Allow -contains $relNorm)) { [void]$bad.Add($relNorm) }
  }
}
if ($bad.Count -gt 0) {
  "FAIL: legal hint tokens found outside allowlist:" | Write-Output
  $bad | Sort-Object -Unique | Write-Output
  exit 1
}
"PASS: legal-hints gate OK." | Write-Output