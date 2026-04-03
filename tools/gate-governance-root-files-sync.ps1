param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ProjectRoot = (Resolve-Path (Join-Path $RepoRoot '..\..')).Path

$CanonicalGov = Join-Path $ProjectRoot '_INTERN\governance'
$RepoGov = Join-Path $RepoRoot '_INTERN\governance'
$CanonicalBrain = Join-Path $ProjectRoot 'Brain_EGO_Dateien'
$RepoBrain = Join-Path $RepoRoot 'Brain_EGO_Dateien'

$Pairs = @(
    @{ A = (Join-Path $CanonicalGov 'BOOTSTRAP_INTERNAL.md');          B = (Join-Path $RepoGov 'BOOTSTRAP_INTERNAL.md') },
    @{ A = (Join-Path $CanonicalGov 'GOVERNANCE_INTERNAL.md');         B = (Join-Path $RepoGov 'GOVERNANCE_INTERNAL.md') },
    @{ A = (Join-Path $CanonicalGov 'LEARNINGS_INTERNAL.md');          B = (Join-Path $RepoGov 'LEARNINGS_INTERNAL.md') },
    @{ A = (Join-Path $CanonicalGov 'QA_GATE_INTERNAL.md');            B = (Join-Path $RepoGov 'QA_GATE_INTERNAL.md') },
    @{ A = (Join-Path $CanonicalBrain 'ACTIVE_SCOPE_LOCK_INTERNAL.md'); B = (Join-Path $RepoBrain 'ACTIVE_SCOPE_LOCK_INTERNAL.md') }
)

$Missing = 0
$Mismatch = 0

foreach ($pair in $Pairs) {
    if (-not (Test-Path -LiteralPath $pair.A -PathType Leaf) -or -not (Test-Path -LiteralPath $pair.B -PathType Leaf)) {
        $Missing++
        Write-Host ("MISSING={0} | {1}" -f $pair.A, $pair.B)
        continue
    }

    $ha = (Get-FileHash -LiteralPath $pair.A -Algorithm SHA256).Hash
    $hb = (Get-FileHash -LiteralPath $pair.B -Algorithm SHA256).Hash
    if ($ha -ne $hb) {
        $Mismatch++
        Write-Host ("MISMATCH={0} | {1}" -f $pair.A, $pair.B)
    }
}

Write-Host ("MISSING_COUNT={0}" -f $Missing)
Write-Host ("MISMATCH_COUNT={0}" -f $Mismatch)

if ($Missing -gt 0 -or $Mismatch -gt 0) {
    throw 'FAIL: governance root sync gate failed'
}

Write-Host 'PASS: governance root files sync gate'
