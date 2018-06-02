$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$Script:PrivateFunctionPath = "$Script:ModuleRoot\private"

foreach ($script in (Get-ChildItem -Path $Script:PrivateFunctionPath)) {
    . $script.FullName
}

Describe "Private function tests for $Script:ModuleName" {

    Context "Install-ChocolateyGetProvider" {
        It "Should install ChocolateyGet PackageProvider" {
            $result = Install-ChocolateyGetProvider
            $result | Should -Be 'Installed'
        }
    }

    Context "Install-iPerf3" {
        It "Should install iPerf3 Package from ChocolateyGet" {
            $result = Install-iPerf3
            $result | Should -Be 'Installed'
        }
    }

    Context "Set-iPerf3Port" {
        It "Should set firewall rules for iPerf3 using designated port" {
            $result = Set-iPerf3Port -Port '5201'
            $result | Should -Be 'Set port'
        }
    }

    Context "Set-iPerf3Task" {
        It "Should register iPerf3 server Scheduled Task" {
            $result = Set-iPerf3Task
            $result | Should -Be 'Registered/started scheduled task'
        }
    }
}