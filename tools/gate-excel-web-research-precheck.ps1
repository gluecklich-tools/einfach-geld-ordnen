param(
    [Parameter(Mandatory = $true)]
    [string]$ResearchReportPath,
    [string]$ScopeToken = '',
    [string]$WorkbookPath = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not (Test-Path -LiteralPath $ResearchReportPath -PathType Leaf)) {
    throw ('FAIL: research report missing: {0}' -f $ResearchReportPath)
}

$content = [System.IO.File]::ReadAllText($ResearchReportPath, [System.Text.UTF8Encoding]::new($false))

$requiredTokens = @(
    'MICROSOFT_DOCS=present',
    'MICROSOFT_COMMUNITY_OR_FORUM=present',
    'CHAMPIONSHIP_OR_FMWC=present',
    'RULE=RESEARCH_REQUIRED_BEFORE_ANY_EXCEL_COMMAND'
)

foreach ($token in $requiredTokens) {
    if ($content -notmatch [regex]::Escape($token)) {
        throw ('FAIL: missing research token: {0}' -f $token)
    }
}

if ($ScopeToken -and ($content -notmatch [regex]::Escape($ScopeToken))) {
    throw ('FAIL: missing scope token in research report: {0}' -f $ScopeToken)
}

if ($WorkbookPath -and ($content -notmatch [regex]::Escape($WorkbookPath))) {
    throw ('FAIL: missing workbook path in research report: {0}' -f $WorkbookPath)
}

Write-Host ("REPORT={0}" -f $ResearchReportPath)
Write-Host ("SCOPE_TOKEN={0}" -f $ScopeToken)
Write-Host 'PASS: excel web research precheck'
