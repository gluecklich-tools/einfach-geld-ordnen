param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(

        'Produkt-Loop',

        'Claude-Prompting',

        'Governance-Änderung',

        'Brain-Intern-Struktur',

        'Folgeprojekt-Klon',

        'OpenAI-Regress-Governance',

        'Tool-Entrypoint-Failure',

        'Workbook-Artifact-Identity',

        'Active-Scope-Lock',

        'Visible-Surface-Rebuild',

        'Workbook-Masterpass',

        'Sheet-Finalizer',

        'Tool-Repair',

        'Hash-Mismatch-Relock'
    )]
    [string]$TaskType,

    [string]$RepoRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\GitHub_Clone_Dateien\einfach-geld-ordnen",

    [string]$BrainRoot = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\Brain_EGO_Dateien",

    [string]$ClaudeRoot = "C:\Users\carst\Projekte\Claude"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$Message) {
    throw ("FAIL: {0}" -f $Message)
}

function Split-List([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }

    return @(
        ($Value -split ';') |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne "" }
    )
}

function Resolve-TokenToPath {
    param(
        [Parameter(Mandatory = $true)][string]$Token,
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$BrainRoot,
        [Parameter(Mandatory = $true)][string]$ClaudeRoot
    )

    switch -Regex ($Token) {
        '^_INTERN\\' {
            return (Join-Path $RepoRoot $Token)
        }
        '^Brain_EGO_Dateien\\' {
            $suffix = $Token.Substring("Brain_EGO_Dateien\".Length)
            return (Join-Path $BrainRoot $suffix)
        }
        '^Claude\\' {
            $suffix = $Token.Substring("Claude\".Length)
            return (Join-Path $ClaudeRoot $suffix)
        }
        '^C:\\' {
            return $Token
        }
        default {
            return $Token
        }
    }
}

$matrixPath = Join-Path $RepoRoot "_INTERN\governance\TASK_REQUIRED_READS_MATRIX.tsv"
if (-not (Test-Path -LiteralPath $matrixPath -PathType Leaf)) {
    Fail ("TASK_REQUIRED_READS_MATRIX.tsv missing: {0}" -f $matrixPath)
}

$lines = @([System.IO.File]::ReadAllLines($matrixPath, [System.Text.Encoding]::UTF8))
if (@($lines).Count -lt 2) {
    Fail ("TASK_REQUIRED_READS_MATRIX.tsv empty: {0}" -f $matrixPath)
}

$rows = @(
    foreach ($line in @($lines | Select-Object -Skip 1)) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $parts = @($line -split "`t", 5)
        if (@($parts).Count -lt 5) {
            Fail ("malformed matrix row: {0}" -f $line)
        }

        [pscustomobject]@{
            TaskType        = $parts[0].Trim()
            RequiredPrimary = $parts[1].Trim()
            RequiredMirror  = $parts[2].Trim()
            Optional        = $parts[3].Trim()
            ContextRule     = $parts[4].Trim()
        }
    }
)

$row = @($rows | Where-Object { $_.TaskType -eq $TaskType } | Select-Object -First 1)
if (@($row).Count -eq 0) {
    Fail ("task type not found in matrix: {0}" -f $TaskType)
}
$row = $row[0]

$required = @()
$required += @(Split-List $row.RequiredPrimary)
$required += @(Split-List $row.RequiredMirror)
$required = @($required | Where-Object { $_ -ne "" })

if (@($required).Count -eq 0) {
    Fail ("no required reads resolved for task type: {0}" -f $TaskType)
}

$resolved = @(
    foreach ($item in @($required)) {
        $path = Resolve-TokenToPath -Token $item -RepoRoot $RepoRoot -BrainRoot $BrainRoot -ClaudeRoot $ClaudeRoot

        [pscustomobject]@{
            Token  = $item
            Path   = $path
            Exists = (Test-Path -LiteralPath $path)
            Kind   = if (Test-Path -LiteralPath $path -PathType Container) {
                "Dir"
            }
            elseif (Test-Path -LiteralPath $path -PathType Leaf) {
                "File"
            }
            else {
                "Missing"
            }
        }
    }
)

$missing = @($resolved | Where-Object { -not $_.Exists })
if (@($missing).Count -gt 0) {
    $list = (@($missing | ForEach-Object { $_.Path }) -join "`r`n")
    Fail ("required reads missing for task [{0}]:`r`n{1}" -f $TaskType, $list)
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$reportDir = Join-Path (Join-Path $RepoRoot "_local\chatpack") $ts
$reportDir = Join-Path $reportDir "SSOT"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$taskSlug = ($TaskType -replace '[^A-Za-z0-9]+','_').Trim('_').ToUpperInvariant()
$reportPath = Join-Path $reportDir ("REQUIRED_READS_PREFLIGHT_{0}.md" -f $taskSlug)

$readLines = @(
    $resolved | ForEach-Object {
        "- [{0}] {1}" -f $_.Kind, $_.Path
    }
)

$body = @"
# Required Reads Preflight

## TaskType
$TaskType

## TaskSlug
$taskSlug

## Matrix
$matrixPath

## Required Reads
$($readLines -join "`r`n")

## Result
PASS
"@

$enc = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($reportPath, $body, $enc)

Write-Host ("TASKTYPE: {0}" -f $TaskType)
Write-Host ("TASKSLUG: {0}" -f $taskSlug)
Write-Host ("REPORT: {0}" -f $reportPath)
Write-Host ("READS: {0}" -f @($resolved).Count)
Write-Host "PASS: required reads preflight"

# EGO_MANAGED_BLOCK:APRIL03_REQUIREDREADS:START
# Governance-Änderung / Tool-Änderung / Active-Scope-Änderung erfordern Required Reads vor RUN.
# EGO_MANAGED_BLOCK:APRIL03_REQUIREDREADS:END

# EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:START
# Excel-bezogene Schritte brauchen vorgelagerten Research-Precheck.
# Required Reads ersetzt diesen Web-Research nicht, sondern kommt zusaetzlich davor oder parallel.
# EGO_MANAGED_BLOCK:APRIL03_EXCEL_RESEARCH_FIRST:END

# EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_REQUIRED_READS:START
# RequiredReads-Preflight kennt jetzt Workbook-Masterpass, Sheet-Finalizer, Tool-Repair und Hash-Mismatch-Relock.
# EGO_MANAGED_BLOCK:APRIL09_MASTERPASS_HYBRID_REQUIRED_READS:END
