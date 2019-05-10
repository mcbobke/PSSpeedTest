Describe "Remove-SpeedTestServer (Public)" {
    Context "Remove-SpeedTestServer" {
        It "Should remove iPerf3 scheduled task listener on local computer" {
            $oldConfirmPreference = $ConfirmPreference
            $ConfirmPreference = 'None'

            Install-SpeedTestServer
            Remove-SpeedTestServer
            
            $result = Get-Package -Name 'iperf3' `
                        -ErrorAction 'SilentlyContinue' `
                        -ProviderName 'ChocolateyGet'
            $result | Should -BeNullOrEmpty

            $result = Get-NetFirewallRule -DisplayName 'iPerf3 Server Inbound TCP Rule' `
                        -ErrorAction 'SilentlyContinue'
            $result | Should -BeNullOrEmpty

            $result = Get-NetFirewallRule -DisplayName 'iPerf3 Server Outbound TCP Rule' `
                        -ErrorAction 'SilentlyContinue'
            $result | Should -BeNullOrEmpty
            
            $result = Get-ScheduledTask -TaskName 'iPerf3 Server' `
                        -ErrorAction 'SilentlyContinue'
            $result | Should -BeNullOrEmpty
            
            $result = Get-Process -Name 'iperf3' `
                        -ErrorAction 'SilentlyContinue'
            $result | Should -BeNullOrEmpty

            $ConfirmPreference = $oldConfirmPreference
        }
    }
}