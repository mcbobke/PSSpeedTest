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

    if (Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -ErrorAction 'SilentlyContinue') {
        Write-Verbose -Message 'iPerf3 package already installed.'
        return 'Installed'
    }

    if (!(Get-PackageProvider -ListAvailable -Name 'ChocolateyGet' -ErrorAction 'SilentlyContinue')) {
        Write-Verbose -Message 'ChocolateyGet package provider not found; installing.'
        try {
            Install-ChocolateyGetProvider
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    Write-Verbose -Message 'Importing ChocolateyGet package provider and installing iperf3.'
    Import-PackageProvider -Name 'ChocolateyGet'
    Install-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -Force -ErrorAction 'SilentlyContinue'
    if (Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -ErrorAction 'SilentlyContinue') {
        Write-Verbose -Message 'iPerf3 package installed.'
        return 'Installed'
    }
    else {
        throw 'iPerf3 failed to install!'
    }
}