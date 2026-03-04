#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (MarkerPath=#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg MarkerRaw=#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg) (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (MarkerPath=#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg MarkerRaw=#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg) (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (MarkerPath=#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg MarkerRaw=#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg) (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (MarkerPath=#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg MarkerRaw=#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
# DEBUG_CLOSEOUT_MARKER_PATH (P0)
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerPath_dbg = $Marker
#requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg  = ""
try { if(Test-Path -LiteralPath $Marker -PathType Leaf){ #requires -Version 7.0
param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
Remove-Module PSReadLine -ErrorAction SilentlyContinue
try { if($IsWindows){ chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Fail([string]$m){ throw $m }

$RepoRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "..\.."))
$BrainDir = Join-Path $ProjectRoot "Brain_EGO_Dateien"

$marker = Join-Path $BrainDir "BRAIN_SYNC_LAST.txt"
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg = (Get-Content -LiteralPath $Marker -Raw -Encoding UTF8).Trim() } } catch {}
if(!(Test-Path -LiteralPath $marker -PathType Leaf)){
  Fail "FAIL: CLOSEOUT_MARKER_MISSING (Brain_EGO_Dateien/BRAIN_SYNC_LAST.txt fehlt)"
}

# last commit time (committer date in ISO 8601)
$commitIso = (git log -1 --format=%cI 2>$null)
if([string]::IsNullOrWhiteSpace($commitIso)){
  Fail "FAIL: CLOSEOUT_NO_GIT_LOG (git log -1 failed)"
}
$commitTime = [DateTimeOffset]::Parse($commitIso)

# parse brain marker time: accept ISO in file OR fallback file mtime
$raw = Get-Content -LiteralPath $marker -Raw -Encoding UTF8
$brainTime = $null
$m = [regex]::Match($raw, '(?m)(\d{4}-\d{2}-\d{2}[T\s]\d{2}:\d{2}:\d{2})')
if($m.Success){
  $brainTime = [DateTimeOffset]::Parse($m.Groups[1].Value.Replace(" ","T"))
} else {
  $brainTime = [DateTimeOffset](Get-Item -LiteralPath $marker).LastWriteTimeUtc
}

if($brainTime -lt $commitTime){
  Fail ("FAIL: CLOSEOUT_REQUIRED (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"_markerRaw_dbg) (BrainSync older than last commit)`nBrain={0}`nCommit={1}`nRun: pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\round-closeout.ps1" -f $brainTime.ToString('o'), $commitTime.ToString('o'))
}

"PASS: gate-closeout-after-commit"
