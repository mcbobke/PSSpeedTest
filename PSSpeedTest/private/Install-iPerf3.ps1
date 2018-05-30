<#
    .SYNOPSIS
    Installs the latest version of iPerf3 on this computer.

    .DESCRIPTION
    Installs the latest version of iPerf3 on this computer from the Chocolatey package source.

    .EXAMPLE
    Install-iPerf3
#>

function Install-iPerf3 {
    [CmdletBinding()]
    Param (
    )

    if (!(Get-PackageProvider -ListAvailable -Name 'ChocolateyGet')) {
        Write-Verbose -Message 'ChocolateyGet package provider not found; installing.'
        try {
            Install-ChocolateyGetProvider
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    Write-Verbose -Message 'Importing ChocolateyGet package provider and installing iperf3.'
    try {
        Import-PackageProvider -Name 'ChocolateyGet'
        $result = Install-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -Force
        Write-Verbose -Message 'iPerf3 package installed.'
        return $result
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}