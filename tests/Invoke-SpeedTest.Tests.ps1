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

Describe "Invoke-SpeedTest (Public)" {
    Context "Invoke-SpeedTest (Unmocked)" {
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

    Context "Invoke-SpeedTest (Mocked for testing parameters)" {
        Mock -Verifiable Invoke-SpeedTest {return 0}

        It "Should not throw an error if only the Internet parameter is used" {
            {Invoke-SpeedTest -Internet} | Should -Not -Throw
        }

        It "Should not throw an error if only the Local parameter is used" {
            {Invoke-SpeedTest -Local} | Should -Not -Throw
        }

        It "Should not throw an error if only the Server parameter is used" {
            {Invoke-SpeedTest -Server "local.domain.com"} | Should -Not -Throw
        }

        It "Should throw an error if the Internet and Server parameters are both used" {
            {Invoke-SpeedTest -Internet -Server "local.domain.com"} | Should -Throw
        }

        It "Should throw an error if the Local and Server parameters are both used" {
            {Invoke-SpeedTest -Local -Server "local.domain.com"} | Should -Throw
        }

        It "Should throw an error if the Internet and Port parameters are both used" {
            {Invoke-SpeedTest -Internet -Port "5201"} | Should -Throw
        }

        It "Should throw an error if the Local and Port parameters are both used" {
            {Invoke-SpeedTest -Local -Port "5201"} | Should -Throw
        }

        It "Should throw an error if the Internet, Local and Server parameters are used" {
            {Invoke-SpeedTest -Internet -Local -Server "local.domain.com"} | Should -Throw
        }

        It "Should throw an error if the Internet, Local and Port parameters are used" {
            {Invoke-SpeedTest -Internet -Local -Port "5201"} | Should -Throw
        }

        It "Should throw an error if the Internet, Local, Server and Port parameters are used" {
            {Invoke-SpeedTest -Internet -Local -Server "local.domain.com" -Port "5201"} | Should -Throw
        }

        It "Should throw an error if both Internet and Local parameters are used" {
            {Invoke-SpeedTest -Internet -Local} | Should -Throw
        }

        It "Should throw an error if Server and Port parameters are used but empty" {
            {Invoke-SpeedTest -Server "" -Port ""} | Should -Throw
        }

        It "Should throw an error if Server parameter is used but empty" {
            {Invoke-SpeedTest -Server "" -Port "5201"} | Should -Throw
        }

        It "Should throw an error if Port parameter is used but empty" {
            {Invoke-SpeedTest -Server "local.domain.com" -Port ""} | Should -Throw
        }

        It "Should throw an error if Server and Port parameters are used but null" {
            {Invoke-SpeedTest -Server $null -Port $null} | Should -Throw
        }

        It "Should throw an error if Server parameter is used but null" {
            {Invoke-SpeedTest -Server $null -Port "5201"} | Should -Throw
        }

        It "Should throw an error if Port parameter is used but null" {
            {Invoke-SpeedTest -Server "local.domain.com" -Port $null} | Should -Throw
        }

        It "Should throw an error if Port parameter is used but Server is not" {
            {Invoke-SpeedTest -Port "5201"} | Should -Throw
        }

        Assert-VerifiableMock
    }
}