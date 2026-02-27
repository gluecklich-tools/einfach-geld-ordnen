param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$WorkflowRel = ".github/workflows/enterprise-laws.yml"
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }

$wf = Join-Path $RepoRoot $WorkflowRel
if(!(Test-Path -LiteralPath $wf)){ Fail "FAIL: ACTIONS_TRIGGER_POLICY missing workflow: $WorkflowRel" }

$lines = [IO.File]::ReadAllLines($wf, $enc)

$hasOn=$false
$hasDispatch=$false
$hasPush=$false
$inPush=$false
$inBranches=$false
$branches = New-Object System.Collections.Generic.HashSet[string]

foreach($ln in $lines){
  $t = ($ln ?? "").Trim()

  if($t -eq "on:"){ $hasOn=$true; continue }
  if($t -eq "workflow_dispatch:"){ $hasDispatch=$true; continue }

  if($t -eq "push:"){ $hasPush=$true; $inPush=$true; $inBranches=$false; continue }

  if($inPush -and $t -like "branches:*"){ $inBranches=$true; continue }

  if($inBranches){
    if($t.StartsWith("- ")){
      $b = $t.Substring(2).Trim()
      if($b.Length -gt 0){ [void]$branches.Add($b) }
      continue
    } else {
      $inBranches=$false
      $inPush=$false
    }
  }
}

if(-not $hasOn){ Fail "FAIL: ACTIONS_TRIGGER_POLICY missing: on:" }
if(-not $hasDispatch){ Fail "FAIL: ACTIONS_TRIGGER_POLICY missing: workflow_dispatch:" }
if(-not $hasPush){ Fail "FAIL: ACTIONS_TRIGGER_POLICY missing: on.push" }
if($branches.Count -eq 0){ Fail "FAIL: ACTIONS_TRIGGER_POLICY missing: on.push.branches list" }

if(-not $branches.Contains("main")){ Fail "FAIL: ACTIONS_TRIGGER_POLICY branches missing: main" }
if(-not $branches.Contains("recovery/**")){ Fail "FAIL: ACTIONS_TRIGGER_POLICY branches missing: recovery/**" }

"PASS: ACTIONS_TRIGGER_POLICY (main + recovery/** + workflow_dispatch)"
exit 0