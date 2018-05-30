<#
    .SYNOPSIS
    Installs and sets up iPerf3 on a domain-accessible server.

    .DESCRIPTION
    Uses remoting to install the latest version of iPerf3 as a service on a network computer, running it as a server service.

    .PARAMETER ComputerName
    The name of the network computer that will act as an iPerf3 server.

    .PARAMETER Credential
    Network credentials used to authenticate to the network computer.

    .EXAMPLE
    Setup-iPerf3Server -ComputerName SERVER01 -Credential domain\user
#>

function Install-iPerf3Server {
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