<#
    .SYNOPSIS
    Configures a designated network computer as a private domain iPerf3 server.

    .DESCRIPTION
    Installs and configures iPerf3 as a constantly-listening service on a network computer,
    and configures this computer to test bandwidth over the local network if 'Start-SpeedTest -LocalNetwork'
    is run.

    .PARAMETER ComputerName
    The name of the network computer that will act as an iPerf3 server.
    
    .PARAMETER Port
    The port number that the iPerf3 server will listen on.

    .PARAMETER Credential
    Network credentials used to authenticate to the network computer.

    .EXAMPLE
    Install-SpeedTestServer -ComputerName SERVER01 -Credential domain\user
#>

function Install-SpeedTestServer {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,
        [ValidateNotNullOrEmpty()]
        [String]
        $Port,
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $Credential
    )

    Write-Host 'This cmdlet is not yet implemented!'
}