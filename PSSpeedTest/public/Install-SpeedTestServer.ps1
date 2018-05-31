<#
    .SYNOPSIS
    Configures a designated domain computer as a private local iPerf3 server.

    .DESCRIPTION
    Configures iPerf3 as a constantly-listening service on a domain computer.

    .PARAMETER ComputerName
    The name of the local domain computer that will act as an iPerf3 server.
    
    .PARAMETER Port
    The port number that the iPerf3 server will listen on.
    If not specified, the default port '5201' will be used.

    .PARAMETER Credential
    Domain credentials used to authenticate to the domain computer, if necessary.

    .EXAMPLE
    Need to write examples.
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

    Write-Host 'This cmdlet is not yet implemented!'
}