InModuleScope PSSpeedTest {
    Describe "Install-ChocolateyGetProvider (Private)" {
        Context "Install-ChocolateyGetProvider" {
            It "Should install ChocolateyGet PackageProvider" {
                Install-ChocolateyGetProvider

                $result = Get-PackageProvider -ListAvailable -Name "ChocolateyGet" |
                    Select-Object -ExpandProperty "Name"
                $result | Should -Be "ChocolateyGet"
            }
        }
    }
}