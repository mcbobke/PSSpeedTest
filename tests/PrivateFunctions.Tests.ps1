$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$Script:PrivateFunctionPath = "$Script:ModuleRoot\private"
$Script:origConfirmPref = $ConfirmPreference

foreach ($script in (Get-ChildItem -Path $Script:PrivateFunctionPath)) {
    . $script.FullName
}

Describe "Private function tests for $Script:ModuleName" {
    BeforeAll {
        $ConfirmPreference = 'None'
    }

    AfterAll {
        $ConfirmPreference = $Script:origConfirmPref
    }

    Context "Install-ChocolateyGetProvider" {
        It "Should install ChocolateyGet PackageProvider" {
            {Install-ChocolateyGetProvider} | Should -Not -Throw
        }
    }

    Context "Install-iPerf3" {
        It "Should install iPerf3 Package from ChocolateyGet" {
            {Install-iPerf3} | Should -Not -Throw
        }
    }

    Context "Set-iPerf3Port" {
        It "Should set firewall rules for iPerf3 using designated port" {
            {Set-iPerf3Port -Port '5201'} | Should -Not -Throw
        }
    }

    Context "Set-iPerf3Task" {
        It "Should register iPerf3 server Scheduled Task" {
            {Set-iPerf3Task -Port '5201'} | Should -Not -Throw
        }
    }
}