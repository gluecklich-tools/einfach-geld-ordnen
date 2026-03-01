param(
  [Parameter(Mandatory)][string]$SiteUrl,
  [Parameter(Mandatory)][object[]]$Checks,
  [int]$TimeoutSec = 20,
  [int]$MaxUrls = 0,
  [string[]]$IgnorePatterns = @()
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function NormalizeUrl([string]$base,[string]$path){
  $b = $base.TrimEnd('/')
  $p = $path
  if([string]::IsNullOrWhiteSpace($p)){ $p='/' }
  if(-not $p.StartsWith('/')){ $p='/' + $p }
  return ($b + $p)
}

function ShouldIgnore([string]$url,[string[]]$patterns){
  foreach($pat in $patterns){
    if([string]::IsNullOrWhiteSpace($pat)){ continue }
    if($url -like $pat){ return $true }
  }
  return $false
}

$fail = New-Object System.Collections.Generic.List[string]

foreach($c in $Checks){
  $path = [string]$c.Path
  $expect = @($c.Expect) | ForEach-Object { [int]$_ }
  $url = NormalizeUrl $SiteUrl $path

  if(ShouldIgnore $url $IgnorePatterns){ continue }

  try{
    $resp = Invoke-WebRequest -Uri $url -Method GET -MaximumRedirection 0 -TimeoutSec $TimeoutSec -UseBasicParsing
    $code = [int]$resp.StatusCode
  } catch {
    $code = $null
    try{
      $r = $_.Exception.Response
      if($null -ne $r -and $r.StatusCode){ $code = [int]$r.StatusCode }
    }catch{}
    if($null -eq $code){
      $fail.Add("NO_RESPONSE: $url :: $($_.Exception.Message)")
      continue
    }
  }

  if($expect -notcontains $code){
    $fail.Add("BAD_STATUS: $url :: got=$code expect=$($expect -join ',')")
  } else {
    "OK: $code $url"
  }
}

if($fail.Count -gt 0){
  "FAIL: SMOKE_HTTP"
  $fail | ForEach-Object { " - $_" }
  exit 3
}

"PASS: SMOKE_HTTP"
exit 0