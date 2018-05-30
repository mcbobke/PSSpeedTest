$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\$Env:BHProjectName"
$Script:ModuleName = Split-Path $moduleRoot -Leaf

Describe "Unit tests for $Script:ModuleName" {
    BeforeAll {
        Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
        Import-Module $Global:TestThisModule
    }

    It "Should install ChocolateyGet PackageProvider" {
        $result = Install-ChocolateyGetProvider
        $result.Name | Should -Be 'ChocolateyGet'
    }

    It "Should install iPerf3 Package from ChocolateyGet" {
        $result = Install-iPerf3
        $result.Name | Should -Be 'iperf3'
        $result.Status | Should -Be 'Installed'
    }

    AfterAll {
        Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
    }
}