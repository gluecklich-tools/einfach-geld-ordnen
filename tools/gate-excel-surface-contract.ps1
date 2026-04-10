param(
    [Parameter(Mandatory = $true)]
    [string]$ContractPath,

    [Parameter(Mandatory = $true)]
    [string]$LayoutSpecPath,

    [Parameter(Mandatory = $true)]
    [string]$WorkbookPath,

    [Parameter(Mandatory = $true)]
    [string]$WorkbookSha256
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail {
    param([Parameter(Mandatory = $true)][string]$Message)
    throw ('FAIL: {0}' -f $Message)
}

foreach ($path in @($ContractPath, $LayoutSpecPath, $WorkbookPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        Fail ('missing required path: {0}' -f $path)
    }
}

$contract = [System.IO.File]::ReadAllText($ContractPath, [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
$spec     = [System.IO.File]::ReadAllText($LayoutSpecPath, [System.Text.UTF8Encoding]::new($false)) | ConvertFrom-Json

if ($contract.workbook_path -ne $WorkbookPath) {
    Fail 'contract workbook_path mismatch'
}
if ($spec.workbook_path -ne $WorkbookPath) {
    Fail 'layout spec workbook_path mismatch'
}
if ($contract.workbook_sha256 -ne $WorkbookSha256) {
    Fail 'contract workbook_sha256 mismatch'
}
if ($spec.workbook_sha256 -ne $WorkbookSha256) {
    Fail 'layout spec workbook_sha256 mismatch'
}

if ($contract.visible_input_surface -ne 'A:J') {
    Fail 'visible_input_surface must be A:J'
}
if ($contract.functional_columns -ne 'K:S') {
    Fail 'functional_columns must be K:S'
}
if ($contract.help_card_target -ne 'T:Z') {
    Fail 'help_card_target must be T:Z'
}
if (($contract.force_hidden_columns -join '|') -notmatch 'K:S') {
    Fail 'contract missing K:S hidden rule'
}
if (($contract.force_hidden_columns -join '|') -notmatch 'AA:AB') {
    Fail 'contract missing AA:AB hidden rule'
}
if ($spec.help_card_outer_range -ne 'T1:Z7') {
    Fail 'help_card_outer_range must be T1:Z7'
}
if ($spec.middle_functional_columns -ne 'K:S') {
    Fail 'layout spec middle_functional_columns must be K:S'
}
if ($spec.far_right_hidden_columns -ne 'AA:AB') {
    Fail 'layout spec far_right_hidden_columns must be AA:AB'
}
if ($spec.allowed_help_card_zone -ne 'T:Z') {
    Fail 'layout spec allowed_help_card_zone must be T:Z'
}

$actualSha = (Get-FileHash -LiteralPath $WorkbookPath -Algorithm SHA256).Hash.ToUpperInvariant()
if ($actualSha -ne $WorkbookSha256.ToUpperInvariant()) {
    Fail ('workbook sha256 mismatch. expected [{0}] got [{1}]' -f $WorkbookSha256.ToUpperInvariant(), $actualSha)
}

Write-Host ("CONTRACT={0}" -f $ContractPath)
Write-Host ("LAYOUT_SPEC={0}" -f $LayoutSpecPath)
Write-Host ("WORKBOOK_PATH={0}" -f $WorkbookPath)
Write-Host ("WORKBOOK_SHA256={0}" -f $actualSha)
Write-Host 'VISIBLE_INPUT_SURFACE=A:J'
Write-Host 'FUNCTIONAL_COLUMNS=K:S'
Write-Host 'HELP_CARD_TARGET=T:Z'
Write-Host 'FORCE_HIDDEN_COLUMNS=K:S|AA:AB'
Write-Host 'PASS: excel surface contract gate'

# EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_SURFACE_GATE:START
# gate-excel-surface-contract darf keinen alten Prehash-Resume-Punkt durchwinken.
# Bei Hash-Mismatch gilt FAIL CLOSED und Scan-Only.
# EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_SURFACE_GATE:END
