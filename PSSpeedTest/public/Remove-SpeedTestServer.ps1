<#
    .SYNOPSIS
    Removes iPerf3 server configuration from the local or a domain computer.

    .DESCRIPTION
    Removes iPerf3 server configuration from the local or a domain computer.
    This includes the iPerf3 package, firewall rules, and scheduled task.

    .PARAMETER ComputerName
    The name of the domain computer that is acting as an iPerf3 server.
    If this parameter is not specified, the local computer will be targeted.

    .PARAMETER Credential
    Domain credentials used to authenticate to a domain computer, if necessary.

    .EXAMPLE
    Remove-SpeedTestServer -ComputerName SERVER01 -Credential domain\user
    Decommissions iPerf3 server SERVER01.
    This runs the appropriate setup functions under the 'domain\user' credential.

    .EXAMPLE
    Remove-SpeedTestServer
    Decommissions the local iPerf3 server.

    .EXAMPLE
    Install-SpeedTestServer -Port 5555 -PassThru
#>

function Remove-SpeedTestServer {
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $Credential
    )

    $timeout = 30 # Seconds

    if (!(Test-Administrator)) {
        throw "You are not running as administrator. Please re-run this function after opening PowerShell as administrator."
    }

    if (!($ComputerName)) {
        Write-Output "Decommissioning local iPerf3 server."

        # Remove scheduled task before stopping process to prevent auto-trigger
        Remove-iPerf3Task
        Write-Verbose -Message "Stopping iPerf3 process."
        Get-Process -Name 'iperf3' | Stop-Process
        Remove-iPerf3Port
        Remove-iPerf3

        $timeoutTimer = [Diagnostics.Stopwatch]::StartNew()
        $processTest = $false
        while ($timeoutTimer.Elapsed.TotalSeconds -lt $timeout) {
            $getProcessResult = Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'
            if (!$getProcessResult) {
                Write-Verbose -Message "iPerf3 process does not exist."
                $processTest = $true
                break
            }
            else {
                Start-Sleep -Seconds 3
            }
        }
        $timeoutTimer.Stop()

        if (!($processTest)) {
            throw "iPerf3 process still running even though decommission was attempted. Timeout of $timeout seconds reached."
        }
    }
    else {
        if (!($Credential)) {
            Write-Verbose -Message "Decommissioning iPerf3 server on domain computer $ComputerName."
            try {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Remove-iPerf3Task}
                Write-Verbose -Message "Stopping iPerf3 process."
                Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Process -Name 'iperf3' | Stop-Process}
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Remove-iPerf3Port}
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Remove-iPerf3}
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            $timeoutTimer = [Diagnostics.Stopwatch]::StartNew()
            $processTest = $false
            while ($timeoutTimer.Elapsed.TotalSeconds -lt $timeout) {
                $getProcessResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'}
                if (!$getProcessResult) {
                    Write-Verbose -Message "iPerf3 process does not exist on $ComputerName."
                    $processTest = $true
                    break
                }
                else {
                    Start-Sleep -Seconds 3
                }
            }
            $timeoutTimer.Stop()

            if (!($processTest)) {
                throw "iPerf3 process still running even though decommission was attempted on computer $ComputerName. Timeout of $timeout seconds reached."
            }
        }
        else {
            Write-Verbose -Message "Decommissioning iPerf3 server on domain computer $ComputerName with credential $Credential."
            try {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Remove-iPerf3Task} -Credential $Credential
                Write-Verbose -Message "Stopping iPerf3 process."
                Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Process -Name 'iperf3' | Stop-Process} -Credential $Credential
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Remove-iPerf3Port} -Credential $Credential
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Remove-iPerf3} -Credential $Credential
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            $timeoutTimer = [Diagnostics.Stopwatch]::StartNew()
            $processTest = $false
            while ($timeoutTimer.Elapsed.TotalSeconds -lt $timeout) {
                $getProcessResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'} -Credential $Credential
                if ($getProcessResult) {
                    Write-Verbose -Message "iPerf3 process does not exist on $ComputerName."
                    $processTest = $true
                    break
                }
                else {
                    Start-Sleep -Seconds 3
                }
            }
            $timeoutTimer.Stop()

            if (!($processTest)) {
                throw "iPerf3 process still running even though decommission was attempted on computer $ComputerName with credential $Credential. Timeout of $timeout seconds reached."
            }
        }
    }
}