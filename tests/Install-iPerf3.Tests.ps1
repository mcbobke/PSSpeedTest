InModuleScope PSSpeedTest {
    Describe "Install-iPerf3 (Private)" {
        Context "Install-iPerf3" {
            It "Should install iPerf3 Package from ChocolateyGet" {
                Install-iPerf3

                $result = Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' |
                    Select-Object -ExpandProperty 'Name'
                $result | Should -Be 'iperf3'
            }
        }
    }
}