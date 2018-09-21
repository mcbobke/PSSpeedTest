<#
    .SYNOPSIS
    Removes the ChocolateyGet package provider/source from this computer.

    .DESCRIPTION
    Removes the ChocolateyGet package provider/source from this computer forcefully.

    .EXAMPLE
    Remove-ChocolateyGetProvider
#>

function Remove-ChocolateyGetProvider {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param (
        [Switch]
        $PassThru
    )

}