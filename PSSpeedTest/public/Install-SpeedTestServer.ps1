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

    .EXAMPLE
    Install-SpeedTestServer -ComputerName SERVER01 -Port 5201 -Credential domain\user
    Sets up computer SERVER01 as an iPerf3 server listening on port 5201.
    This runs the appropriate setup functions under the 'domain\user' credential.

    .EXAMPLE
    Install-SpeedTestServer -Port 5555
    Sets up the local computer as an iPerf3 server listening on port 5555.
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
        $Credential
    )

    if (!($ComputerName)) {
        Write-Verbose -Message "Setting up server on local machine on port $Port."
        Install-ChocolateyGetProvider | Out-Null
        Install-iPerf3 | Out-Null
        Set-iPerf3Port -Port $Port | Out-Null
        Set-iPerf3Task -Port $Port | Out-Null
        Write-Verbose -Message "Waiting for 10 seconds for iPerf3 executable to launch."
        Start-Sleep -Seconds 10

        if (Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue') {
            return "iPerf3 Server started on port $Port."
        }
        else {
            throw "iPerf3 Server failed to start on port $Port."
        }
    }
    else {
        if (!($Credential)) {
            Write-Verbose -Message "Setting up server on domain machine $ComputerName on port $Port."
            Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Install-ChocolateyGetProvider} | Out-Null
            Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Install-iPerf3} | Out-Null
            Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Set-iPerf3Port} -ArgumentList $Port | Out-Null
            Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Set-iPerf3Task} -ArgumentList $Port | Out-Null
            Write-Verbose -Message "Waiting for 5 seconds for iPerf3 executable to launch."
            Start-Sleep -Seconds 5

            $getProcessResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'}
            if ($getProcessResult) {
                return "iPerf3 Server started on computer $ComputerName on port $Port."
            }
            else {
                throw "iPerf3 Server failed to start on computer $ComputerName on port $Port."
            }
        }
        else {
            Write-Verbose -Message "Setting up server on domain machine $ComputerName on port $Port with credential $Credential."
            Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Install-ChocolateyGetProvider} -Credential $Credential | Out-Null
            Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Install-iPerf3} -Credential $Credential | Out-Null
            Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Set-iPerf3Port} -ArgumentList $Port -Credential $Credential | Out-Null
            Invoke-Command -ComputerName $ComputerName -ScriptBlock ${Function:Set-iPerf3Task} -ArgumentList $Port -Credential $Credential | Out-Null
            Write-Verbose -Message "Waiting for 5 seconds for iPerf3 executable to launch."
            Start-Sleep -Seconds 5

            $getProcessResult = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'} -Credential $Credential
            if ($getProcessResult) {
                return "iPerf3 Server started on computer $ComputerName on port $Port with credential $Credential."
            }
            else {
                throw "iPerf3 Server failed to start on computer $ComputerName on port $Port with credential $Credential."
            }
        }
    }
}