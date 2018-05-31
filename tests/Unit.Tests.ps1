$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\$Env:BHProjectName"
$Script:ModuleName = Split-Path $moduleRoot -Leaf
$TestPassword = ConvertTo-SecureString -String "Test123" -AsPlainText -Force
$TestCredential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList ("Test123",$TestPassword)

Describe "Unit tests for $Script:ModuleName" {
    BeforeAll {
        Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
        Import-Module $Global:TestThisModule
    }

    Context "config.json" {
        It "config.json should be valid JSON" {
            {Get-Content -Path "$Script:ModuleRoot\config.json" | ConvertFrom-Json} | Should -Not -Throw
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
            {Install-SpeedTestServer -ComputerName "local.domain.com" -Port "7777" -Credential $TestCredential} | Should -Not -Throw
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

    AfterAll {
        Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
    }
}