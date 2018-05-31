<#
    .SYNOPSIS
    Set the default server configurations for Internet and Local speed test servers.

    .DESCRIPTION
    Set the default server configurations for Internet and Local speed test servers.
    Convert parameter values to appropriate PSCustomObject and write to the JSON configuration file.

    .EXAMPLE
    Write an example.
#>

function Set-SpeedTestConfig {
    [CmdletBinding()]
    Param(
        [ValidateNotNullOrEmpty()]
        [String]
        $InternetServer,
        [ValidateNotNullOrEmpty()]
        [String]
        $InternetPort,
        [ValidateNotNullOrEmpty()]
        [String]
        $LocalServer,
        [ValidateNotNullOrEmpty()]
        [String]
        $LocalPort
    )

    try {
        $config = Get-SpeedTestConfig
    }
    catch {
        Write-Host "No configuration found - starting with empty configuration."
        $jsonString = @"
    {   "defaultPort"       : "5201",
        "defaultLocalServer": {
            "defaultServer" : "",
            "defaultPort"   : ""
        },
        "defaultInternetServer" : {
            "defaultServer" : "",
            "defaultPort"   : ""
        }
    }
"@
        $config = $jsonString | ConvertFrom-Json
    }

    # Detailed parameter validation against current configuration
    if ($InternetPort `
        -and (!($InternetServer)) `
        -and (!($config.defaultInternetServer.defaultServer))) {
        throw "Cannot set an Internet port with an empty InternetServer setting."
        }
    if ($LocalPort `
        -and (!($LocalServer)) `
        -and (!($config.defaultLocalServer.defaultServer))) {
        throw "Cannot set a Local port with an empty LocalServer setting."
    }

    if ($InternetServer) {$config.defaultInternetServer.defaultServer = $InternetServer}
    if ($InternetPort) {$config.defaultInternetServer.defaultPort = $InternetPort}
    if ($LocalServer) {$config.defaultLocalServer.defaultServer = $LocalServer}
    if ($LocalPort) {$config.defaultLocalServer.defaultServer = $LocalPort}

    $config `
        | ConvertTo-Json `
        | Set-Content -Path "$((Get-Location).Path | Split-Path -Parent)\config.json"
}