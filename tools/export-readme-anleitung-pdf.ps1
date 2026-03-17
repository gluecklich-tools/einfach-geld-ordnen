#requires -Version 7.0
param(
    [Parameter(Mandatory = $true)][string]$InputTextPath,
    [Parameter(Mandatory = $true)][string]$OutputPdfPath,
    [string]$DocumentTitle = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Fail([string]$Message) {
    throw ('FAIL: {0}' -f $Message)
}

function Ensure-Directory {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    if (-not (Test-Path -LiteralPath $LiteralPath)) {
        New-Item -ItemType Directory -Path $LiteralPath -Force | Out-Null
    }
}

function Get-BytesSha256Hex {
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)
    $sha256 = [System.Security.Cryptography.SHA256]::HashData($Bytes)
    return ([System.BitConverter]::ToString($sha256)).Replace('-', '')
}

function Get-FileHashHex {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $LiteralPath).Hash
}

function Write-BinaryAndVerify {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][byte[]]$Bytes
    )

    $parent = Split-Path -Parent $LiteralPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        Ensure-Directory -LiteralPath $parent
    }

    [System.IO.File]::WriteAllBytes($LiteralPath, $Bytes)
    $verifyBytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    if ($verifyBytes.Length -ne $Bytes.Length) {
        Fail ('VERIFY_BINARY_LENGTH_FAILED: {0}' -f $LiteralPath)
    }

    $srcHash = Get-BytesSha256Hex -Bytes $Bytes
    $dstHash = Get-BytesSha256Hex -Bytes $verifyBytes
    if ($srcHash -ne $dstHash) {
        Fail ('VERIFY_BINARY_HASH_FAILED: {0}' -f $LiteralPath)
    }
}

function Test-IsUpperHeadingLine {
    param([Parameter(Mandatory = $true)][string]$Line)

    $trimmed = $Line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) { return $false }
    if ($trimmed.Length -gt 80) { return $false }

    $hasLetter = $false
    foreach ($char in $trimmed.ToCharArray()) {
        if ([char]::IsLetter($char)) {
            $hasLetter = $true
            break
        }
    }

    if (-not $hasLetter) { return $false }
    return ($trimmed -ceq $trimmed.ToUpperInvariant())
}

function Wrap-PlainText {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int]$FontSize,
        [Parameter(Mandatory = $true)][double]$UsableWidth
    )

    $chars = [Math]::Max(20, [int][Math]::Floor($UsableWidth / ($FontSize * 0.53)))
    $words = @($Text -split '\s+')
    if (@($words).Count -eq 0) { return @('') }

    $lines = New-Object System.Collections.Generic.List[string]
    $current = ''

    foreach ($word in $words) {
        if ([string]::IsNullOrWhiteSpace($word)) { continue }

        if ([string]::IsNullOrWhiteSpace($current)) {
            $current = $word
            continue
        }

        $candidate = $current + ' ' + $word
        if ($candidate.Length -le $chars) {
            $current = $candidate
        }
        else {
            [void]$lines.Add($current)
            $current = $word
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($current)) {
        [void]$lines.Add($current)
    }

    return @($lines | ForEach-Object { $_ })
}

function New-TextBlock {
    param(
        [Parameter(Mandatory = $true)][string]$Kind,
        [Parameter(Mandatory = $true)][string[]]$Lines,
        [Parameter(Mandatory = $true)][double]$Left,
        [Parameter(Mandatory = $true)][int]$Size,
        [Parameter(Mandatory = $true)][int]$Leading,
        [Parameter(Mandatory = $true)][string]$Font,
        [Parameter(Mandatory = $true)][int]$SpaceAfter
    )

    return [pscustomobject]@{
        kind = $Kind
        lines = @($Lines)
        left = $Left
        size = $Size
        leading = $Leading
        font = $Font
        space_after = $SpaceAfter
    }
}

function Build-TextBlocks {
    param(
        [Parameter(Mandatory = $true)][object[]]$Lines,
        [Parameter(Mandatory = $false)][string]$DocumentTitle
    )

    $pageW = 595.28
    $marginLeft = 54.0
    $marginRight = 54.0
    $usableW = $pageW - $marginLeft - $marginRight

    $blocks = @()
    $titleWritten = $false

    if (-not [string]::IsNullOrWhiteSpace($DocumentTitle)) {
        $blocks += ,(New-TextBlock -Kind 'title' -Lines @($DocumentTitle.Trim()) -Left $marginLeft -Size 20 -Leading 26 -Font 'F2' -SpaceAfter 6)
        $titleWritten = $true
    }

    foreach ($raw in @($Lines)) {
        $line = [string]$raw
        $trimmed = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }

        if (-not $titleWritten) {
            $blocks += ,(New-TextBlock -Kind 'title' -Lines @($trimmed) -Left $marginLeft -Size 20 -Leading 26 -Font 'F2' -SpaceAfter 6)
            $titleWritten = $true
            continue
        }

        if (Test-IsUpperHeadingLine -Line $trimmed) {
            $blocks += ,(New-TextBlock -Kind 'heading' -Lines @($trimmed) -Left $marginLeft -Size 13 -Leading 19 -Font 'F2' -SpaceAfter 4)
            continue
        }

        if ($trimmed.StartsWith('- ')) {
            $text = $trimmed.Substring(2).Trim()
            $wrapped = @(Wrap-PlainText -Text $text -FontSize 11 -UsableWidth ($usableW - 22))
            $bulletLines = @()
            $bulletLines += ('- ' + $wrapped[0])
            foreach ($item in @($wrapped | Select-Object -Skip 1)) {
                $bulletLines += ('  ' + [string]$item)
            }

            $blocks += ,(New-TextBlock -Kind 'bullet' -Lines $bulletLines -Left ($marginLeft + 10) -Size 11 -Leading 14 -Font 'F1' -SpaceAfter 2)
            continue
        }

        if ($trimmed -match '^\d+\.\s+') {
            $firstDot = $trimmed.IndexOf('.')
            $prefix = $trimmed.Substring(0, $firstDot + 1)
            $text = $trimmed.Substring($firstDot + 1).Trim()
            $wrapped = @(Wrap-PlainText -Text $text -FontSize 11 -UsableWidth ($usableW - 26))
            $numberLines = @()
            $numberLines += ($prefix + ' ' + $wrapped[0])
            foreach ($item in @($wrapped | Select-Object -Skip 1)) {
                $numberLines += ('   ' + [string]$item)
            }

            $blocks += ,(New-TextBlock -Kind 'number' -Lines $numberLines -Left ($marginLeft + 10) -Size 11 -Leading 14 -Font 'F1' -SpaceAfter 2)
            continue
        }

        $wrappedBody = @(Wrap-PlainText -Text $trimmed -FontSize 11 -UsableWidth $usableW)
        $blocks += ,(New-TextBlock -Kind 'body' -Lines $wrappedBody -Left $marginLeft -Size 11 -Leading 14 -Font 'F1' -SpaceAfter 2)
    }

    if (-not $titleWritten) {
        Fail 'no usable title/content found in input text'
    }

    return @($blocks)
}

function Paginate-Blocks {
    param([Parameter(Mandatory = $true)][object[]]$Blocks)

    $pageH = 841.89
    $marginTop = 56.0
    $marginBottom = 56.0

    $pages = @()
    $currentPage = @()
    $y = $pageH - $marginTop

    foreach ($block in @($Blocks)) {
        $lineCount = @($block.lines).Count
        $required = ($lineCount * [int]$block.leading) + [int]$block.space_after

        if (($y - $required) -lt $marginBottom) {
            if (@($currentPage).Count -gt 0) {
                $pages += ,(@($currentPage))
            }
            $currentPage = @()
            $y = $pageH - $marginTop
        }

        foreach ($line in @($block.lines)) {
            $currentPage += ,([pscustomobject]@{
                font = [string]$block.font
                size = [int]$block.size
                x = [double]$block.left
                y = [double]$y
                text = [string]$line
            })
            $y -= [int]$block.leading
        }

        $y -= [int]$block.space_after
    }

    if (@($currentPage).Count -gt 0) {
        $pages += ,(@($currentPage))
    }

    return @($pages)
}

function Escape-PdfTextBytes {
    param([Parameter(Mandatory = $true)][string]$Text)

    $safe = $Text.Replace('\', '\\').Replace('(', '\(').Replace(')', '\)')
    $enc = [System.Text.Encoding]::GetEncoding(1252)
    return $enc.GetBytes($safe)
}

function Render-PdfPageStreamBytes {
    param([Parameter(Mandatory = $true)][object[]]$PageRows)

    $buffer = New-Object System.IO.MemoryStream
    foreach ($row in @($PageRows)) {
        $prefix = ('BT /{0} {1} Tf 1 0 0 1 {2} {3} Tm (' -f $row.font, $row.size, ([string]::Format([System.Globalization.CultureInfo]::InvariantCulture, '{0:0.00}', $row.x)), ([string]::Format([System.Globalization.CultureInfo]::InvariantCulture, '{0:0.00}', $row.y)))
        $suffix = ') Tj ET' + "`n"
        $prefixBytes = [System.Text.Encoding]::ASCII.GetBytes($prefix)
        $textBytes = Escape-PdfTextBytes -Text $row.text
        $suffixBytes = [System.Text.Encoding]::ASCII.GetBytes($suffix)
        $buffer.Write($prefixBytes, 0, $prefixBytes.Length)
        $buffer.Write($textBytes, 0, $textBytes.Length)
        $buffer.Write($suffixBytes, 0, $suffixBytes.Length)
    }

    return $buffer.ToArray()
}

function Build-PdfBytes {
    param([Parameter(Mandatory = $true)][object[]]$Pages)

    $pageW = 595.28
    $pageH = 841.89

    $objects = @{}
    $objects[1] = [System.Text.Encoding]::ASCII.GetBytes('<< /Type /Catalog /Pages 2 0 R >>')
    $objects[3] = [System.Text.Encoding]::ASCII.GetBytes('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>')
    $objects[4] = [System.Text.Encoding]::ASCII.GetBytes('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>')

    $pageRefs = @()
    $nextNum = 5
    $pageIndex = 0

    foreach ($page in @($Pages)) {
        $pageIndex++
        $pageRows = @($page)
        $pageRows += ,([pscustomobject]@{
            font = 'F1'
            size = 9
            x = 500.0
            y = 28.0
            text = ('Seite {0} von {1}' -f $pageIndex, @($Pages).Count)
        })

        $contentNum = $nextNum
        $pageNum = $nextNum + 1
        $nextNum += 2

        $streamBytes = Render-PdfPageStreamBytes -PageRows $pageRows
        $streamHeader = [System.Text.Encoding]::ASCII.GetBytes(('<< /Length {0} >>' -f $streamBytes.Length) + "`nstream`n")
        $streamFooter = [System.Text.Encoding]::ASCII.GetBytes("endstream")
        $combinedStream = New-Object System.IO.MemoryStream
        $combinedStream.Write($streamHeader, 0, $streamHeader.Length)
        $combinedStream.Write($streamBytes, 0, $streamBytes.Length)
        $newlineBytes = [System.Text.Encoding]::ASCII.GetBytes("`n")
        $combinedStream.Write($newlineBytes, 0, $newlineBytes.Length)
        $combinedStream.Write($streamFooter, 0, $streamFooter.Length)
        $objects[$contentNum] = $combinedStream.ToArray()

        $pageObjText = ('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {0} {1}] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents {2} 0 R >>' -f ([string]::Format([System.Globalization.CultureInfo]::InvariantCulture, '{0:0.00}', $pageW)), ([string]::Format([System.Globalization.CultureInfo]::InvariantCulture, '{0:0.00}', $pageH)), $contentNum)
        $objects[$pageNum] = [System.Text.Encoding]::ASCII.GetBytes($pageObjText)
        $pageRefs += ('{0} 0 R' -f $pageNum)
    }

    $kids = [string]::Join(' ', @($pageRefs))
    $objects[2] = [System.Text.Encoding]::ASCII.GetBytes(('<< /Type /Pages /Count {0} /Kids [ {1} ] >>' -f @($pageRefs).Count, $kids))

    $pdf = New-Object System.IO.MemoryStream
    $header = [byte[]](37,80,68,70,45,49,46,52,10,37,226,227,207,211,10)
    $pdf.Write($header, 0, $header.Length)

    $offsets = @{}
    for ($objNum = 1; $objNum -lt $nextNum; $objNum++) {
        $offsets[$objNum] = [int64]$pdf.Length
        $objStart = [System.Text.Encoding]::ASCII.GetBytes(('{0} 0 obj' -f $objNum) + "`n")
        $objEnd = [System.Text.Encoding]::ASCII.GetBytes("`nendobj`n")
        $objBytes = [byte[]]$objects[$objNum]
        $pdf.Write($objStart, 0, $objStart.Length)
        $pdf.Write($objBytes, 0, $objBytes.Length)
        $pdf.Write($objEnd, 0, $objEnd.Length)
    }

    $xrefPos = [int64]$pdf.Length
    $xrefHeader = [System.Text.Encoding]::ASCII.GetBytes(('xref' + "`n" + '0 ' + $nextNum + "`n"))
    $pdf.Write($xrefHeader, 0, $xrefHeader.Length)
    $firstXref = [System.Text.Encoding]::ASCII.GetBytes("0000000000 65535 f `n")
    $pdf.Write($firstXref, 0, $firstXref.Length)

    for ($objNum = 1; $objNum -lt $nextNum; $objNum++) {
        $line = '{0:0000000000} 00000 n ' -f [int64]$offsets[$objNum]
        $lineBytes = [System.Text.Encoding]::ASCII.GetBytes($line + "`n")
        $pdf.Write($lineBytes, 0, $lineBytes.Length)
    }

    $trailer = [System.Text.Encoding]::ASCII.GetBytes(('trailer' + "`n" + '<< /Size ' + $nextNum + ' /Root 1 0 R >>' + "`n" + 'startxref' + "`n" + $xrefPos + "`n" + '%%EOF' + "`n"))
    $pdf.Write($trailer, 0, $trailer.Length)

    return $pdf.ToArray()
}

if (-not (Test-Path -LiteralPath $InputTextPath)) {
    Fail ('InputTextPath missing: {0}' -f $InputTextPath)
}

$Lines = @([System.IO.File]::ReadAllLines($InputTextPath, [System.Text.Encoding]::UTF8))
$NonEmptyLines = @($Lines | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
if (@($NonEmptyLines).Count -lt 2) {
    Fail ('input text too small/unexpected: {0}' -f $InputTextPath)
}

$Blocks = @(Build-TextBlocks -Lines $Lines -DocumentTitle $DocumentTitle)
$Pages = @(Paginate-Blocks -Blocks $Blocks)
if (@($Pages).Count -eq 0) {
    Fail 'PDF pagination produced zero pages.'
}

$PdfBytes = Build-PdfBytes -Pages $Pages
if ($PdfBytes.Length -le 0) {
    Fail 'generated PDF bytes are empty.'
}

Write-BinaryAndVerify -LiteralPath $OutputPdfPath -Bytes $PdfBytes

$OutputHash = Get-FileHashHex -LiteralPath $OutputPdfPath
$InputHash = Get-FileHashHex -LiteralPath $InputTextPath

Write-Host ('INPUT_TEXT: {0}' -f (Resolve-Path -LiteralPath $InputTextPath).Path)
Write-Host ('INPUT_TEXT_SHA256: {0}' -f $InputHash)
Write-Host ('OUTPUT_PDF: {0}' -f (Resolve-Path -LiteralPath $OutputPdfPath).Path)
Write-Host ('OUTPUT_PDF_HASH: {0}' -f $OutputHash)
Write-Host ('PAGE_COUNT: {0}' -f @($Pages).Count)
Write-Host 'BACKEND: self-contained powershell pdf emitter'
Write-Host 'PASS: export readme anleitung pdf'
