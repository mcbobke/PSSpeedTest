<#
    .SYNOPSIS
    Removes the iPerf3 Chocolatey package from this computer.

    .DESCRIPTION
    Removes the iPerf3 package from this computer as installed from the ChocolateyGet package source.

    .EXAMPLE
    Remove-iPerf3
#>

function Remove-iPerf3 {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param (

    )

}