param(
  [Parameter(Mandatory=$true)][string]$File,
  [string[]]$Args = @(),
  [switch]$NoLog
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

if (-not (Test-Path -LiteralPath $File)) { Fail "File not found: $File" }

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "pwsh.exe"
# build args safely (no quote hell)
$all = @("-NoProfile","-ExecutionPolicy","Bypass","-File",$File) + $Args
$psi.Arguments = ($all | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join " "
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError  = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow  = $true

$p = New-Object System.Diagnostics.Process
$p.StartInfo = $psi
[void]$p.Start()
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
$p.WaitForExit()

if (-not $NoLog) {
  try {
    $repo = (& git rev-parse --show-toplevel 2>$null)
    if ($repo) {
      $repo = (Resolve-Path -LiteralPath $repo).Path
      $dir = Join-Path $repo "_local\_reports\cmd"
      if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
      $ts = Get-Date -Format "yyyyMMdd_HHmmss"
      $log = Join-Path $dir ("cmdfile_{0}.log" -f $ts)
      $enc = New-Object System.Text.UTF8Encoding($false)
      $text = "FILE: " + $File + "
ARGS: " + ($Args -join " ") + "

STDOUT:
" + $stdout + "

STDERR:
" + $stderr + "
EXIT=" + $p.ExitCode + "
"
      [System.IO.File]::WriteAllText($log, $text, $enc)
      "LOG: $log"
    }
  } catch { }
}

if ($stdout) { $stdout.TrimEnd() }
if ($stderr) { $stderr.TrimEnd() }

if ($p.ExitCode -ne 0) { exit $p.ExitCode }
