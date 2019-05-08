<#
    .SYNOPSIS
    Get the default server configurations for Internet and Local speed test servers.

    .DESCRIPTION
    Get the default server configurations for Internet and Local speed test servers.
    If '-PassThru' is used, converts the JSON configuration file into a PSCustomObject.

    .EXAMPLE
    Get-SpeedTestConfig

    .EXAMPLE
    Get-SpeedTestConfig -PassThru
#>

function Get-SpeedTestConfig {
    [CmdletBinding()]
    Param()

    try {
        Write-Verbose -Message "Getting content of config.json and returning as a PSCustomObject."
        $config = Get-Content -Path "$($PSScriptRoot | Split-Path -Parent)\config.json" -ErrorAction "Stop" | ConvertFrom-Json

        $config = [PSCustomObject] @{
            DefaultInternetServer = $config.defaultInternetServer.defaultServer;
            DefaultInternetPort = $config.defaultInternetServer.defaultPort;
            DefaultLocalServer = $config.defaultLocalServer.defaultServer;
            DefaultLocalPort = $config.defaultLocalServer.defaultPort;
        }

        return $config
    }
    catch {
        throw "Can't find the JSON configuration file. Use 'Set-SpeedTestConfig' to create one."
    }
}