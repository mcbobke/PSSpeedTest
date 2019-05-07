<#
    .SYNOPSIS
    Removes the iPerf3 Chocolatey package from this computer.

    .DESCRIPTION
    Removes the iPerf3 package from this computer as installed from the ChocolateyGet package source.

    .EXAMPLE
    Remove-iPerf3
#>

function Remove-iPerf3 {
    [CmdletBinding()]
    Param ()

    Write-Verbose -Message "Removing 'iperf3' package."

    try {
        Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' | Uninstall-Package -Force
    }
    catch {
        Write-Verbose -Message "Package 'iperf3' not found as installed by ChocolateyGet provider - no action taken."
    }
}