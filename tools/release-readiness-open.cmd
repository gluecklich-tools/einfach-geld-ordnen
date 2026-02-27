@echo off
setlocal
cd /d "%~dp0\.."
echo === Release Readiness (open window) ===
echo Repo: %CD%
echo.
cmd /k pwsh -NoProfile -ExecutionPolicy Bypass -File "tools\release-readiness-minicheck.ps1"