<#
    .SYNOPSIS
    Starts a bandwidth test over the internet or on the local private network.

    .DESCRIPTION
    Starts a bandwidth test with iPerf3 over the internet against a public iPerf3 server, or on the local private network against a previously-configured iPerf3 server.

    .PARAMETER Internet
    Forces the bandwitdth test to run over the internet against a public iPerf3 server.
    If a default public iPerf3 server is not specified in the configuration file, the user will be prompted to run Set-SpeedTestConfig.

    .PARAMETER Local
    Forces the bandwidth test to run over the local network against a locally-accessible iPerf3 server.
    If a default server is not specified in the configuration file, the user will be prompted to run Set-SpeedTestConfig.

    .PARAMETER Server
    The hostname or IP address of a server that is running iPerf3 as a listening service.

    .PARAMETER Port
    The port on the iPerf3 server that iPerf3 is listening on.
    This will run the local iPerf3 client on the same port as they must match on the client and the server.
    If Server is specified and Port is not, the default port '5201' will be used.

    .EXAMPLE
    Invoke-SpeedTest -Internet
    Runs a bandwidth test against default public iPerf3 server that is stored in the configuration.
    If there is no stored default, you will be prompted to set one.

    .EXAMPLE
    Invoke-SpeedTest -Local
    Runs a bandwidth test against default local iPerf3 server that is stored in the configuration.
    If there is no stored default, you will be prompted to set one.

    .EXAMPLE
    Invoke-SpeedTest -Server local.domain.com
    Runs a bandwidth test against iPerf3 server 'local.domain.com' on default port '5201'.

    .EXAMPLE
    Invoke-SpeedTest -Server 20.19.57.21 -Port 7777
    Runs a bandwidth test against iPerf3 server '20.19.57.21' on port '7777'.
#>

function Invoke-SpeedTest {
    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName="Internet")]
        [Switch]
        $Internet,
        [Parameter(ParameterSetName="Local")]
        [Switch]
        $Local,
        [Parameter(Mandatory=$true,
            ParameterSetName="Specified")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Server,
        [Parameter(ParameterSetName="Specified")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port
    )

    Write-Verbose -Message "Starting speed test."

    Install-ChocolateyGetProvider
    Install-iPerf3

    $config = Get-SpeedTestConfig
    $command = "iperf3.exe "

    if ($Internet) {
        Write-Verbose -Message "Defaulting to stored Internet speed test server settings."
        if (!($config.defaultInternetServer.defaultServer)) {
            throw "No default Internet server configured - run Set-SpeedTestConfig."
        }
        else {
            $command = $command + "-c $($config.defaultInternetServer.defaultServer) "
            if ($config.defaultInternetServer.defaultPort) {
                $command = $command + "-p $($config.defaultInternetServer.defaultPort) "
            }
            else {
                $command = $command + "-p $($config.defaultPort) "
            }
        }
    }
    elseif ($Local) {
        Write-Verbose -Message "Defaulting to stored Local speed test server settings."
        if (!($config.defaultLocalServer.defaultServer)) {
            throw "No default Local server configured - run Set-SpeedTestConfig."
        }
        else {
            $command = $command + "-c $($config.defaultLocalServer.defaultServer) "
            if ($config.defaultLocalServer.defaultPort) {
                $command = $command + "-p $($config.defaultLocalServer.defaultPort) "
            }
            else {
                $command = $command + "-p $($config.defaultPort) "
            }
        }
    }
    elseif ($Server) {
        Write-Verbose -Message "Server: $Server and port: $Port specified manually."
        $command = $command + "-c $Server "
        if ($Port) {
            $command = $command + "-p $Port "
        }
        else {
            $command = $command + "-p $($config.defaultPort) "
        }
    }

    $command = $command + "-f m -J"

    Write-Verbose -Message "Executing command: $command"

    $resultsJSON = Invoke-Expression -Command $command
    $resultsPS = $resultsJSON | ConvertFrom-Json

    if ($resultsPS.error) {
        if ($resultsPS.error -match 'unable to connect to server'){
            throw "Catastrophic error occurred: $($resultsPS.error)"
        }
        else {
            Write-Warning -Message "Problem occurred: $($resultsPS.error)"
            $megabitsPerSecSent = 0
            $megabitsPerSecReceived = 0
        }
    }
    else {
        Write-Verbose -Message "Speed test successful; calculating mbps and returning PSCustomObject."
        $megabitsPerSecSent = (($resultsPS.end.sum_sent.bits_per_second) / 1000000.0).ToInt32($null)
        $megabitsPerSecReceived = (($resultsPS.end.sum_received.bits_per_second) / 1000000.0).ToInt32($null)
    }

    $returnObj = New-Object -TypeName 'PSCustomObject' @{
        megabitsPerSecSent = $megabitsPerSecSent;
        megabitsPerSecReceived = $megabitsPerSecReceived;
    }

    return $returnObj
}