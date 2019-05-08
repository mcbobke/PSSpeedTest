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
    Param(
        [string]
        $test
    )

    try {
        Write-Verbose -Message "Getting content of config.json and returning as a PSCustomObject."
        $config = Get-Content -Path "$($PSScriptRoot | Split-Path -Parent)\config.json" -ErrorAction "Stop" | ConvertFrom-Json

        if ($PassThru){
            return $config
        }
        else {
            Write-Host "Internet Server: $($config.defaultInternetServer.defaultServer)"
            Write-Host "Internet Port: $($config.defaultInternetServer.defaultPort)"
            Write-Host "Local Server: $($config.defaultLocalServer.defaultServer)"
            Write-Host "Local Port: $($config.defaultLocalServer.defaultPort)"
        }
    }
    catch {
        throw "Can't find the JSON configuration file. Use 'Set-SpeedTestConfig' to create one."
    }
}