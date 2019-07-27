function Install-SpeedTestServer {
    <#
        .SYNOPSIS
        Configures the local computer as an iPerf3 server.

        .DESCRIPTION
        Configures iPerf3 as a constantly-listening service on the local computer.
        
        .PARAMETER Port
        The port number that the iPerf3 server will listen on.
        If not specified, the default port '5201' will be used.

        .PARAMETER PassThru
        Returns the object returned by "Get-Process -Name 'iperf3' -ErrorAction 'SilentlyContinue'".

        .EXAMPLE
        Install-SpeedTestServer
        Sets up the local computer as an iPerf3 server listening on default iPerf port 5201.

        .EXAMPLE
        Install-SpeedTestServer -Port 5555
        Sets up the local computer as an iPerf3 server listening on port 5555.

        .EXAMPLE
        Install-SpeedTestServer -Port 5555 -PassThru
    #>

    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [String]
        $Port = '5201',
        [Switch]
        $PassThru
    )

    $timeout = 30 # Seconds

    if (!(Test-Administrator)) {
        throw 'You are not running as administrator. Please re-run this function after opening PowerShell as administrator.'
    }

    Write-Verbose -Message "Setting up iPerf3 server on local machine on port $Port."
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
        } else {
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