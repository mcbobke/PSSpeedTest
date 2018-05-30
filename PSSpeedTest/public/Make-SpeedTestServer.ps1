<#
    .SYNOPSIS
    Configures a designated network computer as a private domain iPerf3 server.

    .DESCRIPTION
    Installs and configures iPerf3 as a constantly-listening service on a network computer,
    and configures this computer to test bandwidth over the local network if 'Start-SpeedTest -LocalNetwork'
    is run.

    .PARAMETER ComputerName
    The name of the network computer that will act as an iPerf3 server.

    .PARAMETER Credential
    Network credentials used to authenticate to the network computer.

    .EXAMPLE
    Make-SpeedTestServer -ComputerName SERVER01 -Credential domain\user
#>

function Make-SpeedTestServer {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $Credential
    )

    Write-Output 'This cmdlet is not yet implemented!'
}