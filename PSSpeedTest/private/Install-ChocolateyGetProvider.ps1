<#
    .SYNOPSIS
    Installs the ChocolateyGet package provider/source on this computer.

    .DESCRIPTION
    Installs the ChocolateyGet package provider/source on this computer forcefully.

    .EXAMPLE
    Install-ChocolateyGetProvider
#>

function Install-ChocolateyGetProvider {
    [CmdletBinding()]
    Param (
    )

    if (Get-PackageProvider -Name 'ChocolateyGet' -ErrorAction 'SilentlyContinue') {
        Write-Verbose -Message 'Chocolatey package provider/source already installed.'
        return 'Installed'
    }

    $PackageProviderParams = @{
        Name = 'ChocolateyGet';
        Scope = 'CurrentUser';
        Force = $true;
        ForceBootstrap = $true;
        ErrorAction = 'SilentlyContinue';
    }

    Write-Verbose -Message 'Installing ChocolateyGet PackageProvider.'
    Install-PackageProvider @PackageProviderParams
    if (Get-PackageProvider -Name 'ChocolateyGet' -ErrorAction 'SilentlyContinue') {
        Write-Verbose -Message 'Chocolatey package provider/source successfully installed.'
        return 'Installed'
    }
    else {
        throw 'ChocolateyGet failed to install!'
    }
}