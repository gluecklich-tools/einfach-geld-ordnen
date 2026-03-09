param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Produkt-Loop","Claude-Prompting","Claude-Review","Folgeprojekt-Klon")]
    [string]$Mode,

    [string]$RepoRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen",

    [string]$BrainRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\Brain_EGO_Dateien",

    [string]$ClaudeRoot = "C:\Users\carst\Projekte\Claude"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$Message) { throw $Message }

$requiredReadsPreflight = Join-Path $RepoRoot "_INTERN\tools\knowledge-required-reads-preflight.ps1"
if (-not (Test-Path -LiteralPath $requiredReadsPreflight)) {
    Fail "FAIL: missing required reads preflight: $requiredReadsPreflight"
}

$taskType = switch ($Mode) {
    "Produkt-Loop"     { "Produkt-Loop" }
    "Claude-Prompting" { "Claude-Prompting" }
    "Claude-Review"    { "Claude-Prompting" }
    "Folgeprojekt-Klon" { "Folgeprojekt-Klon" }
    default            { "Claude-Prompting" }
}

& pwsh -NoProfile -ExecutionPolicy Bypass -File $requiredReadsPreflight -TaskType $taskType
$exit = $LASTEXITCODE
if ($exit -ne 0) {
    Fail "FAIL: required reads preflight failed for Claude mode [$Mode]"
}

$corePaths = @(
    (Join-Path $ClaudeRoot "LEARNINGS_CLAUDE.md"),
    (Join-Path $ClaudeRoot "DRIFT_PATTERNS_CLAUDE.md"),
    (Join-Path $ClaudeRoot "PROMPT_PATTERNS_CLAUDE.md"),
    (Join-Path $ClaudeRoot "BINDIGUNGSREGELN_CLAUDE.md"),
    (Join-Path $ClaudeRoot "FAILURES_CLAUDE.md"),
    (Join-Path $RepoRoot "_INTERN\governance\claude\CLAUDE_WORK_GUARD_POLICY.md"),
    (Join-Path $RepoRoot "_INTERN\governance\claude\CLAUDE_PRODUCT_LOOP_HARD_RULES.md"),
    (Join-Path $BrainRoot "external_models\claude\CLAUDE_WORK_GUARD_AND_RESUME.md")
)

$missing = @($corePaths | Where-Object { -not (Test-Path -LiteralPath $_) })
if ($missing.Count -gt 0) {
    Fail ("FAIL: Claude work guard missing core files:`r`n" + ($missing -join "`r`n"))
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$reportDir = Join-Path (Join-Path (Join-Path $RepoRoot "_local\chatpack") $ts) "SSOT"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$reportPath = Join-Path $reportDir ("CLAUDE_WORK_GUARD_{0}.md" -f (($Mode -replace '[^A-Za-z0-9]+','_').Trim('_').ToUpperInvariant()))

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Claude Work Guard") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Mode") | Out-Null
$lines.Add($Mode) | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Required Core Files") | Out-Null
foreach ($path in $corePaths) {
    $lines.Add("- " + $path) | Out-Null
}
$lines.Add("") | Out-Null
$lines.Add("## Hard Rules") | Out-Null
$lines.Add("- Keine Claude-Arbeit ohne Required Reads und Claude Work Guard") | Out-Null
$lines.Add("- Keine neue Seite ohne reale Freigabe der aktuellen Seite") | Out-Null
$lines.Add("- Kein Vertrauen in Claude-Claims ohne Artefaktprüfung") | Out-Null
$lines.Add("- Premium-Ziele nur über Mikro-Loops") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Result") | Out-Null
$lines.Add("PASS") | Out-Null

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($reportPath, ([string]::Join("`r`n", $lines)), $enc)

Write-Host "REPORT: $reportPath"
Write-Host "FILES: $($corePaths.Count)"
Write-Host "PASS: claude work guard"