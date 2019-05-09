<#
    .SYNOPSIS
    Installs the latest version of iPerf3 on this computer.

    .DESCRIPTION
    Installs the latest version of iPerf3 on this computer from the ChocolateyGet package source.

    .PARAMETER PassThru
    Returns the object returned by "Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -ErrorAction 'SilentlyContinue'".

    .EXAMPLE
    Install-iPerf3

    .EXAMPLE
    Install-iPerf3 -PassThru
#>

function Install-iPerf3 {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param (
        [Switch]
        $PassThru
    )

    try {
        Write-Verbose -Message "Checking for existing iperf3 package."
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

    Write-Verbose -Message 'Importing ChocolateyGet package provider and installing iperf3 package as it was not found.'
    Import-PackageProvider -Name 'ChocolateyGet'

    $PackageParams = @{
        Name = 'iperf3';
        ProviderName = 'ChocolateyGet';
        Force = $true;
        ErrorAction = 'SilentlyContinue';
        Confirm = $false;
    }
    if ($PSCmdlet.ShouldContinue("Can package $($PackageParams['Name']) be installed?", 'Installing iPerf3')) {
        Install-Package @PackageParams | Out-Null
    }

    $toReturn = Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' -ErrorAction 'SilentlyContinue'
    if ($toReturn) {
        Write-Verbose -Message 'iPerf3 package installed.'
    }
    else {
        throw "iPerf3 failed to install or was not installed. Message: {0}" -f $error[0].Exception.message
    }

    if ($PassThru) {
        return $toReturn
    }
}