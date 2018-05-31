$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$Script:PrivateFunctionPath = "$Script:ModuleRoot\private"

foreach ($script in (Get-ChildItem -Path $Script:PrivateFunctionPath)) {
    . $script.FullName
}

Describe "Unit tests for $Script:ModuleName" {
    It "Should install ChocolateyGet PackageProvider" {
        $result = Install-ChocolateyGetProvider
        $result.Name | Should -Be 'ChocolateyGet'
    }

    It "Should install iPerf3 Package from ChocolateyGet" {
        $result = Install-iPerf3
        $result.Name | Should -Be 'iperf3'
        $result.Status | Should -Be 'Installed'
    }
}