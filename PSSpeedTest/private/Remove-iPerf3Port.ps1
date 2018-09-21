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

}