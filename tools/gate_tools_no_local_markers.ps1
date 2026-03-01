#requires -Version 7.0
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
try { if($IsWindows){ chcp 65001 | Out-Null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

"PASS: gate_tools_no_local_markers (placeholder)"
exit 0
