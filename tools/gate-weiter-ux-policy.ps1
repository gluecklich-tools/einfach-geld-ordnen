param()

# BEGIN AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1
. (Join-Path $PSScriptRoot 'shared\tool-entrypoint-failure-sync-runtime.ps1') -ToolEntryPointPath $PSCommandPath -RequiredReadsTaskType 'Tool-Entrypoint-Failure'
# END AUTO_FAILURE_TOOL_ENTRYPOINT_HOOK_V1

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Push-Location $repo
try {
  function Get-RepoRel([string]$p){
    $full = [System.IO.Path]::GetFullPath($p)
    $base = $repo
    if(-not $base.EndsWith([System.IO.Path]::DirectorySeparatorChar)){ $base += [System.IO.Path]::DirectorySeparatorChar }
    $u1 = [Uri]$base
    $u2 = [Uri]$full
    [Uri]::UnescapeDataString($u1.MakeRelativeUri($u2).ToString()).Replace('/','\')
  }

  function Get-SelfUrl([string]$r){
    $r = $r.Replace('\','/')
    if($r -match '^seiten/(.+)\.md$'){ return "{{ site.baseurl }}/seiten/$($matches[1]).html" }
    if($r -match '^pillar/(.+)\.md$'){ return "{{ site.baseurl }}/pillar/$($matches[1]).html" }
    return ""
  }

  $tracked = @(git ls-files -- 'seiten/*.md' 'seiten/**/*.md' 'pillar/*.md' 'pillar/**/*.md')
  $md = @()
  foreach($rel in @($tracked)){
    if([string]::IsNullOrWhiteSpace($rel)){ continue }
    $full = Join-Path $repo $rel
    if(Test-Path -LiteralPath $full){
      $md += Get-Item -LiteralPath $full
    }
  }
  $md = @($md | Sort-Object FullName -Unique)

  $rxBlock = [regex]'(?ims)^\s*##\s+Weiter\s*$.*?(?=^\s*##\s+|\z)'
  $rxLink  = [regex]'\[([^\]]+)\]\(([^)]+)\)'

  $bad = New-Object System.Collections.Generic.List[object]

  foreach($f in @($md)){
    $r = Get-RepoRel $f.FullName
    $raw = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
    if(-not $rxBlock.IsMatch($raw)){ continue }

    $block = $rxBlock.Match($raw).Value
    $m = $rxLink.Matches($block)
    $issues = New-Object System.Collections.Generic.List[string]

    if($m.Count -ne 3){ $issues.Add("Weiter-Block hat nicht genau 3 Markdown-Links") | Out-Null }

    $selfUrl = Get-SelfUrl $r
    $targets = @()

    foreach($mm in @($m)){
      $t = ($mm.Groups[1].Value).Trim()
      $u = ($mm.Groups[2].Value).Trim()

      if($t -match '^\s*Weiter\s*$'){ $issues.Add("Linktext ist 'Weiter' (Platzhalter)") | Out-Null }
      if(-not [string]::IsNullOrWhiteSpace($selfUrl) -and $u -eq $selfUrl){ $issues.Add("Self-Link im Weiter-Block") | Out-Null }
      if($u -match '\.md(\)|$)'){ $issues.Add(".md-Link im Weiter-Block") | Out-Null }
      if($u -eq '#'){ $issues.Add("Hash-Link im Weiter-Block") | Out-Null }

      $targets += $u
    }

    if($block -notmatch '\{\%\s*include\s+no_sackgasse_footer\.html\s*\%\}'){
      $issues.Add("Footer include fehlt direkt nach Weiter") | Out-Null
    }

    if($r.Replace('\','/') -eq 'pillar/index.md'){
      $want = @(
        '{{ site.baseurl }}/pillar/haushaltsbuch.html',
        '{{ site.baseurl }}/pillar/fixkosten.html',
        '{{ site.baseurl }}/pillar/50-30-20.html'
      )
      if($targets.Count -eq 3){
        for($i=0;$i -lt 3;$i++){
          if($targets[$i] -ne $want[$i]){
            $issues.Add("pillar/index Weiter-Reihenfolge/Targets nicht policy-konform") | Out-Null
            break
          }
        }
      }
    }

    if($issues.Count -gt 0){
      $bad.Add([pscustomobject]@{
        File   = $r.Replace('\','/')
        Issues = @($issues)
      }) | Out-Null
    }
  }

  if($bad.Count -gt 0){
    $bad | ConvertTo-Json -Depth 5
    "FAIL: Weiter UX Policy Gate verletzt (Bad={0})" -f $bad.Count
    throw "STOP: Weiter UX Policy Gate failed."
  }

  "PASS: Weiter UX Policy Gate ok."

  # Policy file must exist (repo SSOT)
  $pol = Join-Path $repo 'tools/policy/WEITER_NAV_POLICY.md'
  if(-not (Test-Path -LiteralPath $pol)){ throw 'STOP: Missing tools/policy/WEITER_NAV_POLICY.md' }
}
finally {
  Pop-Location
}

