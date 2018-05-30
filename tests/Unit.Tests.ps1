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
        It "Should throw an error if ComputerName parameter is not used" {
            {Install-SpeedTestServer -Port "5201" -Credential $TestCredential} | Should -Throw
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