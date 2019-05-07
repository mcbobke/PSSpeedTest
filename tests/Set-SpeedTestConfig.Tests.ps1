$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ConfigPath = Join-Path -Path $Script:ModuleRoot -ChildPath "config.json"

function Reset-Configuration {
    $config = Get-Content -Path $Script:ConfigPath | ConvertFrom-Json
    $config.defaultInternetServer.defaultServer = ""
    $config.defaultInternetServer.defaultPort = ""
    $config.defaultLocalServer.defaultServer = ""
    $config.defaultLocalServer.defaultPort = ""
    $config | ConvertTo-Json | Set-Content -Path $Script:ConfigPath
}

Describe "Set-SpeedTestConfig (Public)" {
    AfterEach {
        Reset-Configuration
    }

    Context "Set-SpeedTestConfig" {
        It "Should save valid config if InternetServer and InternetPort parameters are used" {
            Set-SpeedTestConfig -InternetServer "test.public.com" -InternetPort "7777"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultInternetServer.defaultServer | Should -Be "test.public.com"
            $config.defaultInternetServer.defaultPort | Should -Be "7777"
        }

        It "Should save valid config if LocalServer and LocalPort parameters are used" {
            Set-SpeedTestConfig -LocalServer "test.local.com" -LocalPort "7777"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultLocalServer.defaultServer | Should -Be "test.local.com"
            $config.defaultLocalServer.defaultPort | Should -Be "7777"
        }

        It "Should save valid config if all parameters are used" {
            Set-SpeedTestConfig -InternetServer "test.public.com" -InternetPort "7777" `
                    -LocalServer "test.local.com" -LocalPort "7777"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultInternetServer.defaultServer | Should -Be "test.public.com"
            $config.defaultInternetServer.defaultPort | Should -Be "7777"
            $config.defaultLocalServer.defaultServer | Should -Be "test.local.com"
            $config.defaultLocalServer.defaultPort | Should -Be "7777"
        }

        It "Should save valid config if InternetServer and LocalServer parameters are used" {
            Set-SpeedTestConfig -InternetServer "test.public.com" -LocalServer "test.local.com"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultInternetServer.defaultServer | Should -Be "test.public.com"
            $config.defaultLocalServer.defaultServer | Should -Be "test.local.com"
        }

        It "Should save valid config if InternetServer parameter is used on its own" {
            Set-SpeedTestConfig -InternetServer "test.public.com"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultInternetServer.defaultServer | Should -Be "test.public.com"
        }
        
        It "Should save valid config if LocalServer parameter is used on its own" {
            Set-SpeedTestConfig -LocalServer "test.local.com"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultLocalServer.defaultServer = "test.local.com"
        }

        It "Should save valid config if InternetPort parameter is used with a saved InternetServer" {
            Set-SpeedTestConfig -InternetServer "test.public.com"
            Set-SpeedTestConfig -InternetPort "7777"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultInternetServer.defaultPort | Should -Be "7777"
        }

        It "Should save valid config if LocalPort parameter is used with a saved LocalServer" {
            Set-SpeedTestConfig -LocalServer "test.local.com"
            Set-SpeedTestConfig -LocalPort "7777"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultLocalServer.defaultPort | Should -Be "7777"
        }

        It "Should save valid config if InternetPort and LocalPort parameters are used with both saved servers" {
            Set-SpeedTestConfig -InternetServer "test.public.com"
            Set-SpeedTestConfig -LocalServer "test.local.com"
            Set-SpeedTestConfig -InternetPort "7777" -LocalPort "7777"
            $config = Get-SpeedTestConfig -PassThru
            $config.defaultInternetServer.defaultPort | Should -Be "7777"
            $config.defaultLocalServer.defaultPort | Should -Be "7777"
        }

        It "Should throw if InternetPort parameter is used without a saved InternetServer" {
            {Set-SpeedTestConfig -InternetPort "7777"} | Should -Throw
        }

        It "Should throw if LocalPort parameter is used without a saved LocalServer" {
            {Set-SpeedTestConfig -LocalPort "7777"} | Should -Throw
        }
    }
}