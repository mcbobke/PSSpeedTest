# PSSpeedTest
A module for testing network bandwidth over the internet as well as private networks.

Author: Matthew Bobke

[![Build status](https://ci.appveyor.com/api/projects/status/r58ua2us4q66h569/branch/master?svg=true)](https://ci.appveyor.com/project/MatthewBobke/psspeedtest/branch/master)

## Description

Whenever I've needed to run a network bandwidth test, I've defaulted to services such as [Speedtest by Ookla](http://www.speedtest.net/) and [fast.com](https://fast.com/en/). While effective, I spend a lot of time in the shell and I don't want to have to open an internet browser just to see if my network speeds are slow. [iPerf3](https://iperf.fr/) is a simple command-line utility for testing network bandwidth and has been combined with PowerShell to form `PSSpeedTest`. Behind the scenes, the executable is retrieved using the [ChocolateyGet](https://github.com/jianyunt/ChocolateyGet) `PackageProvider`.

## Building

`.\build.ps1`

## Testing

`.\build.ps1 -Task Test`