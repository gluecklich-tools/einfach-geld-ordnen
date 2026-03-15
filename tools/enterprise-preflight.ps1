param(
  [switch]$SkipToolParse
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

if(-not (Test-Path -LiteralPath ".\_config.yml")){ Fail "Not in repo root (missing _config.yml)." }
if(-not (Test-Path -LiteralPath ".\tools")){ Fail "Missing tools folder." }

if(-not $SkipToolParse){
  $tools = New-Object System.Collections.Generic.List[System.IO.FileInfo]

  $trackedToolFiles = @(
    git -C . ls-files -- 'tools/*.ps1'
  )

  foreach($rel in $trackedToolFiles){
    if([string]::IsNullOrWhiteSpace($rel)){ continue }
    $full = Join-Path (Get-Location).Path $rel
    if(-not (Test-Path -LiteralPath $full -PathType Leaf)){ continue }
    $tools.Add((Get-Item -LiteralPath $full)) | Out-Null
  }

  $tools = @($tools | Sort-Object FullName -Unique)

  foreach($f in $tools){
    $t = $null
    $e = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName,[ref]$t,[ref]$e)
    if($e -and $e.Count -gt 0){
      Fail ("ParserError in tools file: {0} | {1}" -f $f.Name, $e[0].Message)
    }
  }
}

"ENTERPRISE_PREFLIGHT_OK"