# PSSpeedTest

A module for testing network bandwidth over the internet as well as private networks.

Author: Matthew Bobke

[![Build status](https://ci.appveyor.com/api/projects/status/r58ua2us4q66h569/branch/master?svg=true)](https://ci.appveyor.com/project/MatthewBobke/psspeedtest/branch/master)

## Description

Whenever I've needed to run a network bandwidth test, I've defaulted to services such as [Speedtest by Ookla](http://www.speedtest.net/) and [fast.com](https://fast.com/en/). While effective, I spend a lot of time in the shell and I don't want to have to open an internet browser just to see if my network speeds are slow. [iPerf3](https://iperf.fr/) is a simple command-line utility for testing network bandwidth and has been combined with PowerShell to form `PSSpeedTest`. Behind the scenes, the executable is retrieved using the [ChocolateyGet](https://github.com/jianyunt/ChocolateyGet) `PackageProvider`.

## Installation

`Install-Module -Name PSSpeedTest -Repository PSGallery`

**NOTE:** Installing this module will not automatically install `ChocolateyGet` or `iPerf3`. Running `Invoke-SpeedTest` or `Install-SpeedTestServer` will prompt for the installation of these two items **if** they are not installed **or** the `-Force` argument is not given.

## Usage (Public Functions)

`Get-Help FunctionName -Full` for detailed help.

### Get-SpeedTestConfig

Returns a list of your configured default speed test servers/ports for `Invoke-SpeedTest`.

### Set-SpeedTestConfig

Used to set the default speed test servers/ports for `Invoke-SpeedTest` when using the `-Internet` or `-Local` switch arguments.

### Invoke-SpeedTest

Runs a speed test against a server that is running iPerf3. The `-Internet` or `-Local` switches will use stored defaults, or a server can be specified with `-Server` and `-Port`.
`-Port` can be left out to use the default iPerf3 port 5201.

### Install-SpeedTestServer

Sets up iPerf3 as a server process on this machine or another Windows domain-joined computer (if `-ComputerName` is specified). This performs the following:

* Installs the `ChocolateyGet` PackageProvider if not already present.
* Installs the `iPerf3` package if not already present.
* Sets the inbound/outbound firewall rules for the given port (5201 if the `-Port` parameter is not used.)
* Creates a Scheduled Task to run `iperf3.exe` with the necessary parameters for server usage on computer startup.

## Building

`.\build.ps1`

## Testing

`.\build.ps1 -Task Test`

## Contributing

Contributions are welcome and encouraged. Please submit issues and pull requests!