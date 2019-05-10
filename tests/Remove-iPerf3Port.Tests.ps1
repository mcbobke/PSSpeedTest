InModuleScope PSSpeedTest {
    Describe "Remove-iPerf3Port (Private)" {
        Context "Remove-iPerf3Port" {
            It "Should remove the iPerf3 NetFirewallRule" {
                Set-iPerf3Port -Port "5201"
                Remove-iPerf3Port

                $result = Get-NetFirewallRule `
                    -DisplayName 'iPerf3 Server Inbound TCP Rule' `
                    -ErrorAction 'SilentlyContinue'
                $result | Should -BeNullOrEmpty

                $result = Get-NetFirewallRule `
                    -DisplayName 'iPerf3 Server Outbound TCP Rule' `
                    -ErrorAction 'SilentlyContinue'
                $result | Should -BeNullOrEmpty
            }
        }
    }
}