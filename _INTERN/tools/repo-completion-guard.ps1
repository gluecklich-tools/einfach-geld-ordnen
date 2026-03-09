param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Repo-Repair","Repo-Verify","Repo-Closeout","Repo-Resume")]
    [string]$Mode,

    [string]$RepoRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$Message) { throw $Message }

$required = @(
    (Join-Path $RepoRoot "_INTERN\governance\REPO_COMPLETION_ORDER_POLICY.md"),
    (Join-Path $RepoRoot "_INTERN\governance\REPO_COMPLETION_CHECKLIST.md"),
    (Join-Path $RepoRoot "_INTERN\governance\REPO_COMPLETION_HARD_RULES.md")
)

$missing = @($required | Where-Object { -not (Test-Path -LiteralPath $_) })
if ($missing.Count -gt 0) {
    Fail ("FAIL: repo completion guard missing required files:`r`n" + ($missing -join "`r`n"))
}

$gitStatus = @(& git -C $RepoRoot status --porcelain)
if ($LASTEXITCODE -ne 0) {
    Fail "FAIL: git status failed"
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$reportDir = Join-Path (Join-Path (Join-Path $RepoRoot "_local\chatpack") $ts) "SSOT"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$reportPath = Join-Path $reportDir ("REPO_COMPLETION_GUARD_{0}.md" -f (($Mode -replace '[^A-Za-z0-9]+','_').Trim('_').ToUpperInvariant()))

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Repo Completion Guard") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Mode") | Out-Null
$lines.Add($Mode) | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Git Status Count") | Out-Null
$lines.Add([string]$gitStatus.Count) | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Rules") | Out-Null
$lines.Add("- Repair -> Verify -> Commit/Push -> Closeout -> Resume") | Out-Null
$lines.Add("- Kein Themenwechsel mit offenem Repo-P0") | Out-Null
$lines.Add("- Nach jedem gelösten Block neu priorisieren") | Out-Null

if ($Mode -eq "Repo-Resume" -and $gitStatus.Count -gt 0) {
    Fail ("FAIL: Repo-Resume blocked because working tree is not clean:`r`n" + ($gitStatus -join "`r`n"))
}

$lines.Add("") | Out-Null
$lines.Add("## Result") | Out-Null
$lines.Add("PASS") | Out-Null

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($reportPath, ([string]::Join("`r`n", $lines)), $enc)

Write-Host "REPORT: $reportPath"
Write-Host ("CHANGES: {0}" -f $gitStatus.Count)
Write-Host "PASS: repo completion guard"