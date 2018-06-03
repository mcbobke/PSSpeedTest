<#
    .SYNOPSIS
    Set the local firewall rules for the port that iPerf3 will listen on.

    .DESCRIPTION
    Set the local firewall rules for the port that iPerf3 will listen on.
    This will set inbound/outbound Allow TCP on the given port.

    .PARAMETER Port
    The port that iPerf3 will listen on.

    .PARAMETER PassThru
    Returns the objects returned by "New-NetFirewallRule" for both the inbound and outbound rules, in an array.

    .EXAMPLE
    Set-iPerf3Port -Port "5201"

    .EXAMPLE
    Set-iPerf3Port -Port "5201" -PassThru
#>

function Set-iPerf3Port {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port,
        [Switch]
        $PassThru
    )

    $FirewallInboundParams = @{
        DisplayName = "iPerf3 Server Inbound TCP Rule";
        Direction = "Inbound";
        LocalPort = $Port;
        Protocol = "TCP";
        Action = "Allow";
        ErrorAction = "SilentlyContinue";
    }

    $FirewallOutboundParams = @{
        DisplayName = "iPerf3 Server Outbound TCP Rule";
        Direction = "Outbound";
        LocalPort = $Port;
        Protocol = "TCP";
        Action = "Allow";
        ErrorAction = "SilentlyContinue";
    }

    $inboundResult = New-NetFirewallRule @FirewallInboundParams
    $outboundResult = New-NetFirewallRule @FirewallOutboundParams

    if ($inboundResult -and $outboundResult) {
        Write-Verbose -Message 'iPerf3 server port firewall rules set.'
    }
    else {
        throw 'iPerf3 server port firewall rules could not be set'
    }

    if ($PassThru) {
        return @($inboundResult, $outboundResult)
    }
}