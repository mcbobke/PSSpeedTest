<#
    .SYNOPSIS
    Installs the latest version of iPerf3 on this computer.

    .DESCRIPTION
    Installs the latest version of iPerf3 on this computer from the ChocolateyGet package source.

    .PARAMETER Force
    Forces installation of the iPerf3 package if not already installed.

    .PARAMETER PassThru
    Returns the object returned by "Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -ErrorAction 'SilentlyContinue'".

    .EXAMPLE
    Install-iPerf3

    .EXAMPLE
    Install-iPerf3 -PassThru
#>

function Install-iPerf3 {
    [CmdletBinding()]
    Param (
        [Switch]
        $Force,
        [Switch]
        $PassThru
    )

    try {
        Write-Verbose -Message "Checking for existence iperf3 package."
        Import-PackageProvider -Name 'ChocolateyGet' -ErrorAction 'Stop'
        $toReturn = Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -Force -ErrorAction 'SilentlyContinue'

        if ($toReturn) {
            Write-Verbose -Message 'iPerf3 package already installed.'
            if ($PassThru) {
                return $toReturn
            }
            else {
                return
            }
        }
    }
    catch {
        if (!(Get-PackageProvider -ListAvailable -Name 'ChocolateyGet' -ErrorAction 'SilentlyContinue')) {
            Write-Verbose -Message 'ChocolateyGet package provider not found; installing.'
            try {
                Install-ChocolateyGetProvider
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }

    if (!($Force)) {
        $response = '0'
        do {
            $response = Read-Host -Prompt "The 'iperf3' package is required. Continue with installation? (y/n)"
            switch ($response) {
                'y' {
                    break
                }
                'n' {
                    Write-Verbose -Message "The operation was aborted."
                    return
                }
                Default {
                    Write-Verbose -Message "Invalid input. Expected 'y' or 'n'."
                }
            }
        } while ($true)
    }

    Write-Verbose -Message 'Importing ChocolateyGet package provider and installing iperf3 package as it was not found.'
    Import-PackageProvider -Name 'ChocolateyGet'
    Install-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -Force -ErrorAction 'SilentlyContinue' | Out-Null
    $toReturn = Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -Force -ErrorAction 'SilentlyContinue'

    if ($toReturn) {
        Write-Verbose -Message 'iPerf3 package installed.'
    }
    else {
        throw "iPerf3 failed to install. Message: {0}" -f $error[0].Exception.message
    }

    if ($PassThru) {
        return $toReturn
    }
}