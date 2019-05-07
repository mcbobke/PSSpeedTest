$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$Script:ConfigPath = Join-Path -Path $Script:ModuleRoot -ChildPath "config.json"

Describe "Get-SpeedTestConfig (Public)" {
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
}