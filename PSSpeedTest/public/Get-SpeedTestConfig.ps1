<#
    .SYNOPSIS
    Get the default server configurations for Internet and Local speed test servers.

    .DESCRIPTION
    Get the default server configurations for Internet and Local speed test servers.
    Converts the JSON configuration file into a PSCustomObject.

    .EXAMPLE
    Get-SpeedTestConfig
#>

function Get-SpeedTestConfig {
    [CmdletBinding()]
    Param()

    try {
        $config = Get-Content "$($PSScriptRoot | Split-Path -Parent)\config.json"
        return $config | ConvertFrom-Json
    }
    catch {
        throw "Can't find the JSON configuration file. Use 'Set-SpeedTestConfig' to create one."
    }
}