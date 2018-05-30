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

    $PackageProviderParams = @{
        Name = 'ChocolateyGet';
        Scope = 'CurrentUser';
        Force = $true;
        ForceBootstrap = $true;
        ErrorAction = 'Stop';
    }

    try {
        $result = Install-PackageProvider @PackageProviderParams
        Write-Verbose 'Chocolatey package provider/source successfully installed.'
        return $result
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}