#requires -Version 7.0
param(
  [string]$GovDir   = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\_INTERN\governance",
  [string]$BrainDir = "C:\Users\carst\Projekte\Einfach-Geld-Ordnen\Brain_EGO_Dateien"
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
function WriteUtf8NoBom([string]$Path, [string]$Content){
  $dir = Split-Path -Parent $Path
  if($dir -and !(Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}
function Sha256File([string]$Path){
  return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
if(!(Test-Path -LiteralPath $GovDir)){ throw "STOP: GovDir missing: $GovDir" }
if(!(Test-Path -LiteralPath $BrainDir)){ New-Item -ItemType Directory -Path $BrainDir -Force | Out-Null }
$docs = @(
  "BOOTSTRAP_INTERNAL.md",
  "GOVERNANCE_INTERNAL.md",
  "QA_GATE_INTERNAL.md",
  "LEARNINGS_INTERNAL.md",
  "ROADMAP_INTERNAL.md"
)
# Ensure folders
$latest = Join-Path $BrainDir "latest"
$snapshots = Join-Path $BrainDir "snapshots"
$reports = Join-Path $BrainDir "_reports"
foreach($d in @($latest,$snapshots,$reports)){
  if(!(Test-Path -LiteralPath $d)){ New-Item -ItemType Directory -Path $d -Force | Out-Null }
}
$now = Get-Date
$stamp = $now.ToString("yyyyMMdd_HHmmss")
$snapDir = Join-Path $snapshots $stamp
New-Item -ItemType Directory -Path $snapDir -Force | Out-Null
# Build manifest
$filesObj = [ordered]@{}
$writes = New-Object System.Collections.Generic.List[string]
foreach($name in $docs){
  $p = Join-Path $GovDir $name
  if(!(Test-Path -LiteralPath $p)){ throw "STOP: missing SSOT doc: $p" }
  $hash = Sha256File $p
  $filesObj[$name] = $hash
  Copy-Item -LiteralPath $p -Destination (Join-Path $latest $name) -Force
  Copy-Item -LiteralPath $p -Destination (Join-Path $snapDir $name) -Force
  $writes.Add((Join-Path $latest $name)) | Out-Null
  $writes.Add((Join-Path $snapDir $name)) | Out-Null
}
$manifestPath = Join-Path $GovDir "SSOT_MANIFEST_INTERNAL.json"
$manifest = [ordered]@{
  updated = $now.ToString("o")
  files = $filesObj
} | ConvertTo-Json -Depth 10
WriteUtf8NoBom $manifestPath ($manifest.Trim() + "`n")
$writes.Add($manifestPath) | Out-Null
# Minimal report (stdout)
[pscustomobject]@{
  Ok = $true
  GovDir = $GovDir
  BrainDir = $BrainDir
  SnapshotDir = $snapDir
  Writes = $writes.ToArray()
}
