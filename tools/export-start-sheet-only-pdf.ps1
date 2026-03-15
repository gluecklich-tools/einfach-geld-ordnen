param(
    [Parameter(Mandatory = $true)]
    [string]$SourceXlsx,

    [ValidateSet('START')]
    [string]$Sheet = 'START',

    [string]$OutDir,

    [switch]$KeepStartOnlyXlsx
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue

try {
    if ($IsWindows) {
        chcp 65001 > $null
    }
}
catch {
}

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$RunTs    = Get-Date -Format 'yyyyMMdd_HHmmss'

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path $RepoRoot '_local\outputs'
}

$ScratchRoot = Join-Path $RepoRoot '_local\_scratch'
$ChatpackDir = Join-Path $RepoRoot ("_local\chatpack\{0}\SSOT" -f $RunTs)
$ReportPath  = Join-Path $ChatpackDir 'EXPORT_START_SHEET_ONLY_PDF.md'
$JsonPath    = Join-Path $ChatpackDir 'EXPORT_START_SHEET_ONLY_PDF.json'
$StdOutLog   = Join-Path $ChatpackDir 'LIBREOFFICE_STDOUT.log'
$StdErrLog   = Join-Path $ChatpackDir 'LIBREOFFICE_STDERR.log'
$ProfileDir  = Join-Path $ScratchRoot ("lo_profile_start_sheet_only_pdf_{0}" -f $RunTs)

function Fail([string]$Message) {
    throw ('FAIL: {0}' -f $Message)
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $Dir = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($Dir) -and -not (Test-Path -LiteralPath $Dir)) {
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    }

    $Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Join-Lines {
    param([AllowNull()]$Lines)

    if ($null -eq $Lines) {
        return ''
    }

    return (($Lines | ForEach-Object { [string]$_ }) -join [Environment]::NewLine).Trim()
}

function Invoke-CheckedPwsh {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$ArgumentList = @(),
        [Parameter(Mandatory = $true)][string]$Label
    )

    $Output = & pwsh -NoProfile -ExecutionPolicy Bypass -File $FilePath @ArgumentList 2>&1
    $ExitCode = $LASTEXITCODE
    $Text = Join-Lines -Lines $Output

    if ($ExitCode -ne 0) {
        if ([string]::IsNullOrWhiteSpace($Text)) {
            $Text = 'no output'
        }
        Fail ('{0} fehlgeschlagen (exit={1}): {2}' -f $Label, $ExitCode, $Text)
    }

    return [pscustomobject]@{
        Output = @($Output)
        Text   = $Text
    }
}

function Invoke-NativeProcess {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$ArgumentList,
        [Parameter(Mandatory = $true)][string]$StdOutPath,
        [Parameter(Mandatory = $true)][string]$StdErrPath
    )

    if (Test-Path -LiteralPath $StdOutPath) { Remove-Item -LiteralPath $StdOutPath -Force }
    if (Test-Path -LiteralPath $StdErrPath) { Remove-Item -LiteralPath $StdErrPath -Force }

    $Proc = Start-Process `
        -FilePath $FilePath `
        -ArgumentList $ArgumentList `
        -RedirectStandardOutput $StdOutPath `
        -RedirectStandardError $StdErrPath `
        -NoNewWindow `
        -Wait `
        -PassThru

    $StdOut = ''
    $StdErr = ''

    if (Test-Path -LiteralPath $StdOutPath) {
        $StdOut = Get-Content -LiteralPath $StdOutPath -Raw -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $StdErrPath) {
        $StdErr = Get-Content -LiteralPath $StdErrPath -Raw -ErrorAction SilentlyContinue
    }

    return [pscustomobject]@{
        ExitCode = $Proc.ExitCode
        StdOut   = $StdOut
        StdErr   = $StdErr
    }
}

function Resolve-SofficePath {
    $Candidates = New-Object System.Collections.Generic.List[string]

    $CmdCom = Get-Command 'soffice.com' -ErrorAction SilentlyContinue
    if ($null -ne $CmdCom -and -not [string]::IsNullOrWhiteSpace($CmdCom.Source)) {
        [void]$Candidates.Add($CmdCom.Source)
    }

    $CmdExe = Get-Command 'soffice.exe' -ErrorAction SilentlyContinue
    if ($null -ne $CmdExe -and -not [string]::IsNullOrWhiteSpace($CmdExe.Source)) {
        [void]$Candidates.Add($CmdExe.Source)
    }

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        [void]$Candidates.Add((Join-Path $env:ProgramFiles 'LibreOffice\program\soffice.com'))
        [void]$Candidates.Add((Join-Path $env:ProgramFiles 'LibreOffice\program\soffice.exe'))
    }

    if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
        [void]$Candidates.Add((Join-Path ${env:ProgramFiles(x86)} 'LibreOffice\program\soffice.com'))
        [void]$Candidates.Add((Join-Path ${env:ProgramFiles(x86)} 'LibreOffice\program\soffice.exe'))
    }

    foreach ($Candidate in ($Candidates | Select-Object -Unique)) {
        if (Test-Path -LiteralPath $Candidate) {
            return (Resolve-Path -LiteralPath $Candidate).Path
        }
    }

    return $null
}

function Convert-PathToFileUri {
    param([Parameter(Mandatory = $true)][string]$Path)
    $Resolved = (Resolve-Path -LiteralPath $Path).Path
    return ([System.Uri]::new($Resolved)).AbsoluteUri
}

function Stop-LibreOfficeProcesses {
    $Items = @(
        Get-Process -ErrorAction SilentlyContinue |
            Where-Object { $_.ProcessName -like 'soffice*' }
    )

    foreach ($Item in $Items) {
        try {
            Stop-Process -Id $Item.Id -Force -ErrorAction Stop
        }
        catch {
        }
    }

    Start-Sleep -Milliseconds 500
}

function Get-MatchValueOrFail {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $Match = [regex]::Match($Text, $Pattern)
    if (-not $Match.Success) {
        Fail ('{0} nicht gefunden: {1}' -f $Label, $Text)
    }

    $Value = $Match.Groups[1].Value.Trim()
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Fail ('{0} ist leer.' -f $Label)
    }

    return $Value
}

function Get-PdfSnapshot {
    param([Parameter(Mandatory = $true)][string]$Root)

    $Map = @{}
    if (-not (Test-Path -LiteralPath $Root)) {
        return $Map
    }

    foreach ($Item in (Get-ChildItem -LiteralPath $Root -File -Filter '*.pdf' -ErrorAction SilentlyContinue)) {
        $Map[$Item.FullName] = ('{0}|{1}' -f $Item.Length, $Item.LastWriteTimeUtc.ToString('o'))
    }

    return $Map
}

function Get-ChangedPdfPaths {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Before,
        [Parameter(Mandatory = $true)][hashtable]$After
    )

    $Changed = New-Object System.Collections.Generic.List[string]

    foreach ($Path in $After.Keys) {
        if (-not $Before.ContainsKey($Path)) {
            [void]$Changed.Add($Path)
            continue
        }

        if ($Before[$Path] -ne $After[$Path]) {
            [void]$Changed.Add($Path)
        }
    }

    return @($Changed.ToArray())
}

function Get-RunnerArgumentList {
    param(
        [Parameter(Mandatory = $true)][string]$RunnerScript,
        [Parameter(Mandatory = $true)][string]$InputXlsx,
        [Parameter(Mandatory = $true)][string]$Sheet
    )

    $Raw = [System.IO.File]::ReadAllText($RunnerScript, [System.Text.Encoding]::UTF8)
    $Args = @(
        '-InputXlsx', $InputXlsx,
        '-Sheet', $Sheet
    )

    if ($Raw -match '(?m)^\s*\[ValidateSet\("apply","snapshot"\)' -or $Raw -match '(?m)^\s*\[string\]\$Mode\b') {
        $Args += @('-Mode', 'apply')
    }

    return @($Args)
}

New-Item -ItemType Directory -Force -Path $ChatpackDir | Out-Null
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
New-Item -ItemType Directory -Force -Path $ScratchRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null

$ResolvedSourceXlsx = (Resolve-Path -LiteralPath $SourceXlsx -ErrorAction Stop).Path
if (-not $ResolvedSourceXlsx.EndsWith('.xlsx', [System.StringComparison]::OrdinalIgnoreCase)) {
    Fail ('SourceXlsx ist keine .xlsx-Datei: {0}' -f $ResolvedSourceXlsx)
}
if ((Get-Item -LiteralPath $ResolvedSourceXlsx).Length -le 0) {
    Fail ('SourceXlsx ist leer: {0}' -f $ResolvedSourceXlsx)
}

$RunnerScript = Join-Path $RepoRoot 'tools\run-start-xlsx-builder.ps1'
$TrimScript   = Join-Path $RepoRoot 'tools\export-single-sheet-xlsx.py'
$PythonExe    = Join-Path $RepoRoot '.venv\Scripts\python.exe'
$SofficePath  = Resolve-SofficePath

if (-not (Test-Path -LiteralPath $RunnerScript)) { Fail ('Runner fehlt: {0}' -f $RunnerScript) }
if (-not (Test-Path -LiteralPath $TrimScript))   { Fail ('Sheet-Trim-Tool fehlt: {0}' -f $TrimScript) }
if (-not (Test-Path -LiteralPath $PythonExe))    { Fail ('Python fehlt: {0}' -f $PythonExe) }
if ($null -eq $SofficePath)                      { Fail 'LibreOffice soffice.com/soffice.exe wurde nicht gefunden.' }

$RunnerArgs   = Get-RunnerArgumentList -RunnerScript $RunnerScript -InputXlsx $ResolvedSourceXlsx -Sheet $Sheet
$RunnerResult = Invoke-CheckedPwsh -FilePath $RunnerScript -ArgumentList $RunnerArgs -Label 'run-start-xlsx-builder'

$BuilderXlsxPath = Get-MatchValueOrFail -Text $RunnerResult.Text -Pattern '(?im)^OUTPUT:\s*(.+)$' -Label 'Runner OUTPUT'
$RunnerReportPath = 'none'
$RunnerReportMatch = [regex]::Match($RunnerResult.Text, '(?im)^REPORT:\s*(.+)$')
if ($RunnerReportMatch.Success) {
    $RunnerReportPath = $RunnerReportMatch.Groups[1].Value.Trim()
}

if (-not (Test-Path -LiteralPath $BuilderXlsxPath)) {
    Fail ('Builder-OUTPUT-XLSX fehlt: {0}' -f $BuilderXlsxPath)
}
if ((Get-Item -LiteralPath $BuilderXlsxPath).Length -le 0) {
    Fail ('Builder-OUTPUT-XLSX ist leer: {0}' -f $BuilderXlsxPath)
}

$StartOnlyXlsx = Join-Path $OutDir ("START_ONLY_{0}.xlsx" -f $RunTs)
$PycacheDir = Join-Path $RepoRoot 'tools\__pycache__'

if (Test-Path -LiteralPath $PycacheDir) {
    Remove-Item -LiteralPath $PycacheDir -Recurse -Force -ErrorAction SilentlyContinue
}

$TrimOutput = $null
$TrimExitCode = 0
try {
    $TrimOutput = & $PythonExe -B $TrimScript --input $BuilderXlsxPath --sheet $Sheet --output $StartOnlyXlsx 2>&1
    $TrimExitCode = $LASTEXITCODE
}
finally {
    if (Test-Path -LiteralPath $PycacheDir) {
        Remove-Item -LiteralPath $PycacheDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($TrimExitCode -ne 0) {
    $TrimText = Join-Lines -Lines $TrimOutput
    Fail ('Sheet-Trim fehlgeschlagen: {0}' -f $TrimText)
}

$TrimText = Join-Lines -Lines $TrimOutput
if ([string]::IsNullOrWhiteSpace($TrimText)) {
    Fail 'Sheet-Trim lieferte keine JSON-Antwort.'
}

try {
    $TrimJson = $TrimText | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Fail ('Sheet-Trim-JSON unlesbar: {0}' -f $TrimText)
}

if (-not (Test-Path -LiteralPath $StartOnlyXlsx)) {
    Fail ('START-only-XLSX fehlt: {0}' -f $StartOnlyXlsx)
}
if ((Get-Item -LiteralPath $StartOnlyXlsx).Length -le 0) {
    Fail ('START-only-XLSX ist leer: {0}' -f $StartOnlyXlsx)
}
if ([int]$TrimJson.output_sheet_count -ne 1) {
    Fail ('START-only-Vertrag verletzt: output_sheet_count={0}' -f [int]$TrimJson.output_sheet_count)
}

$OutputSheetNames = @()
if ($null -ne $TrimJson.output_sheet_names) {
    $OutputSheetNames = @($TrimJson.output_sheet_names | ForEach-Object { [string]$_ })
}
if ($OutputSheetNames.Count -ne 1 -or $OutputSheetNames[0] -ne $Sheet) {
    Fail ('START-only-Vertrag verletzt: output_sheet_names={0}' -f ($OutputSheetNames -join ', '))
}

$ExpectedPdfPath = Join-Path $OutDir ("START_ONLY_{0}.pdf" -f $RunTs)
if (Test-Path -LiteralPath $ExpectedPdfPath) {
    Remove-Item -LiteralPath $ExpectedPdfPath -Force
}

$BeforeSnapshot = Get-PdfSnapshot -Root $OutDir
Stop-LibreOfficeProcesses
$ProfileUri = Convert-PathToFileUri -Path $ProfileDir

$SofficeArgs = @(
    ('-env:UserInstallation={0}' -f $ProfileUri),
    '--headless',
    '--invisible',
    '--nologo',
    '--nolockcheck',
    '--nodefault',
    '--norestore',
    '--convert-to', 'pdf:calc_pdf_Export',
    '--outdir', $OutDir,
    $StartOnlyXlsx
)

$SofficeRun = Invoke-NativeProcess -FilePath $SofficePath -ArgumentList $SofficeArgs -StdOutPath $StdOutLog -StdErrPath $StdErrLog
$AfterSnapshot = Get-PdfSnapshot -Root $OutDir

if ([int]$SofficeRun.ExitCode -ne 0) {
    $Msg = ('stdout: {0} || stderr: {1}' -f (($SofficeRun.StdOut | Out-String).Trim()), (($SofficeRun.StdErr | Out-String).Trim())).Trim()
    Fail ('LibreOffice PDF-Export fehlgeschlagen (ExitCode {0}): {1}' -f $SofficeRun.ExitCode, $Msg)
}

$PdfPath = $null
if (Test-Path -LiteralPath $ExpectedPdfPath) {
    $PdfPath = (Resolve-Path -LiteralPath $ExpectedPdfPath).Path
}
else {
    $ChangedPdfs = @(Get-ChangedPdfPaths -Before $BeforeSnapshot -After $AfterSnapshot)
    if ($ChangedPdfs.Count -eq 1) {
        $PdfPath = $ChangedPdfs[0]
    }
}

if ($null -eq $PdfPath) {
    $StdOutText = if ([string]::IsNullOrWhiteSpace($SofficeRun.StdOut)) { '<empty>' } else { $SofficeRun.StdOut.Trim() }
    $StdErrText = if ([string]::IsNullOrWhiteSpace($SofficeRun.StdErr)) { '<empty>' } else { $SofficeRun.StdErr.Trim() }
    Fail ('Kein PDF nach Export. expected={0} || stdout={1} || stderr={2} || stdout_log={3} || stderr_log={4}' -f $ExpectedPdfPath, $StdOutText, $StdErrText, $StdOutLog, $StdErrLog)
}

if (-not (Test-Path -LiteralPath $PdfPath)) {
    Fail ('PDF fehlt: {0}' -f $PdfPath)
}

$PdfItem = Get-Item -LiteralPath $PdfPath
if ($PdfItem.Length -le 0) {
    Fail ('PDF ist leer: {0}' -f $PdfPath)
}

$PdfHash = (Get-FileHash -LiteralPath $PdfPath -Algorithm SHA256).Hash

if (-not $KeepStartOnlyXlsx) {
    Remove-Item -LiteralPath $StartOnlyXlsx -Force
}

$StdOutForReport = if ([string]::IsNullOrWhiteSpace($SofficeRun.StdOut)) { '<empty>' } else { $SofficeRun.StdOut.Trim() }
$StdErrForReport = if ([string]::IsNullOrWhiteSpace($SofficeRun.StdErr)) { '<empty>' } else { $SofficeRun.StdErr.Trim() }

$Result = [ordered]@{
    timestamp                     = $RunTs
    source_xlsx                   = $ResolvedSourceXlsx
    runner_script                 = $RunnerScript
    runner_report                 = $RunnerReportPath
    runner_output_xlsx            = $BuilderXlsxPath
    start_only_xlsx               = $StartOnlyXlsx
    start_only_sheet_count        = [int]$TrimJson.output_sheet_count
    start_only_sheet_names        = $OutputSheetNames
    soffice_path                  = $SofficePath
    libreoffice_profile_dir       = $ProfileDir
    libreoffice_profile_uri       = $ProfileUri
    libreoffice_stdout_log        = $StdOutLog
    libreoffice_stderr_log        = $StdErrLog
    libreoffice_stdout            = $StdOutForReport
    libreoffice_stderr            = $StdErrForReport
    expected_pdf_path             = $ExpectedPdfPath
    discovered_pdf_path           = $PdfPath
    discovered_pdf_sha256         = $PdfHash
    discovered_pdf_length         = $PdfItem.Length
    discovered_pdf_last_write_utc = $PdfItem.LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ')
    contract_source_explicit      = $true
    contract_runner_output_parse  = $true
    contract_runner_contract_scan = $true
    contract_start_only_xlsx      = $true
    contract_lo_prekill           = $true
    contract_lo_isolated_profile  = $true
    contract_lo_full_flags        = $true
    contract_lo_process_logs      = $true
    active_sheet                  = $Sheet
}

$Json = $Result | ConvertTo-Json -Depth 8
Write-Utf8NoBom -Path $JsonPath -Content $Json

$Lines = @(
    '# EXPORT_START_SHEET_ONLY_PDF',
    '',
    ('- timestamp: {0}' -f $RunTs),
    ('- source_xlsx: {0}' -f $ResolvedSourceXlsx),
    ('- runner_output_xlsx: {0}' -f $BuilderXlsxPath),
    ('- start_only_xlsx: {0}' -f $StartOnlyXlsx),
    ('- soffice_path: {0}' -f $SofficePath),
    ('- libreoffice_profile_dir: {0}' -f $ProfileDir),
    ('- libreoffice_stdout_log: {0}' -f $StdOutLog),
    ('- libreoffice_stderr_log: {0}' -f $StdErrLog),
    ('- expected_pdf_path: {0}' -f $ExpectedPdfPath),
    ('- discovered_pdf_path: {0}' -f $PdfPath),
    ('- discovered_pdf_length: {0}' -f $PdfItem.Length),
    ('- discovered_pdf_sha256: {0}' -f $PdfHash),
    '',
    '## VERTRAG',
    '- explizite Source-XLSX: ja',
    '- Runner-Contract real gescannt: ja',
    '- Runner-OUTPUT geparst: ja',
    '- START-only-XLSX erzeugt: ja',
    '- LibreOffice Pre-Kill: ja',
    '- isoliertes Profil: ja',
    '- volle Headless-Flags: ja',
    '- Prozesslogs: ja'
)

Write-Utf8NoBom -Path $ReportPath -Content ($Lines -join [Environment]::NewLine)

Write-Host ('REPORT: {0}' -f $ReportPath)
Write-Host ('JSON: {0}' -f $JsonPath)
Write-Host ('START_ONLY_XLSX: {0}' -f $StartOnlyXlsx)
Write-Host ('OUTPUT_PDF: {0}' -f $PdfPath)
Write-Host ('SOFFICE_PATH: {0}' -f $SofficePath)
Write-Host ('STDOUT_LOG: {0}' -f $StdOutLog)
Write-Host ('STDERR_LOG: {0}' -f $StdErrLog)
Write-Host 'PASS: export-start-sheet-only-pdf'