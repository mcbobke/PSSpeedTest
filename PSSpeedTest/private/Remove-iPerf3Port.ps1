<#
    .SYNOPSIS
    Removes the local firewall rules for the port that iPerf3 was listening on.

    .DESCRIPTION
    Removes the local firewall rules for the port that iPerf3 was listening on.
    This will remove the configured firewall rules from Windows Firewall.

    .EXAMPLE
    Remove-iPerf3Port
#>

function Remove-iPerf3Port {
    [CmdletBinding()]
    Param(

    )

    Write-Verbose -Message "Removing inbound and outbound iperf3 firewall rules."

    try {
        Get-NetFirewallRule -DisplayName "iPerf3 Server Inbound TCP Rule" | Remove-NetFirewallRule
        Get-NetFirewallRule -DisplayName "iPerf3 Server Outbound TCP Rule" | Remove-NetFirewallRule
    }
    catch {
        Write-Verbose -Message "Firewall rules not found - no action taken."
    }
}