param(
  [Parameter(Mandatory=$true)][string]$Command,
  [switch]$NoLog
)

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest

function Fail([string]$m){ throw $m }

# Block classic accidents: git output executed as command, duplicated commands, chained code->pwsh
if ($Command -match '^\s*To\s+https?://' ) { Fail "Blocked: looks like git output (To https://...), not a command." }
if ($Command -match 'git\s+status[^|]*git\s+status') { Fail "Blocked: duplicated git status in one line." }
if ($Command -match '\)\s*pwsh\s+-NoProfile') { Fail "Blocked: looks like chained code -g (...)pwsh ... without separator." }

# Execute via cmd.exe to avoid PowerShell token mixing
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "cmd.exe"
$psi.Arguments = "/d /c " + $Command
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
      $log = Join-Path $dir ("cmd_{0}.log" -f $ts)
      $enc = New-Object System.Text.UTF8Encoding($false)
      $text = "CMD: " + $Command + "`n`nSTDOUT:`n" + $stdout + "`n`nSTDERR:`n" + $stderr + "`nEXIT=" + $p.ExitCode + "`n"
      [System.IO.File]::WriteAllText($log, $text, $enc)
      "LOG: $log"
    }
  } catch { }
}

if ($stdout) { $stdout.TrimEnd() }
if ($stderr) { $stderr.TrimEnd() }
if ($p.ExitCode -ne 0) { exit $p.ExitCode }
