# ALLOW_REGEX_PATCH (temporary; must be removed when refactored to literal/AST patching)
param(
  [Parameter(Mandatory=$false)][string]$BaseUrl = 'https://gluecklich-tools.github.io/einfach-geld-ordnen',
  [Parameter(Mandatory=$false)][switch]$NoCache,
  [Parameter(Mandatory=$false)][ValidateSet('Head','Get','HeadGet')][string]$Mode = 'Head',
  [Parameter(Mandatory=$false)][int]$TimeoutSec = 25,
  [Parameter(Mandatory=$false)][int]$MaxRedirect = 0,
  [Parameter(Mandatory=$false)][switch]$DebugUrls,

  # IMPORTANT: put Paths LAST and swallow any remaining args to avoid binding-shift bugs
  [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)][string[]]$Paths
)

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

# Live-Probe Tool (pwsh-first, StrictMode-safe, no crash on 404/3xx)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
try { chcp 65001 | Out-Null } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Clean-Str([string]$s){
  if($null -eq $s){ return '' }
  $t = $s.Trim()
  $t = $t -replace [char]0x00A0, ' '
  $t = $t -replace '[\u200B-\u200D\uFEFF]', ''
  return $t.Trim()
}

function Normalize-Base([string]$u){
  $x = Clean-Str $u
  if([string]::IsNullOrWhiteSpace($x)){ throw 'STOP: BaseUrl empty.' }
  if($x.EndsWith('/')){ $x = $x.TrimEnd('/') }

  $uri = $null
  if(-not [uri]::TryCreate($x, [UriKind]::Absolute, [ref]$uri)){
    throw ("STOP: BaseUrl must be absolute (https://...). Got: [" + $x + "]")
  }
  if($uri.Scheme -ne 'http' -and $uri.Scheme -ne 'https'){
    throw ("STOP: BaseUrl scheme must be http/https. Got: [" + $uri.Scheme + "] in [" + $x + "]")
  }
  return $uri.AbsoluteUri.TrimEnd('/')
}

function New-NoCacheQS(){ 'nocache=' + [guid]::NewGuid().ToString('N') }

function Join-Url([string]$base,[string]$path,[bool]$nocache){
  $b = Normalize-Base $base
  $p0 = Clean-Str $path
  if([string]::IsNullOrWhiteSpace($p0)){ throw 'STOP: empty path.' }

  $p = $p0
  if(-not $p.StartsWith('/')){ $p = '/' + $p }

  $u = $b + $p
  if($nocache){
    if($u -match '\?'){ $u += '&' + (New-NoCacheQS) }
    else { $u += '?' + (New-NoCacheQS) }
  }

  $uri = $null
  if(-not [uri]::TryCreate($u, [UriKind]::Absolute, [ref]$uri)){
    throw ("STOP: Invalid URI built: [" + $u + "]")
  }
  return $uri.AbsoluteUri
}

function Get-HdrValue($Headers,[string]$Name){
  if(-not $Headers){ return '' }
  try{
    if($Headers -is [System.Net.Http.Headers.HttpHeaders]){
      $vals=$null
      if($Headers.TryGetValues($Name,[ref]$vals)){ return (@($vals) -join ', ') }
      return ''
    }
    $m=$Headers.GetType().GetMethod('GetValues',[type[]]@([string]))
    if($m){
      $vals=$m.Invoke($Headers,@($Name))
      return (@($vals) -join ', ')
    }
    if($Headers.PSObject.Properties.Name -contains $Name){
      return (@($Headers.$Name) -join ', ')
    }
    return ''
  } catch { return '' }
}

function Req([ValidateSet('Head','Get')][string]$Method,[string]$Url){
  $common = @{
    Uri = $Url
    Method = $Method
    MaximumRedirection = $MaxRedirect
    SkipHttpErrorCheck = $true
    TimeoutSec = $TimeoutSec
    ErrorAction = 'Stop'
  }
  $r = Invoke-WebRequest @common
  $hdr = $r.Headers
  [pscustomobject]([ordered]@{
    Method       = $Method
    Status       = [int]$r.StatusCode
    Location     = (Get-HdrValue $hdr 'Location')
    ETag         = (Get-HdrValue $hdr 'ETag')
    LastModified = (Get-HdrValue $hdr 'Last-Modified')
    ContentType  = (Get-HdrValue $hdr 'Content-Type')
    Url          = $Url
  })
}

# --- Paths normalize (robust for comma-list + quoted items) ---
if($null -ne $Paths -and $Paths.Count -eq 1 -and $Paths[0] -match ','){
  $Paths = @($Paths[0] -split '\s*,\s*')
}
if($null -ne $Paths){
  $Paths = @($Paths) | ForEach-Object {
    $s = Clean-Str $_
    # strip surrounding single/double quotes if user passed them literally
    $s = $s.Trim()
    if($s.Length -ge 2){
      if(($s.StartsWith("'") -and $s.EndsWith("'")) -or ($s.StartsWith('"') -and $s.EndsWith('"'))){
        $s = $s.Substring(1,$s.Length-2)
      }
    }
    Clean-Str $s
  } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}
# --- end normalize ---
$baseClean = Normalize-Base $BaseUrl

if($null -eq $Paths -or $Paths.Count -eq 0){
  $Paths = @('/seiten/rechner-uebersicht.html','/seiten/rechner-uebersicht.html')
} else {
  $Paths = @($Paths) | ForEach-Object { Clean-Str $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

$nocache = [bool]$NoCache
$urls = foreach($p in $Paths){ Join-Url -base $baseClean -path $p -nocache $nocache }

if($DebugUrls){
  "BASE: $baseClean"
  "PATHS:"
  foreach($p in $Paths){ "  $p" }
  "URLS:"
  foreach($u in $urls){ "  $u" }
  ""
}

$rows = @()
foreach($u in $urls){
  if($Mode -eq 'Head' -or $Mode -eq 'HeadGet'){ $rows += Req -Method 'Head' -Url $u }
  if($Mode -eq 'Get'  -or $Mode -eq 'HeadGet'){ $rows += Req -Method 'Get'  -Url $u }
}

$rows | Format-Table -AutoSize
