Describe "Install-SpeedTestServer (Public)" {
    Context "Install-SpeedTestServer" {
        It "Should install iPerf3 scheduled task listener on local computer" {
            Install-SpeedTestServer

            $result = Get-PackageProvider -ListAvailable -Name 'ChocolateyGet' |
                Select-Object -ExpandProperty 'Name'
            $result | Should -Be 'ChocolateyGet'
            
            $result = Get-Package -Name 'iperf3' -ProviderName 'ChocolateyGet' |
                Select-Object -ExpandProperty 'Name'
            $result | Should -Be 'iperf3'

            $result = Get-NetFirewallRule -DisplayName 'iPerf3 Server Inbound TCP Rule' |
                Select-Object -ExpandProperty 'Enabled'
            $result | Should -Be 'True'

            $result = Get-NetFirewallRule -DisplayName 'iPerf3 Server Outbound TCP Rule' |
                Select-Object -ExpandProperty 'Enabled'
            $result | Should -Be 'True'
            
            $result = Get-ScheduledTask -TaskName 'iPerf3 Server' | 
                Select-Object -ExpandProperty 'TaskName'
            $result | Should -Be 'iPerf3 Server'
            
            $result = Get-Process -Name 'iperf3' | 
                Select-Object -ExpandProperty 'ProcessName'
            $result | Should -Be 'iperf3'
        }
    }
}
<#
TODO:
- Write tests that use Install-SpeedTestServer's parameters and remove between each test
#>