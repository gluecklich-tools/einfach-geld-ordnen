#requires -Version 7.0
param()
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ Remove-Module PSReadLine -ErrorAction SilentlyContinue }catch{}
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
function Resolve-RepoRoot {
  try{
    $t = (git rev-parse --show-toplevel 2>$null)
    if($t){ return $t.Trim() }
  }catch{}
  return (Resolve-Path -LiteralPath ".").Path
}
$Repo = (Resolve-Path -LiteralPath (Resolve-RepoRoot)).Path
$ToolsDir = Join-Path $Repo "tools"
if(-not (Test-Path -LiteralPath $ToolsDir)){ throw "STOP: tools/ not found." }
$OutDir = Join-Path (Join-Path (Join-Path $Repo "assets") "audit") "runs"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$ts = (Get-Date -Format "yyyyMMdd_HHmmss_fff")
$ReportPath = Join-Path $OutDir ("TOOLS_REGISTRY_{0}.md" -f $ts)
$files = @(Get-ChildItem -LiteralPath $ToolsDir -File -Filter "*.ps1" -ErrorAction Stop | Sort-Object Name)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Tools Registry (Repo/tools)") | Out-Null
$lines.Add(("Generated: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))) | Out-Null
$lines.Add(("Repo: {0}" -f $Repo)) | Out-Null
$lines.Add("") | Out-Null
foreach($f in $files){
  $lines.Add(("- tools/{0} ({1} bytes)" -f @($f.Name, $f.Length)) | Out-Null)
}
[IO.File]::WriteAllText($ReportPath, ($lines -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
"OK: Wrote report = $ReportPath"
