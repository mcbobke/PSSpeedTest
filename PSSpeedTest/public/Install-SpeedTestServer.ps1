<#
    .SYNOPSIS
    Configures the local or a domain computer as an iPerf3 server.

    .DESCRIPTION
    Configures iPerf3 as a constantly-listening service on the local or a domain computer.

    .PARAMETER ComputerName
    The name of the domain computer that will act as an iPerf3 server.
    If this parameter is not specified, the local computer will be configured as an iPerf3 server.
    
    .PARAMETER Port
    The port number that the iPerf3 server will listen on.
    If not specified, the default port '5201' will be used.

    .PARAMETER Credential
    Domain credentials used to authenticate to a domain computer, if necessary.

    .PARAMETER PassThru
    Returns the object returned by "Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'".

    .EXAMPLE
    Install-SpeedTestServer -ComputerName SERVER01 -Port 5201 -Credential domain\user
    Sets up computer SERVER01 as an iPerf3 server listening on port 5201.
    This runs the appropriate setup functions under the 'domain\user' credential.

    .EXAMPLE
    Install-SpeedTestServer -Port 5555
    Sets up the local computer as an iPerf3 server listening on port 5555.

    .EXAMPLE
    Install-SpeedTestServer -Port 5555 -PassThru
#>

function Install-SpeedTestServer {
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,
        [ValidateNotNullOrEmpty()]
        [String]
        $Port = '5201',
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $Credential,
        [Switch]
        $PassThru
    )

    $timeout = 30 # Seconds

    if (!(Test-Administrator)) {
        throw "You are not running as administrator. Please re-run this function after opening PowerShell as administrator."
    }

    if (!($ComputerName)) {
        Write-Verbose -Message "Setting up server on local machine on port $Port."
        Install-ChocolateyGetProvider
        Install-iPerf3
        Set-iPerf3Port -Port $Port
        Set-iPerf3Task -Port $Port

        $timeoutTimer = [Diagnostics.Stopwatch]::StartNew()
        $processTest = $false
        while ($timeoutTimer.Elapsed.TotalSeconds -lt $timeout) {
            $getProcessResult = Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'
            if ($getProcessResult) {
                Write-Verbose -Message "iPerf3 Server started on port $Port."
                $processTest = $true
                break
            }
            else {
                Start-Sleep -Seconds 3
            }
        }
        $timeoutTimer.Stop()

        if (!($processTest)) {
            throw "iPerf3 Server failed to start on port $Port. Timeout of $timeout seconds reached."
        }

        if ($PassThru) {
            return $getProcessResult
        }
    }
    else {
        if (!($Credential)) {
            Write-Verbose -Message "Setting up server on domain machine $ComputerName on port $Port."
            try {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Install-ChocolateyGetProvider}
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Install-iPerf3}
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Set-iPerf3Port} -ArgumentList $Port
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Set-iPerf3Task} -ArgumentList $Port
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            $timeoutTimer = [Diagnostics.Stopwatch]::StartNew()
            $processTest = $false
            while ($timeoutTimer.Elapsed.TotalSeconds -lt $timeout) {
                $getProcessResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'}
                if ($getProcessResult) {
                    Write-Verbose -Message "iPerf3 Server started on computer $ComputerName on port $Port."
                    $processTest = $true
                    break
                }
                else {
                    Start-Sleep -Seconds 3
                }
            }
            $timeoutTimer.Stop()

            if (!($processTest)) {
                throw "iPerf3 Server failed to start on computer $ComputerName on port $Port. Timeout of $timeout seconds reached."
            }

            if ($PassThru) {
                return $getProcessResult
            }
        }
        else {
            Write-Verbose -Message "Setting up server on domain machine $ComputerName on port $Port with credential $Credential."
            try {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Install-ChocolateyGetProvider} -Credential $Credential
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Install-iPerf3} -Credential $Credential
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Set-iPerf3Port} -ArgumentList $Port -Credential $Credential
                Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Set-iPerf3Task} -ArgumentList $Port -Credential $Credential
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            $timeoutTimer = [Diagnostics.Stopwatch]::StartNew()
            $processTest = $false
            while ($timeoutTimer.Elapsed.TotalSeconds -lt $timeout) {
                $getProcessResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'} -Credential $Credential
                if ($getProcessResult) {
                    Write-Verbose -Message "iPerf3 Server started on computer $ComputerName on port $Port with credential $Credential."
                    $processTest = $true
                    break
                }
                else {
                    Start-Sleep -Seconds 3
                }
            }
            $timeoutTimer.Stop()

            if (!($processTest)) {
                throw "iPerf3 Server failed to start on computer $ComputerName on port $Port with credential $Credential. Timeout of $timeout seconds reached."
            }

            if ($PassThru) {
                return $getProcessResult
            }
        }
    }
}