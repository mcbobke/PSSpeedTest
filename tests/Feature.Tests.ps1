$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$Script:ConfigPath = Join-Path -Path $Script:ModuleRoot -ChildPath "config.json"

function Reset-Configuration {
    $config = Get-Content -Path $Script:ConfigPath | ConvertFrom-Json
    $config.defaultInternetServer.defaultServer = ""
    $config.defaultInternetServer.defaultPort = ""
    $config.defaultLocalServer.defaultServer = ""
    $config.defaultLocalServer.defaultPort = ""
    $config | ConvertTo-Json | Set-Content -Path $Script:ConfigPath
}

Describe "Feature tests for module $Script:ModuleName" {
    Context "Invoke-SpeedTest (Internet)" {
        BeforeAll {
            Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
            Import-Module $Global:TestThisModule
        }
        
        AfterEach {
            Reset-Configuration
        }

        It "Should successfully run a speed test against a valid public iPerf3 server with a saved configuration" {
            Set-SpeedTestConfig -InternetServer "iperf.he.net" -InternetPort "5201"
            {Invoke-SpeedTest -Internet} | Should -Not -Throw
        }

        It "Should successfully run a speed test against a valid public iPerf3 server with a saved configuration using default port '5201'" {
            Set-SpeedTestConfig -InternetServer "iperf.he.net"
            {Invoke-SpeedTest -Internet} | Should -Not -Throw
        }

        It "Should successfully run a speed test against a valid public iPerf3 server using specified Server/Port parameters" {
            {Invoke-SpeedTest -Server "iperf.he.net" -Port "5201"} | Should -Not -Throw
        }
        
        It "Should successfully run a speed test against a valid public iPerf3 server using specified Server parameter and default port '5201'" {
            {Invoke-SpeedTest -Server "iperf.he.net"} | Should -Not -Throw
        }

        It "Should throw an error when running a speed test against an invalid public iPerf3 server with a saved configuration" {
            Set-SpeedTestConfig -InternetServer "test.local.com"
            {Invoke-SpeedTest -Internet} | Should -Throw
        }

        It "Should throw an error when running a speed test against a valid public iPerf3 server with a saved configuration using an invalid port" {
            Set-SpeedTestConfig -InternetServer "test.local.com" -InternetPort "7777"
            {Invoke-SpeedTest -Internet} | Should -Throw
        }

        It "Should throw an error when running a speed test against an invalid public iPerf3 server/port using specified Server/Port parameters" {
            {Invoke-SpeedTest -Server "test.local.com" -Port "7777"} | Should -Throw
        }

        It "Should throw an error when running a speed test against an invalid public iPerf3 server using specified Server parameter" {
            {Invoke-SpeedTest -Server "test.local.com"} | Should -Throw
        }
    }

    Context "Install-SpeedTestServer (Local Computer)" {
        BeforeAll {
            Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
            Import-Module $Global:TestThisModule
        }

        It "Should install iPerf3 scheduled task listener on local computer" {
            {Install-SpeedTestServer} | Should -Not -Throw
        }
    }
}