param(
    [Parameter(Mandatory = $true)]
    [Alias("StepPath")]
    [string]$Step,

    [ValidateSet("Produkt-Loop","Claude-Prompting","Governance-Änderung","Brain-Intern-Struktur","Folgeprojekt-Klon","OpenAI-Regress-Governance")]
    [string]$RequiredReadsTaskType
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

$StepPath = $Step
if (-not (Test-Path -LiteralPath $StepPath)) {
    Fail ("FAIL: step not found: " + $StepPath)
}

$RepoRoot = (Resolve-Path (Join-Path (Split-Path -Parent $StepPath) "..\..")).Path

$RequiredReadsPreflight = Join-Path $RepoRoot "_INTERN\tools\knowledge-required-reads-preflight.ps1"
if (-not [string]::IsNullOrWhiteSpace($RequiredReadsTaskType)) {
    if (-not (Test-Path -LiteralPath $RequiredReadsPreflight)) {
        Fail "FAIL: required reads preflight missing: $RequiredReadsPreflight"
    }
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $RequiredReadsPreflight -TaskType $RequiredReadsTaskType
    $exit = $LASTEXITCODE
    if ($exit -ne 0) {
        Fail "FAIL: required reads preflight failed for task type [$RequiredReadsTaskType]"
    }
}

$raw = Get-Content -LiteralPath $StepPath -Raw

if ($raw -notmatch '\$EGO_STEP_WRITE_ALLOWLIST\s*=\s*@\(') {
    Fail 'FAIL: step missing $EGO_STEP_WRITE_ALLOWLIST = @(...).'
}

if ($raw -match '(?m)^\s*\$null\s*=\s*\$lines\.Add\(\s*"[-#]') {
    Fail 'FAIL: step report line uses parser-fragile interpolated string; use format operator (-f) or prebuilt string.'
}

if ($raw -match '(?m)^\s*\$pass\w+\s*=\s*\(\(.*\|\s*Where-Object\b.*\)\.Count\s*-eq\s*\d+\)') {
    Fail 'FAIL: step uses pipeline Count directly after Where-Object; wrap with @(... ) before .Count.'
}

if ($raw -match '(?m)\[\s*System\.Collections\.Generic\.List\[string\]\s*\]\$List') {
    Fail 'FAIL: step helper uses Generic.List[string] parameter binding; use direct .Add(...) on local list.'
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $StepPath
$exit = $LASTEXITCODE

if ($exit -ne 0) {
    Fail ("STOP: step-run failed (exit={0})" -f $exit)
}

'PASS: step-run'