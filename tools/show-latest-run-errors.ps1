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

# 1) Step-Fazit (welche Jobs/Steps failed)
try {
  $jobs = gh run view $id -R $Repo --json jobs --jq '.jobs[] | "\(.name) :: \(.conclusion)"'
  if($jobs){ "JOBS:"; $jobs }
} catch {}

# 2) Nur relevante Fehlerzeilen + Kontext
gh run view $id -R $Repo --log |
  Select-String -Pattern '##\[error\]|Exception:|Error:|completed with exit code|Traceback|cannot be retrieved|has not been set|ParserError|Missing:|Not Found|fatal:' -Context 0,6