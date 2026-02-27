@echo off
setlocal
REM Public leak gate (must pass)
pwsh -NoProfile -File tools\gate-public-leaks.ps1
if errorlevel 1 exit /b %errorlevel%
exit /b 0