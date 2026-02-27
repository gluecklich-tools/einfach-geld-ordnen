# ALLOW_REGEX_PATCH (temporary; must be removed when refactored to literal/AST patching)
$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

$Repo = (git rev-parse --show-toplevel).Trim()
Set-Location -LiteralPath $Repo

function Read-Utf8([string]$Path){ [IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8) }
function Rel([string]$full){ $full.Substring($Repo.Length).TrimStart('\').Replace('\','/') }

function Get-Frontmatter([string]$text){
  $t = $text -replace "`r`n","`n"
  if($t -notmatch "(?ms)^---\s*$.*?^---\s*$"){ return $null }
  $m = [regex]::Match($t, "(?ms)^---\s*$\s*(?<fm>.*?)\s*^---\s*$")
  if(-not $m.Success){ return $null }
  return $m.Groups["fm"].Value
}

function Get-FmValue([string]$fm, [string]$key){
  # very small YAML subset: key: "value" or key: value (single-line)
  $rx = "(?m)^\s*" + [regex]::Escape($key) + "\s*:\s*(?<v>.+?)\s*$"
  $m = [regex]::Match($fm, $rx)
  if(-not $m.Success){ return $null }
  $v = $m.Groups["v"].Value.Trim()
  # strip quotes if present
  if(($v.StartsWith('"') -and $v.EndsWith('"')) -or ($v.StartsWith("'") -and $v.EndsWith("'"))){
    $v = $v.Substring(1, $v.Length-2)
  }
  return $v.Trim()
}

function Is-OkWeiterUrl([string]$u){
  if([string]::IsNullOrWhiteSpace($u)){ return $false }
  $u2 = $u.Trim()
  # allow home: {{ site.baseurl }}/
  if($u2 -match "^\{\{\s*site\.baseurl\s*\}\}/\s*$"){ return $true }
  # otherwise require baseurl + .html
  if($u2 -notmatch "^\{\{\s*site\.baseurl\s*\}\}/"){ return $false }
  if($u2 -notmatch "\.html(\#.*)?\s*$"){ return $false }
  return $true
}

$seiten = Join-Path $Repo "seiten"
if(-not (Test-Path -LiteralPath $seiten)){ throw "STOP: seiten/ not found." }
$pages = @(Get-ChildItem -LiteralPath $seiten -File -Recurse -ErrorAction Stop | Where-Object { $_.Extension -in @(".md",".html") })

$tag = "{% include weiter_links.html %}"
$bad = New-Object System.Collections.Generic.List[string]
$used = 0

foreach($p in $pages){
  $txt = Read-Utf8 $p.FullName
  if($txt -notmatch [regex]::Escape($tag)){ continue }
  $used++
  $rel = Rel $p.FullName
  $fm = Get-Frontmatter $txt
  if($null -eq $fm){ $bad.Add(("{0}: include used, but no frontmatter found" -f $rel)) | Out-Null; continue }

  $t1 = Get-FmValue $fm "weiter_1_text"; $u1 = Get-FmValue $fm "weiter_1_url"
  $t2 = Get-FmValue $fm "weiter_2_text"; $u2 = Get-FmValue $fm "weiter_2_url"
  $t3 = Get-FmValue $fm "weiter_3_text"; $u3 = Get-FmValue $fm "weiter_3_url"

  if([string]::IsNullOrWhiteSpace($t1) -or [string]::IsNullOrWhiteSpace($t2) -or [string]::IsNullOrWhiteSpace($t3)){
    $bad.Add(("{0}: missing weiter_*_text (need 3)" -f $rel)) | Out-Null
  }
  if(-not (Is-OkWeiterUrl $u1) -or -not (Is-OkWeiterUrl $u2) -or -not (Is-OkWeiterUrl $u3)){
    $bad.Add(("{0}: weiter_*_url invalid (need {{ site.baseurl }}/ OR {{ site.baseurl }}/...html)  u1={1} u2={2} u3={3}" -f $rel, $u1, $u2, $u3)) | Out-Null
  }
}

"PASS: weiter-gate ran. include-used={0} pages={1}" -f $used, $pages.Count
if($bad.Count -gt 0){
  "FAIL: weiter-gate found issues:"
  $bad.ToArray() | Sort-Object
  throw ("STOP: weiter-gate fail count={0}" -f $bad.Count)
}
"PASS: weiter-gate OK."
