$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$Script:ConfigPath = Join-Path -Path $Script:ModuleRoot -ChildPath "config.json"
$TestPassword = ConvertTo-SecureString -String "Test123" -AsPlainText -Force
$TestCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList ("Test123", $TestPassword)

function Reset-Configuration {
    $config = Get-Content -Path $Script:ConfigPath | ConvertFrom-Json
    $config.defaultInternetServer.defaultServer = ""
    $config.defaultInternetServer.defaultPort = ""
    $config.defaultLocalServer.defaultServer = ""
    $config.defaultLocalServer.defaultPort = ""
    $config | ConvertTo-Json | Set-Content -Path $Script:ConfigPath
}

Describe "Unit tests for $Script:ModuleName" {
    # Mocking as these functions will call over the network
    Mock Invoke-SpeedTest {return 0}
    Mock Install-SpeedTestServer {return 0}
    
    BeforeAll {
        Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
        Import-Module $Global:TestThisModule
    }
    AfterEach {
        Reset-Configuration
    }

    Context "config.json" {
        It "config.json should be valid JSON" {
            {Get-Content -Path $Script:ConfigPath | ConvertFrom-Json} | Should -Not -Throw
        }
    }

    Context "Get-SpeedTestConfig" {
        It "Should return a valid object with expected items" {
            $result = Get-SpeedTestConfig -PassThru
            $result.defaultLocalServer.defaultServer | Should -BeNullOrEmpty
            $result.defaultLocalServer.defaultPort | Should -BeNullOrEmpty
            $result.defaultInternetServer.defaultServer | Should -BeNullOrEmpty
            $result.defaultInternetServer.defaultPort | Should -BeNullOrEmpty
        }

        It "Should throw if the expected file does not exist" {
            try {
                Rename-Item -Path $Script:ConfigPath -NewName "configrename.json" -Force
                {Get-SpeedTestConfig} | Should -Throw
            }
            finally {
                Rename-Item -Path "$Script:ModuleRoot\configrename.json" `
                    -NewName "config.json" -Force
            }
        }
    }

    Context "Set-SpeedTestConfig" {
        It "Should not throw if InternetServer and InternetPort parameters are used" {
            {Set-SpeedTestConfig -InternetServer "test.public.com" -InternetPort "7777"} `
                | Should -Not -Throw
        }

        It "Should not throw if LocalServer and LocalPort parameters are used" {
            {Set-SpeedTestConfig -LocalServer "test.local.com" -LocalPort "7777"} `
                | Should -Not -Throw
        }

        It "Should not throw if all parameters are used" {
            {Set-SpeedTestConfig -InternetServer "test.public.com" -InternetPort "7777" `
                    -LocalServer "test.local.com" -LocalPort "7777"} `
                | Should -Not -Throw
        }

        It "Should not throw if InternetServer and LocalServer parameters are used" {
            {Set-SpeedTestConfig -InternetServer "test.public.com" -LocalServer "test.local.com"} `
                | Should -Not -Throw
        }

        It "Should not throw if InternetServer parameter is used on its own" {
            {Set-SpeedTestConfig -InternetServer "test.public.com"} `
                | Should -Not -Throw
        }
        
        It "Should not throw if LocalServer parameter is used on its own" {
            {Set-SpeedTestConfig -LocalServer "test.local.com"} `
                | Should -Not -Throw
        }

        It "Should not throw if InternetPort parameter is used with a saved InternetServer" {
            Set-SpeedTestConfig -InternetServer "test.public.com"
            {Set-SpeedTestConfig -InternetPort "7777"} | Should -Not -Throw
        }

        It "Should not throw if LocalPort parameter is used with a saved LocalServer" {
            Set-SpeedTestConfig -LocalServer "test.local.com"
            {Set-SpeedTestConfig -LocalPort "7777"} | Should -Not -Throw
        }

        It "Should not throw if InternetPort and LocalPort parameters are used with both saved servers" {
            Set-SpeedTestConfig -InternetServer "test.public.com"
            Set-SpeedTestConfig -LocalServer "test.local.com"
            {Set-SpeedTestConfig -InternetPort "7777" -LocalPort "7777"} | Should -Not -Throw
        }

        It "Should throw if InternetPort parameter is used without a saved InternetServer" {
            {Set-SpeedTestConfig -InternetPort "7777"} | Should -Throw
        }

        It "Should throw if LocalPort parameter is used without a saved LocalServer" {
            {Set-SpeedTestConfig -LocalPort "7777"} | Should -Throw
        }
    }

    Context "Invoke-SpeedTest" {
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
    }

    Context "Install-SpeedTestServer" {
        It "Should not throw an error if only ComputerName parameter is used" {
            {Install-SpeedTestServer -ComputerName "local.domain.com"} | Should -Not -Throw
        }

        It "Should not throw an error if only Port parameter is used" {
            {Install-SpeedTestServer -Port "5201"} | Should -Not -Throw
        }

        It "Should not throw an error if only Credential parameter is used" {
            {Install-SpeedTestServer -Credential $TestCredential} | Should -Not -Throw
        }

        It "Should not throw an error if ComputerName and Port parameters are used and Credential is not" {
            {Install-SpeedTestServer -ComputerName "local.domain.com" -Port "7777"} | Should -Not -Throw
        }

        It "Should not throw an error if ComputerName and Credential parameters are used and Port is not" {
            {Install-SpeedTestServer -ComputerName "local.domain.com" -Credential $TestCredential} | Should -Not -Throw
        }

        It "Should not throw an error if Port and Credential parameters are used and ComputerName is not" {
            {Install-SpeedTestServer -Port "7777" -Credential $TestCredential} | Should -Not -Throw
        }

        It "Should not throw an error if ComputerName, Port, and Credential parameters are specified" {
            {Install-SpeedTestServer -ComputerName "local.domain.com" -Port "7777" -Credential $TestCredential} `
                | Should -Not -Throw
        }

        It "Should throw an error if ComputerName parameter is used but empty" {
            {Install-SpeedTestServer -ComputerName "" -Port "5201" -Credential $TestCredential} | Should -Throw
        }

        It "Should throw an error if Port parameter is used but empty" {
            {Install-SpeedTestServer -ComputerName "local.domain.com" -Port "" -Credential $TestCredential} | Should -Throw
        }

        It "Should throw an error if Credential parameter is used but empty" {
            {Install-SpeedTestServer -ComputerName "local.domain.com" -Port "5201" -Credential ""} | Should -Throw
        }

        It "Should throw an error if ComputerName parameter is used but null" {
            {Install-SpeedTestServer -ComputerName $null -Port "5201" -Credential $TestCredential} | Should -Throw
        }

        It "Should throw an error if Port parameter is used but null" {
            {Install-SpeedTestServer -ComputerName "local.domain.com" -Port $null -Credential $TestCredential} | Should -Throw
        }

        It "Should throw an error if Credential parameter is used but null" {
            {Install-SpeedTestServer -ComputerName "local.domain.com" -Port "5201" -Credential $null} | Should -Throw
        }
    }
}