param(
  [string]$Repo = 'gluecklich-tools/einfach-geld-ordnen',
  [string]$Workflow = 'EGO Gates',
  [int]$Limit = 1
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
try { Remove-Module PSReadLine -ErrorAction SilentlyContinue } catch {}
try { if ($IsWindows) { chcp 65001 > $null } } catch {}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$id = (gh run list -R $Repo -w $Workflow -L $Limit --json databaseId --jq '.[0].databaseId').Trim()
if([string]::IsNullOrWhiteSpace($id)){ throw "STOP: could not resolve latest run id." }

"LAST RUN ID: $id"
gh run view $id -R $Repo --log |
  Select-String -Pattern 'PASS:|##\[error\]|Exception:|completed with exit code' -Context 0,2