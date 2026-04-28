[CmdletBinding()]
param(
    [string]$ProjectRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen",
    [string]$RepoRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen",
    [string]$BrainRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\Brain_EGO_Dateien",
    [string]$ExpectedWorkbookSha256 = "A158F210C4C8DA9B5A41DFAED80AD010A49598B2E2371E576C88F4E92BE1AE33",
    [string]$ExpectedScope = "STAGE_ONLY_COMPACT_LAYOUT_CONTRACT_SCHULDEN_MONATSABSCHLUSS_V9"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$targets = @(
    (Join-Path $BrainRoot "ACTIVE_SCOPE_LOCK_INTERNAL.md"),
    (Join-Path $BrainRoot "latest\ACTIVE_SCOPE_LOCK_INTERNAL.md"),
    (Join-Path $ProjectRoot "_INTERN\governance\ACTIVE_SCOPE_LOCK_INTERNAL.md"),
    (Join-Path $ProjectRoot "_INTERN\governance\brain_mirror\ACTIVE_SCOPE_LOCK_INTERNAL.md")
)

$missingFiles = New-Object System.Collections.Generic.List[string]
$missingMarkers = New-Object System.Collections.Generic.List[string]

foreach ($target in $targets) {
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
        $missingFiles.Add($target)
        continue
    }

    $text = [System.IO.File]::ReadAllText($target)
    foreach ($marker in @($ExpectedWorkbookSha256, $ExpectedScope, "V8", "visuell abgelehnt", "kein Active Replace", "V9 kompakter Layout-Contract")) {
        if ($text -notlike ("*" + $marker + "*")) {
            $missingMarkers.Add(("{0} :: {1}" -f $target, $marker))
        }
    }
}

if ($missingFiles.Count -gt 0 -or $missingMarkers.Count -gt 0) {
    "STATUS=FAIL"
    "MISSING_FILE_COUNT=$($missingFiles.Count)"
    $missingFiles | ForEach-Object { "MISSING_FILE=$_" }
    "MISSING_MARKER_COUNT=$($missingMarkers.Count)"
    $missingMarkers | ForEach-Object { "MISSING_MARKER=$_" }
    exit 1
}

"STATUS=PASS"
"EXPECTED_SCOPE=$ExpectedScope"
"EXPECTED_HASH=$ExpectedWorkbookSha256"
exit 0
