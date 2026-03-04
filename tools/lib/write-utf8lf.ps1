#requires -Version 7.0
param()

function Write-Utf8LfNoBom {
  param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][string]$Text
  )
  $lf = $Text -replace "`r`n", "`n"
  $enc = [System.Text.UTF8Encoding]::new($false)
  [System.IO.File]::WriteAllBytes($Path, $enc.GetBytes($lf))
}