<#
    .SYNOPSIS
    Installs the ChocolateyGet package provider/source on this computer.

    .DESCRIPTION
    Installs the ChocolateyGet package provider/source on this computer forcefully.

    .PARAMETER PassThru
    Returns the object returned by "Get-PackageProvider -Name 'ChocolateyGet' -ErrorAction 'SilentlyContinue'".

    .EXAMPLE
    Install-ChocolateyGetProvider

    .EXAMPLE
    Install-ChocolateyGetProvider -PassThru
#>

function Install-ChocolateyGetProvider {
    [CmdletBinding()]
    Param (
        [Switch]
        $PassThru
    )

    Write-Verbose -Message "Checking for existence of ChocolateyGet provider."
    $toReturn = Get-PackageProvider -Name 'ChocolateyGet' -ErrorAction 'SilentlyContinue'
    if ($toReturn) {
        Write-Verbose -Message 'Chocolatey package provider/source already installed.'
        if ($PassThru) {
            return $toReturn
        }
        else {
            return
        }
    }

    $PackageProviderParams = @{
        Name = 'ChocolateyGet';
        Scope = 'CurrentUser';
        Force = $true;
        ErrorAction = 'SilentlyContinue';
    }

    Write-Verbose -Message 'Installing ChocolateyGet PackageProvider as it was not found.'
    Install-PackageProvider @PackageProviderParams | Out-Null
    $toReturn = Get-PackageProvider -Name 'ChocolateyGet' -ErrorAction 'SilentlyContinue'
    
    if ($toReturn) {
        Write-Verbose -Message 'Chocolatey package provider/source successfully installed.'
    }
    else {
        throw "ChocolateyGet failed to install. Message: $($error[0].Exception.message)"
    }

    if ($PassThru) {
        return $toReturn
    }
}