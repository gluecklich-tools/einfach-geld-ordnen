param(
    [Parameter(Mandatory = $true)]
    [string]$InputXlsx,

    [ValidateSet("apply","snapshot")]
    [string]$Mode = "apply",

    [ValidateSet("START","HAUSHALTSBUCH","MONAT","BUDGETS","FIXKOSTEN","PLANUNG","JAHR","NOTGROSCHEN")]
    [string]$Sheet = "START",

    [ValidateSet("FREEBIE","PRO","VOLLVERSION")]
    [string]$Tier,

    [switch]$Force
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$Message) {
    throw "FAIL: $Message"
}

$RepoRoot   = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PythonExe  = Join-Path $RepoRoot ".venv\Scripts\python.exe"
$BuilderPy  = Join-Path $RepoRoot "tools\build-start-xlsx.py"
$OutDir     = Join-Path $RepoRoot "_local\outputs"
$ChatpackTs = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportDir  = Join-Path $RepoRoot ("_local\chatpack\{0}\SSOT" -f $ChatpackTs)

if (-not (Test-Path -LiteralPath $InputXlsx)) { Fail "InputXlsx fehlt: $InputXlsx" }

$NormalizedInputXlsx = [System.IO.Path]::GetFullPath($InputXlsx)
if (
    $NormalizedInputXlsx -like '*\_local\output\*' -or
    $NormalizedInputXlsx -like '*\_local\outputs\*' -or
    $NormalizedInputXlsx -like '*\_local\patch_backups\*' -or
    $NormalizedInputXlsx -like '*\_local\chatpack\*' -or
    $NormalizedInputXlsx -like '*\_local\_scratch\*'
) {
    Fail "InputXlsx darf nicht aus lokalen Artefaktordnern stammen: $NormalizedInputXlsx"
}
if (-not (Test-Path -LiteralPath $PythonExe))  { Fail "Python fehlt: $PythonExe" }
if (-not (Test-Path -LiteralPath $BuilderPy))  { Fail "Builder fehlt: $BuilderPy" }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($InputXlsx)
$ts = Get-Date -Format "yyyyMMdd_HHmmss"

$targetToken = if ([string]::IsNullOrWhiteSpace($Tier)) { $Sheet.ToLowerInvariant() } else { $Tier.ToLowerInvariant() }

if ($Mode -eq "snapshot") {
    $outPath = Join-Path $OutDir ("{0}_{1}_snapshot_{2}.json" -f $baseName, $targetToken, $ts)
    $reportPath = Join-Path $ReportDir ("BUILD_{0}_XLSX_SNAPSHOT.json" -f $targetToken.ToUpperInvariant())
}
else {
    $outPath = Join-Path $OutDir ("{0}_{1}_builder_{2}.xlsx" -f $baseName, $targetToken, $ts)
    $reportPath = Join-Path $ReportDir ("BUILD_{0}_XLSX_APPLY.json" -f $targetToken.ToUpperInvariant())
    if ((Test-Path -LiteralPath $outPath) -and (-not $Force)) {
        Fail "Output existiert bereits. Nutze -Force."
    }
}

$argList = @(
    $BuilderPy,
    "--input", $InputXlsx,
    "--output", $outPath,
    "--mode", $Mode
)

if ([string]::IsNullOrWhiteSpace($Tier)) {
    $argList += @("--sheet", $Sheet)
}
else {
    $argList += @("--tier", $Tier.ToUpperInvariant())
}

$stdout = & $PythonExe @argList 2>&1
if ($LASTEXITCODE -ne 0) {
    $msg = ($stdout | Out-String).Trim()
    Fail "Builder fehlgeschlagen: $msg"
}

$stdoutText = ($stdout | Out-String).Trim()
[System.IO.File]::WriteAllText(
    $reportPath,
    $stdoutText,
    (New-Object System.Text.UTF8Encoding($false))
)

if ($Mode -eq "snapshot") {
    Write-Host "SNAPSHOT: $outPath"
    Write-Host "REPORT: $reportPath"
    Write-Host ("PASS: build-{0}-xlsx snapshot" -f $targetToken)
}
else {
    Write-Host "OUTPUT: $outPath"
    Write-Host "REPORT: $reportPath"
    Write-Host ("PASS: build-{0}-xlsx apply" -f $targetToken)
}