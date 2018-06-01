<#
    .SYNOPSIS
    Configures the iPerf3 server service that will listen on the given port.

    .DESCRIPTION
    Configures the iPerf3 server service that will listen on the given port.
    Sets the service to run Automatically.

    .PARAMETER Port
    The port that iPerf3 will listen on.

    .EXAMPLE
    Set-iPerf3Service -Port "5201"
#>

function Set-iPerf3Service {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port
    )

    $ServiceParams = @{
        Name = "iPerf3Server";
        BinaryPathName = "iperf3.exe -s -p $Port";
        DisplayName = "iPerf3 Speed Test Server";
        StartupType = "Automatic";
    }

    $serviceResult = New-Service @ServiceParams

    if (!($serviceResult)) {
        throw 'Service could not be created'
    }
    else {
        return 'Set service'
    }
}