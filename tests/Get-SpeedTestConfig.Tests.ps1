$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$Script:ConfigPath = Join-Path -Path $Script:ModuleRoot -ChildPath "config.json"

Describe "Get-SpeedTestConfig (Public)" {
    Context "Get-SpeedTestConfig" {
        It "Should return a valid object with expected items" {
            Set-SpeedTestConfig -InternetServer 'test.internet.com' -InternetPort '1111' -LocalServer 'test.local.com' -LocalPort '1111'
            $result = Get-SpeedTestConfig
            $result.DefaultLocalServer | Should -Be 'test.local.com'
            $result.DefaultLocalPort | Should -Be '1111'
            $result.DefaultInternetServer | Should -Be 'test.internet.com'
            $result.DefaultInternetPort | Should -Be '1111'
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
}