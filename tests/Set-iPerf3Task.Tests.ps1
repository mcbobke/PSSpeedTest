InModuleScope PSSpeedTest {
    Describe "Set-iPerf3Task (Private)" {
        Context "Set-iPerf3Task" {
            It "Should register iPerf3 server Scheduled Task" {
                Install-iPerf3 # Ensuring iperf3 is installed to prevent scheduled task registration failure
                Set-iPerf3Task -Port "5201"

                $result = Get-ScheduledTask -TaskName "iPerf3 Server" |
                    Select-Object -ExpandProperty "TaskName"
                $result | Should -Be "iPerf3 Server"
            }
        }
    }
}