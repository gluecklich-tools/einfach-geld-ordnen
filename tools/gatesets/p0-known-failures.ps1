# P0 Known Failure Gates - synced 20260428 A158/V9

$script:EGO_P0_KNOWN_FAILURES = @(
    "NO_BIG_INLINE_COMMAND",
    "FULLSWAP_ONLY",
    "NO_NAKED_STEP_OR_FILE_RUN",
    "TRUTH_FREEZE_REQUIRED",
    "SCREENSHOT_PASS_REQUIRED_FOR_VISIBLE_PRODUCT_ACCEPTANCE",
    "REJECTED_STAGE_NO_CONTINUATION",
    "STAGE_ONLY_BEFORE_ACTIVE_REPLACE",
    "NO_GLOBAL_USEDRANGE_CLEAR_AUTOFIT_UNMERGE_DELETE",
    "MERGE_SAFE_EXCEL_CLEANUP_REQUIRED",
    "ALLOW_EMPTY_COLLECTION_FOR_EMPTY_FINDINGS",
    "REQUIRED_READS_MATRIX_RUNNER_VALIDATESET_ATOMIC_SYNC",
    "LEAN_HANDOFF_ZIP_REQUIRED",
    "PUBLIC_PRIVATE_BOUNDARY_SCAN_BEFORE_COMMIT",
    "MAX_THREE_VISIBLE_FIXES_THEN_CONTRACT_REBUILD",
    "NO_V6_V7_V8_ROUTE_REPETITION_FOR_SCHULDEN_MONATSABSCHLUSS"
)

function Get-EgoP0KnownFailures {
    [CmdletBinding()]
    param()

    return $script:EGO_P0_KNOWN_FAILURES
}

function Test-EgoTruthFreezeText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [string]$ExpectedHash = "A158F210C4C8DA9B5A41DFAED80AD010A49598B2E2371E576C88F4E92BE1AE33",
        [string]$ExpectedScope = "STAGE_ONLY_COMPACT_LAYOUT_CONTRACT_SCHULDEN_MONATSABSCHLUSS_V9"
    )

    $required = @(
        $ExpectedHash,
        $ExpectedScope,
        "V8",
        "visuell abgelehnt",
        "V9 kompakter Layout-Contract",
        "kein Active Replace"
    )

    $missing = @($required | Where-Object { $Text -notlike ("*" + $_ + "*") })

    return [pscustomobject]@{
        Pass = ($missing.Count -eq 0)
        Missing = $missing
    }
}
