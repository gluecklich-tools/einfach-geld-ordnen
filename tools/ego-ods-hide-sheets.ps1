$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
param(
  [Parameter(Mandatory=$true)][string]$OdsPath,
  [Parameter(Mandatory=$true)][string[]]$Keep
)
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (-not (Test-Path -LiteralPath $OdsPath)) { throw "ODS not found: $OdsPath" }
# lock check
try { $h=[IO.File]::Open($OdsPath,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None); $h.Dispose() } catch { throw "ODS locked (LibreOffice open?). Close it and retry." }
# basic zip check
$z=[System.IO.Compression.ZipFile]::OpenRead($OdsPath)
try {
  $names=@($z.Entries | ForEach-Object { $_.FullName })
  foreach ($req in @('mimetype','content.xml','styles.xml')) { if (-not ($names -contains $req)) { throw "ODS invalid: missing $req" } }
} finally { $z.Dispose() }
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$bak = "$OdsPath.bak_$ts"
Copy-Item -LiteralPath $OdsPath -Destination $bak -Force
$work = Join-Path $env:TEMP ("ego_ods_" + $ts)
$u = Join-Path $work 'u'
$out = Join-Path $work 'patched.ods'
New-Item -ItemType Directory -Path $u -Force | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($OdsPath, $u)
$mt = Join-Path $u 'mimetype'
$cx = Join-Path $u 'content.xml'
$sx = Join-Path $u 'styles.xml'
foreach ($p in @($mt,$cx,$sx)) { if (-not (Test-Path -LiteralPath $p)) { throw "Extract missing: $p" } }
function PatchXml([string]$path,[string[]]$keep){
  $xml = [IO.File]::ReadAllText($path,[Text.UTF8Encoding]::new($false))
  $rx = [regex]'<table:table\b[^>]*\btable:name="([^"]+)"[^>]*>'
  $shown=0; $hidden=0
  $xml2 = $rx.Replace($xml, {
    param($m)
    $name = $m.Groups[1].Value
    $tag = $m.Value
    $tag = [regex]::Replace($tag,'\s+table:display="[^"]*" ',' ')
    $tag = [regex]::Replace($tag,'\s+table:visibility="[^"]*" ',' ')
    $tag = [regex]::Replace($tag,'\s+table:display="[^"]*"(?=>)','')
    $tag = [regex]::Replace($tag,'\s+table:visibility="[^"]*"(?=>)','')
    if ($keep -contains $name) {
      $shown++
      return $tag.TrimEnd('>' ) + ' table:display="true" table:visibility="visible">'
    } else {
      $hidden++
      return $tag.TrimEnd('>' ) + ' table:display="false" table:visibility="collapse">'
    }
  })
  # xml parse sanity
  $d = New-Object System.Xml.XmlDocument
  $d.PreserveWhitespace = $true
  $d.LoadXml($xml2)
  [IO.File]::WriteAllText($path,$xml2,[Text.UTF8Encoding]::new($false))
  return @($shown,$hidden)
}
$c = PatchXml $cx $Keep
$s = PatchXml $sx $Keep
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }
$zip = [System.IO.Compression.ZipFile]::Open($out,[System.IO.Compression.ZipArchiveMode]::Create)
try {
  $me = $zip.CreateEntry('mimetype',[System.IO.Compression.CompressionLevel]::NoCompression)
  $ms = $me.Open(); try { $b=[IO.File]::ReadAllBytes($mt); $ms.Write($b,0,$b.Length) } finally { $ms.Dispose() }
  Get-ChildItem -LiteralPath $u -Recurse -File | ForEach-Object {
    $full=$_.FullName; if ($full -ieq $mt) { return }
    $rel=$full.Substring($u.Length).TrimStart('\','/') -replace '\\','/'
    $en=$zip.CreateEntry($rel,[System.IO.Compression.CompressionLevel]::Optimal)
    $st=$en.Open(); try { $bb=[IO.File]::ReadAllBytes($full); $st.Write($bb,0,$bb.Length) } finally { $st.Dispose() }
  }
} finally { $zip.Dispose() }
# EGO_NO_BIG_PASTE_SANITY_V1
# extra sanity: entry count must not shrink; manifest/settings should be preserved if present
$z0=[System.IO.Compression.ZipFile]::OpenRead($OdsPath)
try { $n0=@($z0.Entries | ForEach-Object { $ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
param(
  [Parameter(Mandatory=$true)][string]$OdsPath,
  [Parameter(Mandatory=$true)][string[]]$Keep
)
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (-not (Test-Path -LiteralPath $OdsPath)) { throw "ODS not found: $OdsPath" }
# lock check
try { $h=[IO.File]::Open($OdsPath,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None); $h.Dispose() } catch { throw "ODS locked (LibreOffice open?). Close it and retry." }
# basic zip check
$z=[System.IO.Compression.ZipFile]::OpenRead($OdsPath)
try {
  $names=@($z.Entries | ForEach-Object { $_.FullName })
  foreach ($req in @('mimetype','content.xml','styles.xml')) { if (-not ($names -contains $req)) { throw "ODS invalid: missing $req" } }
} finally { $z.Dispose() }
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$bak = "$OdsPath.bak_$ts"
Copy-Item -LiteralPath $OdsPath -Destination $bak -Force
$work = Join-Path $env:TEMP ("ego_ods_" + $ts)
$u = Join-Path $work 'u'
$out = Join-Path $work 'patched.ods'
New-Item -ItemType Directory -Path $u -Force | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($OdsPath, $u)
$mt = Join-Path $u 'mimetype'
$cx = Join-Path $u 'content.xml'
$sx = Join-Path $u 'styles.xml'
foreach ($p in @($mt,$cx,$sx)) { if (-not (Test-Path -LiteralPath $p)) { throw "Extract missing: $p" } }
function PatchXml([string]$path,[string[]]$keep){
  $xml = [IO.File]::ReadAllText($path,[Text.UTF8Encoding]::new($false))
  $rx = [regex]'<table:table\b[^>]*\btable:name="([^"]+)"[^>]*>'
  $shown=0; $hidden=0
  $xml2 = $rx.Replace($xml, {
    param($m)
    $name = $m.Groups[1].Value
    $tag = $m.Value
    $tag = [regex]::Replace($tag,'\s+table:display="[^"]*" ',' ')
    $tag = [regex]::Replace($tag,'\s+table:visibility="[^"]*" ',' ')
    $tag = [regex]::Replace($tag,'\s+table:display="[^"]*"(?=>)','')
    $tag = [regex]::Replace($tag,'\s+table:visibility="[^"]*"(?=>)','')
    if ($keep -contains $name) {
      $shown++
      return $tag.TrimEnd('>' ) + ' table:display="true" table:visibility="visible">'
    } else {
      $hidden++
      return $tag.TrimEnd('>' ) + ' table:display="false" table:visibility="collapse">'
    }
  })
  # xml parse sanity
  $d = New-Object System.Xml.XmlDocument
  $d.PreserveWhitespace = $true
  $d.LoadXml($xml2)
  [IO.File]::WriteAllText($path,$xml2,[Text.UTF8Encoding]::new($false))
  return @($shown,$hidden)
}
$c = PatchXml $cx $Keep
$s = PatchXml $sx $Keep
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }
$zip = [System.IO.Compression.ZipFile]::Open($out,[System.IO.Compression.ZipArchiveMode]::Create)
try {
  $me = $zip.CreateEntry('mimetype',[System.IO.Compression.CompressionLevel]::NoCompression)
  $ms = $me.Open(); try { $b=[IO.File]::ReadAllBytes($mt); $ms.Write($b,0,$b.Length) } finally { $ms.Dispose() }
  Get-ChildItem -LiteralPath $u -Recurse -File | ForEach-Object {
    $full=$_.FullName; if ($full -ieq $mt) { return }
    $rel=$full.Substring($u.Length).TrimStart('\','/') -replace '\\','/'
    $en=$zip.CreateEntry($rel,[System.IO.Compression.CompressionLevel]::Optimal)
    $st=$en.Open(); try { $bb=[IO.File]::ReadAllBytes($full); $st.Write($bb,0,$bb.Length) } finally { $st.Dispose() }
  }
} finally { $zip.Dispose() }
# final sanity: required entries exist
$z2=[System.IO.Compression.ZipFile]::OpenRead($out)
try { $n2=@($z2.Entries | ForEach-Object { $_.FullName }); foreach($req in @('mimetype','content.xml','styles.xml')){ if(-not($n2 -contains $req)){ throw "SANITY FAIL: missing $req" } } } finally { $z2.Dispose() }
Copy-Item -LiteralPath $out -Destination $OdsPath -Force
[pscustomobject]@{ Ods=$OdsPath; Backup=$bak; ContentShown=$c[0]; ContentHidden=$c[1]; StylesShown=$s[0]; StylesHidden=$s[1]; Keep=($Keep -join ', ') }.FullName }) } finally { $z0.Dispose() }
$z2=[System.IO.Compression.ZipFile]::OpenRead($out)
try { $n2=@($z2.Entries | ForEach-Object { $ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
param(
  [Parameter(Mandatory=$true)][string]$OdsPath,
  [Parameter(Mandatory=$true)][string[]]$Keep
)
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
if (-not (Test-Path -LiteralPath $OdsPath)) { throw "ODS not found: $OdsPath" }
# lock check
try { $h=[IO.File]::Open($OdsPath,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None); $h.Dispose() } catch { throw "ODS locked (LibreOffice open?). Close it and retry." }
# basic zip check
$z=[System.IO.Compression.ZipFile]::OpenRead($OdsPath)
try {
  $names=@($z.Entries | ForEach-Object { $_.FullName })
  foreach ($req in @('mimetype','content.xml','styles.xml')) { if (-not ($names -contains $req)) { throw "ODS invalid: missing $req" } }
} finally { $z.Dispose() }
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$bak = "$OdsPath.bak_$ts"
Copy-Item -LiteralPath $OdsPath -Destination $bak -Force
$work = Join-Path $env:TEMP ("ego_ods_" + $ts)
$u = Join-Path $work 'u'
$out = Join-Path $work 'patched.ods'
New-Item -ItemType Directory -Path $u -Force | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($OdsPath, $u)
$mt = Join-Path $u 'mimetype'
$cx = Join-Path $u 'content.xml'
$sx = Join-Path $u 'styles.xml'
foreach ($p in @($mt,$cx,$sx)) { if (-not (Test-Path -LiteralPath $p)) { throw "Extract missing: $p" } }
function PatchXml([string]$path,[string[]]$keep){
  $xml = [IO.File]::ReadAllText($path,[Text.UTF8Encoding]::new($false))
  $rx = [regex]'<table:table\b[^>]*\btable:name="([^"]+)"[^>]*>'
  $shown=0; $hidden=0
  $xml2 = $rx.Replace($xml, {
    param($m)
    $name = $m.Groups[1].Value
    $tag = $m.Value
    $tag = [regex]::Replace($tag,'\s+table:display="[^"]*" ',' ')
    $tag = [regex]::Replace($tag,'\s+table:visibility="[^"]*" ',' ')
    $tag = [regex]::Replace($tag,'\s+table:display="[^"]*"(?=>)','')
    $tag = [regex]::Replace($tag,'\s+table:visibility="[^"]*"(?=>)','')
    if ($keep -contains $name) {
      $shown++
      return $tag.TrimEnd('>' ) + ' table:display="true" table:visibility="visible">'
    } else {
      $hidden++
      return $tag.TrimEnd('>' ) + ' table:display="false" table:visibility="collapse">'
    }
  })
  # xml parse sanity
  $d = New-Object System.Xml.XmlDocument
  $d.PreserveWhitespace = $true
  $d.LoadXml($xml2)
  [IO.File]::WriteAllText($path,$xml2,[Text.UTF8Encoding]::new($false))
  return @($shown,$hidden)
}
$c = PatchXml $cx $Keep
$s = PatchXml $sx $Keep
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }
$zip = [System.IO.Compression.ZipFile]::Open($out,[System.IO.Compression.ZipArchiveMode]::Create)
try {
  $me = $zip.CreateEntry('mimetype',[System.IO.Compression.CompressionLevel]::NoCompression)
  $ms = $me.Open(); try { $b=[IO.File]::ReadAllBytes($mt); $ms.Write($b,0,$b.Length) } finally { $ms.Dispose() }
  Get-ChildItem -LiteralPath $u -Recurse -File | ForEach-Object {
    $full=$_.FullName; if ($full -ieq $mt) { return }
    $rel=$full.Substring($u.Length).TrimStart('\','/') -replace '\\','/'
    $en=$zip.CreateEntry($rel,[System.IO.Compression.CompressionLevel]::Optimal)
    $st=$en.Open(); try { $bb=[IO.File]::ReadAllBytes($full); $st.Write($bb,0,$bb.Length) } finally { $st.Dispose() }
  }
} finally { $zip.Dispose() }
# final sanity: required entries exist
$z2=[System.IO.Compression.ZipFile]::OpenRead($out)
try { $n2=@($z2.Entries | ForEach-Object { $_.FullName }); foreach($req in @('mimetype','content.xml','styles.xml')){ if(-not($n2 -contains $req)){ throw "SANITY FAIL: missing $req" } } } finally { $z2.Dispose() }
Copy-Item -LiteralPath $out -Destination $OdsPath -Force
[pscustomobject]@{ Ods=$OdsPath; Backup=$bak; ContentShown=$c[0]; ContentHidden=$c[1]; StylesShown=$s[0]; StylesHidden=$s[1]; Keep=($Keep -join ', ') }.FullName }) } finally { $z2.Dispose() }
if ($n2.Count -lt $n0.Count) { throw ("SANITY FAIL: entries shrank: " + $n0.Count + " -> " + $n2.Count) }
if (($n0 -contains "META-INF/manifest.xml") -and (-not ($n2 -contains "META-INF/manifest.xml"))) { throw "SANITY FAIL: META-INF/manifest.xml lost" }
if (($n0 -contains "settings.xml") -and (-not ($n2 -contains "settings.xml"))) { throw "SANITY FAIL: settings.xml lost" }
# final sanity: required entries exist
$z2=[System.IO.Compression.ZipFile]::OpenRead($out)
try { $n2=@($z2.Entries | ForEach-Object { $_.FullName }); foreach($req in @('mimetype','content.xml','styles.xml')){ if(-not($n2 -contains $req)){ throw "SANITY FAIL: missing $req" } } } finally { $z2.Dispose() }
Copy-Item -LiteralPath $out -Destination $OdsPath -Force
[pscustomobject]@{ Ods=$OdsPath; Backup=$bak; ContentShown=$c[0]; ContentHidden=$c[1]; StylesShown=$s[0]; StylesHidden=$s[1]; Keep=($Keep -join ', ') }