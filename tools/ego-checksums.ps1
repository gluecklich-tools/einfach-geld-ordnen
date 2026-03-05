# ALLOW_REGEX_PATCH (temporary; must be removed when refactored to literal/AST patching)
param(
  [Parameter(Mandatory=$true)]
  [string]$OutDir
)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
Set-Location -LiteralPath $root
function Write-TextIfChanged {
  param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$Text)
# --- EOL_NORMALIZE_TEXT_START ---
# Force LF-only output for all generated text files (prevents CRLF warnings)
if ($null -ne $Text) {
  $Text = $Text -replace "`r`n", "`n"
  $Text = $Text -replace "`r", "`n"
}
# --- EOL_NORMALIZE_TEXT_END ---

  $enc = New-Object System.Text.UTF8Encoding($false)
  $old = $null
  if (Test-Path -LiteralPath $Path) { $old = [System.IO.File]::ReadAllText($Path, $enc) }
  if ($old -ne $Text) { [System.IO.File]::WriteAllText($Path, $Text, $enc); return $true }
  return $false
}
function Get-DownloadFiles {
  $roots = @(
    (Join-Path $root 'assets\downloads'),
    (Join-Path $root 'downloads')
  )
  $ext = @('*.zip','*.pdf','*.ods','*.xlsx','*.xlsm','*.csv')
  $files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
  foreach ($r in $roots) {
    if (Test-Path -LiteralPath $r) {
      foreach ($e in $ext) {
        # IMPORTANT: force to array => never $null => AddRange is safe
        $items = @(
          Get-ChildItem -LiteralPath $r -Recurse -File -Filter $e -ErrorAction SilentlyContinue
        )
        if ($items.Count -gt 0) {                                   # FIX: AddRange requires IEnumerable[FileInfo] (avoid System.Object[])
                                  $__src = @($items)
                                  $__tmp = @()
                                  foreach($x in $__src){
                                    if($null -eq $x){ continue }
                                    if($x -is [System.IO.FileInfo]){ $__tmp += $x; continue }
                                    if($x -is [string]){ $__tmp += (Get-Item -LiteralPath $x -ErrorAction Stop); continue }
                                    if($x.PSObject -and ($x.PSObject.Properties.Name -contains 'FullName')){ $__tmp += (Get-Item -LiteralPath $x.FullName -ErrorAction Stop); continue }
                                  }
                                                                    # FIX: AddRange requires IEnumerable[FileInfo] (avoid System.Object[])
                                  $__src = @($__tmp)
                                  $__tmp = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'
                                  foreach($x in $__src){
                                    if($null -eq $x){ continue }
                                    if($x -is [System.IO.FileInfo]){ $__tmp.Add($x); continue }
                                    if($x -is [string]){
                                      $it = Get-Item -LiteralPath $x -ErrorAction Stop
                                      if($it -is [System.IO.FileInfo]){ $__tmp.Add($it) }
                                      continue
                                    }
                                    if($x.PSObject -and ($x.PSObject.Properties.Name -contains 'FullName')){
                                      $it = Get-Item -LiteralPath $x.FullName -ErrorAction Stop
                                      if($it -is [System.IO.FileInfo]){ $__tmp.Add($it) }
                                      continue
                                    }
                                  }
                                  $files.AddRange($__tmp) }
      }
    }
  }
  $files | Sort-Object FullName -Unique
}
if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }
$dl = Get-DownloadFiles
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# SHA-256 checksums")
$lines.Add(("generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")))
$lines.Add("")
foreach ($f in $dl) {
  $h = (Get-FileHash -Algorithm SHA256 -LiteralPath $f.FullName).Hash.ToLowerInvariant()
  $rel = $f.FullName.Replace($root + [char]92,'')
  $lines.Add(($h + "  " + $rel))
}
$txt = ($lines -join "`r`n") + "`r`n"
$changed = Write-TextIfChanged -Path (Join-Path $OutDir 'checksums.txt') -Text $txt
if ($changed) { "CHECKSUMS_CHANGED=1" } else { "CHECKSUMS_CHANGED=0" }