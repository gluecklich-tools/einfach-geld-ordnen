param(
  [Parameter(Mandatory, ParameterSetName="Inline")][string]$Content,
  [Parameter(Mandatory, ParameterSetName="File")][string]$ContentFile,
  [Parameter(Mandatory)][string]$StepPath,
  [switch]$Force,
  [int]$VerifyRetries = 20,
  [int]$VerifyWaitMs = 100
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{ if($IsWindows){ chcp 65001 | Out-Null } }catch{}
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$enc=[Text.UTF8Encoding]::new($false)

function Fail([string]$m){ Write-Error $m; exit 3 }
function WriteUtf8NoBom([string]$p,[string]$s){ [IO.File]::WriteAllText($p,$s,$enc) }

if([string]::IsNullOrWhiteSpace($StepPath)){ Fail "STOP: StepPath empty" }
$dir = Split-Path -Parent $StepPath
if([string]::IsNullOrWhiteSpace($dir)){ Fail "STOP: StepPath has no parent dir: $StepPath" }
if(!(Test-Path -LiteralPath $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }

if((Test-Path -LiteralPath $StepPath) -and !$Force){
  Fail "STOP: Step already exists (use -Force to overwrite): $StepPath"
}

# Load content (LAW: avoid console-escaped pseudo-newlines)
if($PSCmdlet.ParameterSetName -eq "File"){
  if(!(Test-Path -LiteralPath $ContentFile)){ Fail "STOP: ContentFile not found: $ContentFile" }
  $Content = Get-Content -LiteralPath $ContentFile -Raw -Encoding UTF8
} else {
  # Gate: literal `n sequences are almost always a broken paste/escape
  if($Content -match "``n"){ Fail "STOP: Inline Content contains literal ``n. Use -ContentFile to avoid escaping bugs." }
}

WriteUtf8NoBom $StepPath ($Content.TrimEnd() + "`n")

$ok = $false
for($i=1; $i -le $VerifyRetries; $i++){
  if(Test-Path -LiteralPath $StepPath){
    try{
      $fi = Get-Item -LiteralPath $StepPath -ErrorAction Stop
      if($fi.Length -gt 0){ $ok = $true; break }
    }catch{}
  }
  Start-Sleep -Milliseconds $VerifyWaitMs
}
if(!$ok){ Fail "STOP: Step write verify failed (not found/empty): $StepPath" }

$rp = (Resolve-Path -LiteralPath $StepPath).Path
"STEP_WRITTEN: $rp"
exit 0
