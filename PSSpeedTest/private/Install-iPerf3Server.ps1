<#
    .SYNOPSIS
    Installs and sets up iPerf3 on a domain-accessible server.

    .DESCRIPTION
    Uses remoting to install the latest version of iPerf3 as a service on a network computer, running it as a server service.

    .PARAMETER ComputerName
    The name of the network computer that will act as an iPerf3 server.

    .PARAMETER Port
    The port number that the iPerf3 server will listen on.

    .PARAMETER Credential
    Network credentials used to authenticate to the network computer.

    .EXAMPLE
    Install-iPerf3Server -ComputerName SERVER01 -Port 5201 -Credential domain\user
#>

function Install-iPerf3Server {
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