param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$tools = Join-Path $RepoRoot "tools"
$preflight = Join-Path $tools "enterprise-preflight.ps1"
$smokeTool = Join-Path $tools "smoke-http.ps1"
$smokeCfg  = Join-Path $tools "smoke-checks.json"

if(!(Test-Path -LiteralPath $preflight)){ Fail "Missing: tools/enterprise-preflight.ps1" }
if(!(Test-Path -LiteralPath $smokeTool)){ Fail "Missing: tools/smoke-http.ps1" }
if(!(Test-Path -LiteralPath $smokeCfg)){  Fail "Missing: tools/smoke-checks.json" }

# 1) Preflight (all gates)
& $preflight -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed (exit=$LASTEXITCODE)" }

# 2) Load smoke config
$cfg = Get-Content -LiteralPath $smokeCfg -Encoding UTF8 | Out-String | ConvertFrom-Json
$site = [string]$cfg.SiteUrl
$mode = [string]$cfg.Mode
$max  = [int]$cfg.MaxUrls
$ignore = @($cfg.IgnorePatterns)

$checks = New-Object System.Collections.Generic.List[object]

# Core always
foreach($c in @($cfg.CoreChecks)){ $checks.Add($c) }

if($mode -eq "sitemap_all"){
  $sitemapUrl = ($site.TrimEnd('/') + ([string]$cfg.SitemapPath))
  try{
    $xml = Invoke-WebRequest -Uri $sitemapUrl -Method GET -TimeoutSec 30 -UseBasicParsing
    $content = [xml]$xml.Content
  } catch {
    Fail "STOP: sitemap fetch failed: $sitemapUrl :: $($_.Exception.Message)"
  }

  $locs = @()  # handle sitemapindex or urlset (StrictMode-safe + namespace-safe)
  $root = $content.DocumentElement
  if(-not $root){
    Fail "STOP: sitemap xml has no DocumentElement (empty/invalid xml?)"
  }
  $rootName = [string]$root.LocalName

  $ns = New-Object System.Xml.XmlNamespaceManager($content.NameTable)
  $ns.AddNamespace('sm','http://www.sitemaps.org/schemas/sitemap/0.9')

  $locNodes = @()

  if($rootName -eq 'sitemapindex'){
    $locNodes = @($content.SelectNodes('//sm:sitemap/sm:loc', $ns))
    if($locNodes.Count -eq 0){
      $locNodes = @($content.SelectNodes('//sitemap/loc'))
    }

    foreach($n in $locNodes){
      $u = [string]$n.InnerText
      if([string]::IsNullOrWhiteSpace($u)){ continue }
      $locs += $u
    }

    # fetch each sitemap in index
    $urlLocs = New-Object System.Collections.Generic.List[string]
    foreach($smUrl in $locs){
      try{
        $x = Invoke-WebRequest -Uri $smUrl -Method GET -TimeoutSec 30 -UseBasicParsing
        $sx = [xml]$x.Content

        $sxRoot = $sx.DocumentElement
        if(-not $sxRoot){
          Fail "STOP: sitemap part has no DocumentElement: $smUrl"
        }

        $sxNs = New-Object System.Xml.XmlNamespaceManager($sx.NameTable)
        $sxNs.AddNamespace('sm','http://www.sitemaps.org/schemas/sitemap/0.9')

        $uNodes = @($sx.SelectNodes('//sm:url/sm:loc', $sxNs))
        if($uNodes.Count -eq 0){
          $uNodes = @($sx.SelectNodes('//url/loc'))
        }

        foreach($n in $uNodes){
          $l = [string]$n.InnerText
          if(-not [string]::IsNullOrWhiteSpace($l)){ $urlLocs.Add($l) }
        }
      } catch {
        $msg = param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$tools = Join-Path $RepoRoot "tools"
$preflight = Join-Path $tools "enterprise-preflight.ps1"
$smokeTool = Join-Path $tools "smoke-http.ps1"
$smokeCfg  = Join-Path $tools "smoke-checks.json"

if(!(Test-Path -LiteralPath $preflight)){ Fail "Missing: tools/enterprise-preflight.ps1" }
if(!(Test-Path -LiteralPath $smokeTool)){ Fail "Missing: tools/smoke-http.ps1" }
if(!(Test-Path -LiteralPath $smokeCfg)){  Fail "Missing: tools/smoke-checks.json" }

# 1) Preflight (all gates)
& $preflight -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed (exit=$LASTEXITCODE)" }

# 2) Load smoke config
$cfg = Get-Content -LiteralPath $smokeCfg -Encoding UTF8 | Out-String | ConvertFrom-Json
$site = [string]$cfg.SiteUrl
$mode = [string]$cfg.Mode
$max  = [int]$cfg.MaxUrls
$ignore = @($cfg.IgnorePatterns)

$checks = New-Object System.Collections.Generic.List[object]

# Core always
foreach($c in @($cfg.CoreChecks)){ $checks.Add($c) }

if($mode -eq "sitemap_all"){
  $sitemapUrl = ($site.TrimEnd('/') + ([string]$cfg.SitemapPath))
  try{
    $xml = Invoke-WebRequest -Uri $sitemapUrl -Method GET -TimeoutSec 30 -UseBasicParsing
    $content = [xml]$xml.Content
  } catch {
    Fail "STOP: sitemap fetch failed: $sitemapUrl :: $($_.Exception.Message)"
  }

  $locs = @()

  # handle sitemapindex or urlset
  if($content.sitemapindex -and $content.sitemapindex.sitemap){
    foreach($sm in $content.sitemapindex.sitemap){
      $u = [string]$sm.loc
      if([string]::IsNullOrWhiteSpace($u)){ continue }
      $locs += $u
    }
    # fetch each sitemap in index
    $urlLocs = New-Object System.Collections.Generic.List[string]
    foreach($smUrl in $locs){
      try{
        $x = Invoke-WebRequest -Uri $smUrl -Method GET -TimeoutSec 30 -UseBasicParsing
        $sx = [xml]$x.Content
        if($sx.urlset -and $sx.urlset.url){
          foreach($u in $sx.urlset.url){
            $l = [string]$u.loc
            if(-not [string]::IsNullOrWhiteSpace($l)){ $urlLocs.Add($l) }
          }
        }
      } catch {
        Fail "STOP: sitemap part fetch failed: $smUrl :: $($_.Exception.Message)"
      }
    }
    $locs = $urlLocs
  }
  elseif($content.urlset -and $content.urlset.url){
    foreach($u in $content.urlset.url){
      $l = [string]$u.loc
      if(-not [string]::IsNullOrWhiteSpace($l)){ $locs += $l }
    }
  }

  # filter to same site, map to path, de-dup
  $set = New-Object System.Collections.Generic.HashSet[string]
  foreach($u in $locs){
    if($u -notlike ($site.TrimEnd('/') + "/*")){ continue }
    $path = $u.Substring($site.TrimEnd('/').Length)
    if([string]::IsNullOrWhiteSpace($path)){ $path='/' }
    [void]$set.Add($path)
  }
  $paths = @($set) | ForEach-Object { param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$tools = Join-Path $RepoRoot "tools"
$preflight = Join-Path $tools "enterprise-preflight.ps1"
$smokeTool = Join-Path $tools "smoke-http.ps1"
$smokeCfg  = Join-Path $tools "smoke-checks.json"

if(!(Test-Path -LiteralPath $preflight)){ Fail "Missing: tools/enterprise-preflight.ps1" }
if(!(Test-Path -LiteralPath $smokeTool)){ Fail "Missing: tools/smoke-http.ps1" }
if(!(Test-Path -LiteralPath $smokeCfg)){  Fail "Missing: tools/smoke-checks.json" }

# 1) Preflight (all gates)
& $preflight -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed (exit=$LASTEXITCODE)" }

# 2) Load smoke config
$cfg = Get-Content -LiteralPath $smokeCfg -Encoding UTF8 | Out-String | ConvertFrom-Json
$site = [string]$cfg.SiteUrl
$mode = [string]$cfg.Mode
$max  = [int]$cfg.MaxUrls
$ignore = @($cfg.IgnorePatterns)

$checks = New-Object System.Collections.Generic.List[object]

# Core always
foreach($c in @($cfg.CoreChecks)){ $checks.Add($c) }

if($mode -eq "sitemap_all"){
  $sitemapUrl = ($site.TrimEnd('/') + ([string]$cfg.SitemapPath))
  try{
    $xml = Invoke-WebRequest -Uri $sitemapUrl -Method GET -TimeoutSec 30 -UseBasicParsing
    $content = [xml]$xml.Content
  } catch {
    Fail "STOP: sitemap fetch failed: $sitemapUrl :: $($_.Exception.Message)"
  }

  $locs = @()  # handle sitemapindex or urlset (StrictMode-safe + namespace-safe)
  $root = $content.DocumentElement
  if(-not $root){
    Fail "STOP: sitemap xml has no DocumentElement (empty/invalid xml?)"
  }
  $rootName = [string]$root.LocalName

  $ns = New-Object System.Xml.XmlNamespaceManager($content.NameTable)
  $ns.AddNamespace('sm','http://www.sitemaps.org/schemas/sitemap/0.9')

  $locNodes = @()

  if($rootName -eq 'sitemapindex'){
    $locNodes = @($content.SelectNodes('//sm:sitemap/sm:loc', $ns))
    if($locNodes.Count -eq 0){
      $locNodes = @($content.SelectNodes('//sitemap/loc'))
    }

    foreach($n in $locNodes){
      $u = [string]$n.InnerText
      if([string]::IsNullOrWhiteSpace($u)){ continue }
      $locs += $u
    }

    # fetch each sitemap in index
    $urlLocs = New-Object System.Collections.Generic.List[string]
    foreach($smUrl in $locs){
      try{
        $x = Invoke-WebRequest -Uri $smUrl -Method GET -TimeoutSec 30 -UseBasicParsing
        $sx = [xml]$x.Content

        $sxRoot = $sx.DocumentElement
        if(-not $sxRoot){
          Fail "STOP: sitemap part has no DocumentElement: $smUrl"
        }

        $sxNs = New-Object System.Xml.XmlNamespaceManager($sx.NameTable)
        $sxNs.AddNamespace('sm','http://www.sitemaps.org/schemas/sitemap/0.9')

        $uNodes = @($sx.SelectNodes('//sm:url/sm:loc', $sxNs))
        if($uNodes.Count -eq 0){
          $uNodes = @($sx.SelectNodes('//url/loc'))
        }

        foreach($n in $uNodes){
          $l = [string]$n.InnerText
          if(-not [string]::IsNullOrWhiteSpace($l)){ $urlLocs.Add($l) }
        }
      } catch {
        $msg = param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$tools = Join-Path $RepoRoot "tools"
$preflight = Join-Path $tools "enterprise-preflight.ps1"
$smokeTool = Join-Path $tools "smoke-http.ps1"
$smokeCfg  = Join-Path $tools "smoke-checks.json"

if(!(Test-Path -LiteralPath $preflight)){ Fail "Missing: tools/enterprise-preflight.ps1" }
if(!(Test-Path -LiteralPath $smokeTool)){ Fail "Missing: tools/smoke-http.ps1" }
if(!(Test-Path -LiteralPath $smokeCfg)){  Fail "Missing: tools/smoke-checks.json" }

# 1) Preflight (all gates)
& $preflight -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed (exit=$LASTEXITCODE)" }

# 2) Load smoke config
$cfg = Get-Content -LiteralPath $smokeCfg -Encoding UTF8 | Out-String | ConvertFrom-Json
$site = [string]$cfg.SiteUrl
$mode = [string]$cfg.Mode
$max  = [int]$cfg.MaxUrls
$ignore = @($cfg.IgnorePatterns)

$checks = New-Object System.Collections.Generic.List[object]

# Core always
foreach($c in @($cfg.CoreChecks)){ $checks.Add($c) }

if($mode -eq "sitemap_all"){
  $sitemapUrl = ($site.TrimEnd('/') + ([string]$cfg.SitemapPath))
  try{
    $xml = Invoke-WebRequest -Uri $sitemapUrl -Method GET -TimeoutSec 30 -UseBasicParsing
    $content = [xml]$xml.Content
  } catch {
    Fail "STOP: sitemap fetch failed: $sitemapUrl :: $($_.Exception.Message)"
  }

  $locs = @()

  # handle sitemapindex or urlset
  if($content.sitemapindex -and $content.sitemapindex.sitemap){
    foreach($sm in $content.sitemapindex.sitemap){
      $u = [string]$sm.loc
      if([string]::IsNullOrWhiteSpace($u)){ continue }
      $locs += $u
    }
    # fetch each sitemap in index
    $urlLocs = New-Object System.Collections.Generic.List[string]
    foreach($smUrl in $locs){
      try{
        $x = Invoke-WebRequest -Uri $smUrl -Method GET -TimeoutSec 30 -UseBasicParsing
        $sx = [xml]$x.Content
        if($sx.urlset -and $sx.urlset.url){
          foreach($u in $sx.urlset.url){
            $l = [string]$u.loc
            if(-not [string]::IsNullOrWhiteSpace($l)){ $urlLocs.Add($l) }
          }
        }
      } catch {
        Fail "STOP: sitemap part fetch failed: $smUrl :: $($_.Exception.Message)"
      }
    }
    $locs = $urlLocs
  }
  elseif($content.urlset -and $content.urlset.url){
    foreach($u in $content.urlset.url){
      $l = [string]$u.loc
      if(-not [string]::IsNullOrWhiteSpace($l)){ $locs += $l }
    }
  }

  # filter to same site, map to path, de-dup
  $set = New-Object System.Collections.Generic.HashSet[string]
  foreach($u in $locs){
    if($u -notlike ($site.TrimEnd('/') + "/*")){ continue }
    $path = $u.Substring($site.TrimEnd('/').Length)
    if([string]::IsNullOrWhiteSpace($path)){ $path='/' }
    [void]$set.Add($path)
  }

  $paths = $set.ToArray() | Sort-Object
  if($max -gt 0 -and $paths.Count -gt $max){ $paths = $paths | Select-Object -First $max }

  foreach($p in $paths){
    $checks.Add(@{ Path=$p; Expect=@(200) })
  }
}

& $smokeTool -SiteUrl $site -Checks $checks -MaxUrls $max -IgnorePatterns $ignore
if($LASTEXITCODE -ne 0){ Fail "STOP: smoke-http failed (exit=$LASTEXITCODE)" }

# AUTOGATE_REPORTS_NO_ERRORS
& (Join-Path (Join-Path $RepoRoot 'tools') 'gate-reports-no-errors.ps1') -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: reports gate failed (exit=$LASTEXITCODE)" }
"PASS: ENTERPRISE_AUTOPILOT_STEP"
exit 0
.Exception.Message
        Fail ("STOP: sitemap part fetch failed: {0} :: {1}" -f $smUrl, $msg)
      }
    }
    $locs = $urlLocs
  }
  elseif($rootName -eq 'urlset'){
    $locNodes = @($content.SelectNodes('//sm:url/sm:loc', $ns))
    if($locNodes.Count -eq 0){
      $locNodes = @($content.SelectNodes('//url/loc'))
    }

    foreach($n in $locNodes){
      $l = [string]$n.InnerText
      if(-not [string]::IsNullOrWhiteSpace($l)){ $locs += $l }
    }
  }
  else {
    Fail ("STOP: unexpected sitemap root: {0} (expected sitemapindex|urlset)" -f $rootName)
  }
  }

  # filter to same site, map to path, de-dup
  $set = New-Object System.Collections.Generic.HashSet[string]
  foreach($u in $locs){
    if($u -notlike ($site.TrimEnd('/') + "/*")){ continue }
    $path = $u.Substring($site.TrimEnd('/').Length)
    if([string]::IsNullOrWhiteSpace($path)){ $path='/' }
    [void]$set.Add($path)
  }

  $paths = $set.ToArray() | Sort-Object
  if($max -gt 0 -and $paths.Count -gt $max){ $paths = $paths | Select-Object -First $max }

  foreach($p in $paths){
    $checks.Add(@{ Path=$p; Expect=@(200) })
  }

& $smokeTool -SiteUrl $site -Checks $checks -MaxUrls $max -IgnorePatterns $ignore
if($LASTEXITCODE -ne 0){ Fail "STOP: smoke-http failed (exit=$LASTEXITCODE)" }

# AUTOGATE_REPORTS_NO_ERRORS
& (Join-Path (Join-Path $RepoRoot 'tools') 'gate-reports-no-errors.ps1') -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: reports gate failed (exit=$LASTEXITCODE)" }
"PASS: ENTERPRISE_AUTOPILOT_STEP"
 } | Sort-Object
  if($max -gt 0 -and $paths.Count -gt $max){ $paths = $paths | Select-Object -First $max }

  foreach($p in $paths){
    $checks.Add(@{ Path=$p; Expect=@(200) })
  }
}

& $smokeTool -SiteUrl $site -Checks $checks -MaxUrls $max -IgnorePatterns $ignore
if($LASTEXITCODE -ne 0){ Fail "STOP: smoke-http failed (exit=$LASTEXITCODE)" }

# AUTOGATE_REPORTS_NO_ERRORS
& (Join-Path (Join-Path $RepoRoot 'tools') 'gate-reports-no-errors.ps1') -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: reports gate failed (exit=$LASTEXITCODE)" }
"PASS: ENTERPRISE_AUTOPILOT_STEP"
exit 0
.Exception.Message
        Fail ("STOP: sitemap part fetch failed: {0} :: {1}" -f $smUrl, $msg)
      }
    }
    $locs = $urlLocs
  }
  elseif($rootName -eq 'urlset'){
    $locNodes = @($content.SelectNodes('//sm:url/sm:loc', $ns))
    if($locNodes.Count -eq 0){
      $locNodes = @($content.SelectNodes('//url/loc'))
    }

    foreach($n in $locNodes){
      $l = [string]$n.InnerText
      if(-not [string]::IsNullOrWhiteSpace($l)){ $locs += $l }
    }
  }
  else {
    Fail ("STOP: unexpected sitemap root: {0} (expected sitemapindex|urlset)" -f $rootName)
  }
  }

  # filter to same site, map to path, de-dup
  $set = New-Object System.Collections.Generic.HashSet[string]
  foreach($u in $locs){
    if($u -notlike ($site.TrimEnd('/') + "/*")){ continue }
    $path = $u.Substring($site.TrimEnd('/').Length)
    if([string]::IsNullOrWhiteSpace($path)){ $path='/' }
    [void]$set.Add($path)
  }
  $paths = @($set) | ForEach-Object { param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$tools = Join-Path $RepoRoot "tools"
$preflight = Join-Path $tools "enterprise-preflight.ps1"
$smokeTool = Join-Path $tools "smoke-http.ps1"
$smokeCfg  = Join-Path $tools "smoke-checks.json"

if(!(Test-Path -LiteralPath $preflight)){ Fail "Missing: tools/enterprise-preflight.ps1" }
if(!(Test-Path -LiteralPath $smokeTool)){ Fail "Missing: tools/smoke-http.ps1" }
if(!(Test-Path -LiteralPath $smokeCfg)){  Fail "Missing: tools/smoke-checks.json" }

# 1) Preflight (all gates)
& $preflight -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed (exit=$LASTEXITCODE)" }

# 2) Load smoke config
$cfg = Get-Content -LiteralPath $smokeCfg -Encoding UTF8 | Out-String | ConvertFrom-Json
$site = [string]$cfg.SiteUrl
$mode = [string]$cfg.Mode
$max  = [int]$cfg.MaxUrls
$ignore = @($cfg.IgnorePatterns)

$checks = New-Object System.Collections.Generic.List[object]

# Core always
foreach($c in @($cfg.CoreChecks)){ $checks.Add($c) }

if($mode -eq "sitemap_all"){
  $sitemapUrl = ($site.TrimEnd('/') + ([string]$cfg.SitemapPath))
  try{
    $xml = Invoke-WebRequest -Uri $sitemapUrl -Method GET -TimeoutSec 30 -UseBasicParsing
    $content = [xml]$xml.Content
  } catch {
    Fail "STOP: sitemap fetch failed: $sitemapUrl :: $($_.Exception.Message)"
  }

  $locs = @()  # handle sitemapindex or urlset (StrictMode-safe + namespace-safe)
  $root = $content.DocumentElement
  if(-not $root){
    Fail "STOP: sitemap xml has no DocumentElement (empty/invalid xml?)"
  }
  $rootName = [string]$root.LocalName

  $ns = New-Object System.Xml.XmlNamespaceManager($content.NameTable)
  $ns.AddNamespace('sm','http://www.sitemaps.org/schemas/sitemap/0.9')

  $locNodes = @()

  if($rootName -eq 'sitemapindex'){
    $locNodes = @($content.SelectNodes('//sm:sitemap/sm:loc', $ns))
    if($locNodes.Count -eq 0){
      $locNodes = @($content.SelectNodes('//sitemap/loc'))
    }

    foreach($n in $locNodes){
      $u = [string]$n.InnerText
      if([string]::IsNullOrWhiteSpace($u)){ continue }
      $locs += $u
    }

    # fetch each sitemap in index
    $urlLocs = New-Object System.Collections.Generic.List[string]
    foreach($smUrl in $locs){
      try{
        $x = Invoke-WebRequest -Uri $smUrl -Method GET -TimeoutSec 30 -UseBasicParsing
        $sx = [xml]$x.Content

        $sxRoot = $sx.DocumentElement
        if(-not $sxRoot){
          Fail "STOP: sitemap part has no DocumentElement: $smUrl"
        }

        $sxNs = New-Object System.Xml.XmlNamespaceManager($sx.NameTable)
        $sxNs.AddNamespace('sm','http://www.sitemaps.org/schemas/sitemap/0.9')

        $uNodes = @($sx.SelectNodes('//sm:url/sm:loc', $sxNs))
        if($uNodes.Count -eq 0){
          $uNodes = @($sx.SelectNodes('//url/loc'))
        }

        foreach($n in $uNodes){
          $l = [string]$n.InnerText
          if(-not [string]::IsNullOrWhiteSpace($l)){ $urlLocs.Add($l) }
        }
      } catch {
        $msg = param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$tools = Join-Path $RepoRoot "tools"
$preflight = Join-Path $tools "enterprise-preflight.ps1"
$smokeTool = Join-Path $tools "smoke-http.ps1"
$smokeCfg  = Join-Path $tools "smoke-checks.json"

if(!(Test-Path -LiteralPath $preflight)){ Fail "Missing: tools/enterprise-preflight.ps1" }
if(!(Test-Path -LiteralPath $smokeTool)){ Fail "Missing: tools/smoke-http.ps1" }
if(!(Test-Path -LiteralPath $smokeCfg)){  Fail "Missing: tools/smoke-checks.json" }

# 1) Preflight (all gates)
& $preflight -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: enterprise-preflight failed (exit=$LASTEXITCODE)" }

# 2) Load smoke config
$cfg = Get-Content -LiteralPath $smokeCfg -Encoding UTF8 | Out-String | ConvertFrom-Json
$site = [string]$cfg.SiteUrl
$mode = [string]$cfg.Mode
$max  = [int]$cfg.MaxUrls
$ignore = @($cfg.IgnorePatterns)

$checks = New-Object System.Collections.Generic.List[object]

# Core always
foreach($c in @($cfg.CoreChecks)){ $checks.Add($c) }

if($mode -eq "sitemap_all"){
  $sitemapUrl = ($site.TrimEnd('/') + ([string]$cfg.SitemapPath))
  try{
    $xml = Invoke-WebRequest -Uri $sitemapUrl -Method GET -TimeoutSec 30 -UseBasicParsing
    $content = [xml]$xml.Content
  } catch {
    Fail "STOP: sitemap fetch failed: $sitemapUrl :: $($_.Exception.Message)"
  }

  $locs = @()

  # handle sitemapindex or urlset
  if($content.sitemapindex -and $content.sitemapindex.sitemap){
    foreach($sm in $content.sitemapindex.sitemap){
      $u = [string]$sm.loc
      if([string]::IsNullOrWhiteSpace($u)){ continue }
      $locs += $u
    }
    # fetch each sitemap in index
    $urlLocs = New-Object System.Collections.Generic.List[string]
    foreach($smUrl in $locs){
      try{
        $x = Invoke-WebRequest -Uri $smUrl -Method GET -TimeoutSec 30 -UseBasicParsing
        $sx = [xml]$x.Content
        if($sx.urlset -and $sx.urlset.url){
          foreach($u in $sx.urlset.url){
            $l = [string]$u.loc
            if(-not [string]::IsNullOrWhiteSpace($l)){ $urlLocs.Add($l) }
          }
        }
      } catch {
        Fail "STOP: sitemap part fetch failed: $smUrl :: $($_.Exception.Message)"
      }
    }
    $locs = $urlLocs
  }
  elseif($content.urlset -and $content.urlset.url){
    foreach($u in $content.urlset.url){
      $l = [string]$u.loc
      if(-not [string]::IsNullOrWhiteSpace($l)){ $locs += $l }
    }
  }

  # filter to same site, map to path, de-dup
  $set = New-Object System.Collections.Generic.HashSet[string]
  foreach($u in $locs){
    if($u -notlike ($site.TrimEnd('/') + "/*")){ continue }
    $path = $u.Substring($site.TrimEnd('/').Length)
    if([string]::IsNullOrWhiteSpace($path)){ $path='/' }
    [void]$set.Add($path)
  }

  $paths = $set.ToArray() | Sort-Object
  if($max -gt 0 -and $paths.Count -gt $max){ $paths = $paths | Select-Object -First $max }

  foreach($p in $paths){
    $checks.Add(@{ Path=$p; Expect=@(200) })
  }
}

& $smokeTool -SiteUrl $site -Checks $checks -MaxUrls $max -IgnorePatterns $ignore
if($LASTEXITCODE -ne 0){ Fail "STOP: smoke-http failed (exit=$LASTEXITCODE)" }

# AUTOGATE_REPORTS_NO_ERRORS
& (Join-Path (Join-Path $RepoRoot 'tools') 'gate-reports-no-errors.ps1') -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: reports gate failed (exit=$LASTEXITCODE)" }
"PASS: ENTERPRISE_AUTOPILOT_STEP"
exit 0
.Exception.Message
        Fail ("STOP: sitemap part fetch failed: {0} :: {1}" -f $smUrl, $msg)
      }
    }
    $locs = $urlLocs
  }
  elseif($rootName -eq 'urlset'){
    $locNodes = @($content.SelectNodes('//sm:url/sm:loc', $ns))
    if($locNodes.Count -eq 0){
      $locNodes = @($content.SelectNodes('//url/loc'))
    }

    foreach($n in $locNodes){
      $l = [string]$n.InnerText
      if(-not [string]::IsNullOrWhiteSpace($l)){ $locs += $l }
    }
  }
  else {
    Fail ("STOP: unexpected sitemap root: {0} (expected sitemapindex|urlset)" -f $rootName)
  }
  }

  # filter to same site, map to path, de-dup
  $set = New-Object System.Collections.Generic.HashSet[string]
  foreach($u in $locs){
    if($u -notlike ($site.TrimEnd('/') + "/*")){ continue }
    $path = $u.Substring($site.TrimEnd('/').Length)
    if([string]::IsNullOrWhiteSpace($path)){ $path='/' }
    [void]$set.Add($path)
  }

  $paths = $set.ToArray() | Sort-Object
  if($max -gt 0 -and $paths.Count -gt $max){ $paths = $paths | Select-Object -First $max }

  foreach($p in $paths){
    $checks.Add(@{ Path=$p; Expect=@(200) })
  }

& $smokeTool -SiteUrl $site -Checks $checks -MaxUrls $max -IgnorePatterns $ignore
if($LASTEXITCODE -ne 0){ Fail "STOP: smoke-http failed (exit=$LASTEXITCODE)" }

# AUTOGATE_REPORTS_NO_ERRORS
& (Join-Path (Join-Path $RepoRoot 'tools') 'gate-reports-no-errors.ps1') -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: reports gate failed (exit=$LASTEXITCODE)" }
"PASS: ENTERPRISE_AUTOPILOT_STEP"
 } | Sort-Object
  if($max -gt 0 -and $paths.Count -gt $max){ $paths = $paths | Select-Object -First $max }

  foreach($p in $paths){
    $checks.Add(@{ Path=$p; Expect=@(200) })
  }

& $smokeTool -SiteUrl $site -Checks $checks -MaxUrls $max -IgnorePatterns $ignore
if($LASTEXITCODE -ne 0){ Fail "STOP: smoke-http failed (exit=$LASTEXITCODE)" }

# AUTOGATE_REPORTS_NO_ERRORS
& (Join-Path (Join-Path $RepoRoot 'tools') 'gate-reports-no-errors.ps1') -RepoRoot $RepoRoot
if($LASTEXITCODE -ne 0){ Fail "STOP: reports gate failed (exit=$LASTEXITCODE)" }
"PASS: ENTERPRISE_AUTOPILOT_STEP"
