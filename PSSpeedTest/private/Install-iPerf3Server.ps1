<#
    .SYNOPSIS
    Installs and sets up iPerf3 on a domain-accessible computer.

    .DESCRIPTION
    Uses remoting to install the latest version of iPerf3 as a service on a domain computer, running it as a server service.

    .PARAMETER ComputerName
    The name of the local domain computer that will act as an iPerf3 server.

    .PARAMETER Port
    The port number that the iPerf3 server will listen on.

    .PARAMETER Credential
    Domain credentials used to authenticate to the domain computer, if necessary.

    .EXAMPLE
    Need to write examples.
#>

function Install-iPerf3Server {
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port,
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $Credential
    )
    
    Write-Host 'This cmdlet is not yet implemented!'
}