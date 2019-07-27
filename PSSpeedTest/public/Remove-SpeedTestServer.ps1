function Remove-SpeedTestServer {
    <#
        .SYNOPSIS
        Removes iPerf3 server configuration from the local computer.

        .DESCRIPTION
        Removes iPerf3 server configuration from the local computer.
        This includes the iPerf3 package, firewall rules, and scheduled task.

        .EXAMPLE
        Remove-SpeedTestServer
        Decommissions the local iPerf3 server.
    #>

    [CmdletBinding()]
    Param ()

    $timeout = 30 # Seconds

    if (!(Test-Administrator)) {
        throw 'You are not running as administrator. Please re-run this function after opening PowerShell as administrator.'
    }

    Write-Output 'Decommissioning local iPerf3 server.'

    # Remove scheduled task before stopping process to prevent auto-trigger
    Remove-iPerf3Task

    Write-Verbose -Message 'Stopping iPerf3 process.'
    try {
        Get-Process -Name 'iperf3' | Stop-Process
    } catch {
        Write-Verbose -Message 'iPerf3 process not found - no action taken.'
    }

    Remove-iPerf3Port
    Remove-iPerf3

    $timeoutTimer = [Diagnostics.Stopwatch]::StartNew()
    $processTest = $false
    while ($timeoutTimer.Elapsed.TotalSeconds -lt $timeout) {
        $getProcessResult = Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'
        if (!$getProcessResult) {
            Write-Verbose -Message 'iPerf3 process does not exist.'
            $processTest = $true
            break
        } else {
            Start-Sleep -Seconds 3
        }
    }
    $timeoutTimer.Stop()

    if (!($processTest)) {
        throw "iPerf3 process still running even though decommission was attempted. Timeout of $timeout seconds reached."
    }
}