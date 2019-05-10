InModuleScope PSSpeedTest {
    Describe "Remove-iPerf3 (Private)" {
        Context "Remove-iPerf3" {
            It "Should remove iPerf3 package" {
                Install-iPerf3
                Get-Process -Name 'iperf3' | Stop-Process -Force # Stopping process to prevent file lock
                Remove-iPerf3

                $result = Get-Package -Name 'iperf3' `
                            -ProviderName 'ChocolateyGet' `
                            -ErrorAction 'SilentlyContinue'
                $result | Should -BeNullOrEmpty
            }
        }
    }
}