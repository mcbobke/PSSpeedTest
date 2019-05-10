InModuleScope PSSpeedTest {
    Describe "Remove-iPerf3Task (Private)" {
        Context "Remove-iPerf3Task" {
            It "Should unregister iPerf3 server Scheduled Task" {
                $oldConfirmPreference = $ConfirmPreference
                $ConfirmPreference = 'None'

                Install-iPerf3 # Ensuring iperf3 is installed to prevent scheduled task registration failure
                Set-iPerf3Task -Port "5201"
                Remove-iPerf3Task

                $result = Get-ScheduledTask -TaskName "iPerf3 Server" `
                    -ErrorAction "SilentlyContinue"
                $result | Should -BeNullOrEmpty

                $ConfirmPreference = $oldConfirmPreference
            }
        }
    }
}