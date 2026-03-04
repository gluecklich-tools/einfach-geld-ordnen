#requires -Version 7.0
[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$Repo,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$OutJson,

  # Backward-compat alias
  [Alias("RepoRoot")]
  [string]$RepoRootCompat = ""
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Resolve-Repo([string]$Repo){
  return (Resolve-Path -LiteralPath $Repo).Path
}

function Ensure-Dir([string]$path){
  $dir = Split-Path -Parent $path
  if($dir -and !(Test-Path -LiteralPath $dir)){
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
}

function Write-Utf8NoBom([string]$Path,[string]$Text){
  Ensure-Dir $Path
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $t = $Text.Replace("`r`n","`n")
  [System.IO.File]::WriteAllText($Path,$t,$utf8)
}

$repo = Resolve-Repo $Repo

$downloads = Join-Path $repo "downloads"
$bundles   = Join-Path $downloads "bundles"

$findings = New-Object System.Collections.Generic.List[object]
function Add([string]$Level,[string]$Code,[string]$Message,[string]$Path){
  $findings.Add([pscustomobject]@{ level=$Level; code=$Code; message=$Message; path=$Path })
}

if(!(Test-Path -LiteralPath $downloads)){
  Add "WARN" "DOWNLOADS_MISSING" "downloads/ folder missing" $downloads
} elseif(!(Test-Path -LiteralPath $bundles)){
  Add "WARN" "BUNDLES_DIR_MISSING" "downloads/bundles/ folder missing" $bundles
} else {
  $zips = Get-ChildItem -LiteralPath $bundles -File -Filter "*.zip" -ErrorAction Stop
  if(@($zips).Count -eq 0){
    Add "WARN" "NO_ZIPS" "No bundle ZIPs found in downloads/bundles" $bundles
  } else {
    foreach($z in $zips){
      $n = $z.Name
      $tier="UNKNOWN"
      if($n -match '(?i)freebie'){ $tier="FREEBIE" }
      elseif($n -match '(?i)\bpro\b'){ $tier="PRO" }
      elseif($n -match '(?i)voll|full'){ $tier="VOLL" }

      if($tier -eq "UNKNOWN"){ Add "WARN" "TIER_UNKNOWN" "Bundle tier not recognized from filename" $z.FullName }
      if($z.Length -lt 10240){ Add "WARN" "ZIP_TOO_SMALL" "ZIP is unusually small (<10KB)" $z.FullName }
      if($n -match '(?i)placeholder'){ Add "WARN" "PLACEHOLDER_ZIP" "ZIP filename suggests placeholder" $z.FullName }
    }
  }
}

$result=[pscustomobject]@{
  repo=$repo
  bundlesDir=$bundles
  findings=@($findings)
}

$json = $result | ConvertTo-Json -Depth 6
Write-Utf8NoBom -Path $OutJson -Text ($json + "`n")

Write-Output ("OK: wrote " + $OutJson)