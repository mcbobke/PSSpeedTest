<#
    .SYNOPSIS
    Tests if the current user is running as an administrator on this machine.

    .DESCRIPTION
    Tests if the current user is running as an administrator on this machine.

    .EXAMPLE
    Test-Administrator
#>

function Test-Administrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin = $principal.IsInRole($admin)
    return $IsAdmin
}