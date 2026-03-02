@echo off
setlocal

REM Public leak gate (must pass)
pwsh -NoProfile -ExecutionPolicy Bypass -File tools\gate-public-leaks.ps1
if errorlevel 1 exit /b %errorlevel%

REM Unsafe heredoc gate (must pass)
pwsh -NoProfile -ExecutionPolicy Bypass -File tools\gate-no-unsafe-heredoc.ps1
if errorlevel 1 exit /b %errorlevel%

REM P0: commit allowed only if staged files match last step allowlist proof
pwsh -NoProfile -ExecutionPolicy Bypass -File tools\gate-file-first-step-only.ps1 -RepoRoot . -ForCommit
if errorlevel 1 exit /b %errorlevel%

exit /b 0