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
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="Medium")]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port,
        [Switch]
        $PassThru
    )

    Write-Verbose -Message "Setting inbound and outbound iperf3 firewall rules."

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

    if ($PSCmdlet.ShouldProcess("iperf3 Inbound/Outbound Firewall Rules", "New-NetFirewallRule")) {
        $inboundResult = New-NetFirewallRule @FirewallInboundParams
        $outboundResult = New-NetFirewallRule @FirewallOutboundParams
    }

    if ($inboundResult -and $outboundResult) {
        Write-Verbose -Message 'iPerf3 server port firewall rules set.'
    }
    else {
        throw "iPerf3 server port firewall rules could not be set. Message: {0}" -f $error[0].Exception.message
    }

    if ($PassThru) {
        return @($inboundResult, $outboundResult)
    }
}