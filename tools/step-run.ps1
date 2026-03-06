param(
    [Parameter(Mandatory = $true)]
    [string]$StepPath
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

if (-not (Test-Path -LiteralPath $StepPath)) {
    Fail ("FAIL: step not found: " + $StepPath)
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