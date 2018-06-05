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
        Write-Verbose -Message "Getting content of config.json and returning as a PSCustomObject."
        $config = Get-Content -Path "$($PSScriptRoot | Split-Path -Parent)\config.json" -ErrorAction "Stop"
        return $config | ConvertFrom-Json
    }
    catch {
        throw "Can't find the JSON configuration file. Use 'Set-SpeedTestConfig' to create one."
    }
}