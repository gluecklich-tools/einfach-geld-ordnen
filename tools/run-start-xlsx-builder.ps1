[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputXlsx,
    [ValidateSet("snapshot", "dry-run", "apply")][string]$Mode = "snapshot",
    [string]$OutputXlsx = "",
    [string]$ReportPath = "",
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PythonExe = Join-Path $RepoRoot ".venv\Scripts\python.exe"
$BuilderPath = Join-Path $PSScriptRoot "build-start-xlsx.py"

function Fail([string]$Message) {
    throw "FAIL: $Message"
}

if (-not (Test-Path -LiteralPath $PythonExe)) {
    Fail "Python venv nicht gefunden: $PythonExe"
}
if (-not (Test-Path -LiteralPath $BuilderPath)) {
    Fail "Builder nicht gefunden: $BuilderPath"
}

$inputResolved = (Resolve-Path -LiteralPath $InputXlsx).Path

if ([string]::IsNullOrWhiteSpace($OutputXlsx)) {
    $outDir = Join-Path $RepoRoot "_local\outputs"
    $name = [System.IO.Path]::GetFileNameWithoutExtension($inputResolved)
    $ext  = [System.IO.Path]::GetExtension($inputResolved)
    $ts   = Get-Date -Format "yyyyMMdd_HHmmss"
    $OutputXlsx = Join-Path $outDir ("{0}_start_builder_{1}{2}" -f $name, $ts, $ext)
}

if ([string]::IsNullOrWhiteSpace($ReportPath)) {
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    $ReportPath = Join-Path $RepoRoot ("_local\chatpack\{0}\SSOT\BUILD_START_XLSX_{1}.json" -f $ts, ($Mode.ToUpperInvariant() -replace '-', '_'))
}

$args = @(
    $BuilderPath
    "--input", $inputResolved
    "--output", $OutputXlsx
    "--report", $ReportPath
    "--mode", $Mode
)

if ($Force) {
    $args += "--force"
}

& $PythonExe @args

if ($LASTEXITCODE -ne 0) {
    Fail "build-start-xlsx.py fehlgeschlagen (exit=$LASTEXITCODE)."
}