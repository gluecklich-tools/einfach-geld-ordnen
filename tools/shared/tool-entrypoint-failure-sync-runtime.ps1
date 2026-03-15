param(
    [AllowEmptyString()][string]$ToolEntryPointPath,
    [string]$RequiredReadsTaskType = 'Tool-Entrypoint-Failure'
)

$script:ToolEntryPointPath = $null
if (-not [string]::IsNullOrWhiteSpace($ToolEntryPointPath)) {
    try {
        $script:ToolEntryPointPath = (Resolve-Path -LiteralPath $ToolEntryPointPath).Path
    }
    catch {
        $script:ToolEntryPointPath = [string]$ToolEntryPointPath
    }
}

$script:ToolFailureSyncToolsRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$script:ToolFailureSyncTool = Join-Path $script:ToolFailureSyncToolsRoot 'auto-sync-step-run-failure.ps1'
$script:ToolFailureSyncRequiredReadsTaskType = if ([string]::IsNullOrWhiteSpace($RequiredReadsTaskType)) {
    'Tool-Entrypoint-Failure'
}
else {
    [string]$RequiredReadsTaskType
}

function Invoke-ToolEntrypointFailureSyncBestEffort {
    param(
        [AllowEmptyString()][string]$FailureText
    )

    if ([string]::IsNullOrWhiteSpace($script:ToolEntryPointPath)) {
        return
    }

    if (-not (Test-Path -LiteralPath $script:ToolFailureSyncTool -PathType Leaf)) {
        return
    }

    try {
        $SafeFailureText = if ([string]::IsNullOrWhiteSpace($FailureText)) {
            'tool entrypoint failure'
        }
        else {
            [string]$FailureText
        }

        $SafePattern = [System.IO.Path]::GetFileName($script:ToolEntryPointPath)

        & pwsh -NoProfile -ExecutionPolicy Bypass -File $script:ToolFailureSyncTool `
            -FailureText $SafeFailureText `
            -RunnerPath $script:ToolEntryPointPath `
            -StepPath $script:ToolEntryPointPath `
            -Pattern $SafePattern `
            -RequiredReadsTaskType $script:ToolFailureSyncRequiredReadsTaskType
    }
    catch {
        Write-Host ('AUTO_FAILURE_TOOL_ENTRYPOINT_SYNC_FAIL: {0}' -f $_.Exception.Message)
    }
}

trap {
    $TrapText = try { $_ | Out-String } catch { 'tool entrypoint failure' }
    Invoke-ToolEntrypointFailureSyncBestEffort -FailureText $TrapText
    break
}