InModuleScope PSSpeedTest {
    Describe "Set-iPerf3Port (Private)" {
        Context "Set-iPerf3Port" {
            It "Should set firewall rules for iPerf3 using designated port" {
                Set-iPerf3Port -Port '5201'

                $result = Get-NetFirewallRule -DisplayName 'iPerf3 Server Inbound TCP Rule' |
                    Select-Object -ExpandProperty 'Enabled'
                $result | Should -BeTrue

                $result = Get-NetFirewallRule -DisplayName 'iPerf3 Server Outbound TCP Rule' |
                    Select-Object -ExpandProperty 'Enabled'
                $result | Should -BeTrue
            }
        }
    }
}