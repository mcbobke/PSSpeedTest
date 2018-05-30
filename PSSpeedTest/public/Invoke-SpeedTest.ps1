<#
    .SYNOPSIS
    Starts a bandwidth test over the internet or on the local private network.

    .DESCRIPTION
    Starts a bandwidth test with iPerf3 over the internet against a public iPerf3 server, or on the local private network against a previously-configured iPerf3 server.

    .PARAMETER Internet
    Forces the bandwitdth test to run over the internet against a public iPerf3 server.
    If the Server parameter is not specified, this will attempt to use the default server saved in the config.json file.
    If a default server is not specified in the configuration file, the user will be prompted to specify a default server.

    .PARAMETER Local
    Forces the bandwidth test to run over the local network against a domain-accessible iPerf3 server.
    If the Server parameter is not specified, this will attempt to use the default server saved in the config.json file.
    If a default server is not specified in the configuration file, the user will be prompted to specify a default server.

    .PARAMETER Server
    The hostname or IP address of a server that is running iPerf3 as a listening service.

    .PARAMETER Port
    The port on the iPerf3 server that iPerf3 is listening on.
    This will run the local iPerf3 client on the same port as they must match on the client and the server.

    .EXAMPLE
    Invoke-SpeedTest -Internet -Server example.somewhere.com
    Runs a bandwidth test against public iPerf3 server 'example.somewhere.com' using the default iPerf3 port '5201'.

    .EXAMPLE
    Invoke-SpeedTest -Internet -Server 20.19.57.21 -Port 7777
    Runs a bandwidth test against public iPerf3 server '20.19.57.21' on port '7777'.

    .EXAMPLE
    Invoke-SpeedTest -Internet
    Runs a bandwidth test against the configured default public iPerf3 server, or prompts for one to be specified prior to running the test.

    .EXAMPLE
    Invoke-SpeedTest -Local -Server iPerf3.fqdn.com
    Runs a bandwidth test against local domain iPerf3 server 'iPerf3.fqdn.com' using the default iPerf3 port '5201'.

    .EXAMPLE
    Invoke-SpeedTest -Local -Server 10.1.1.20 -Port 7777
    Runs a bandwidth test against local domain iPerf3 server '10.1.1.20' on port '7777'.

    .EXAMPLE
    Invoke-SpeedTest -Local
    Runs a bandwidth test against the configured default local domain iPerf3 server, or prompts for one to be configured prior to running the test.
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
        [Parameter(Mandatory=$true,
            ParameterSetName="Specified")]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port
    )

    Write-Host 'This cmdlet is not yet implemented!'
}