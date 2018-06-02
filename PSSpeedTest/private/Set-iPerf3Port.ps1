<#
    .SYNOPSIS
    Set the local firewall rules for the port that iPerf3 will listen on.

    .DESCRIPTION
    Set the local firewall rules for the port that iPerf3 will listen on.
    This will set inbound/outbound Allow TCP on the given port.

    .PARAMETER Port
    The port that iPerf3 will listen on.

    .EXAMPLE
    Set-iPerf3Port -Port "5201"
#>

function Set-iPerf3Port {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port
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

    if (!($inboundResult) -or !($outboundResult)) {
        throw 'Firewall rules could not be set'
    }
    else {
        return 'Set port'
    }
}