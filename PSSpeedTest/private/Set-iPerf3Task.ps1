<#
    .SYNOPSIS
    Configures the iPerf3 server scheduled task that will listen on the given port.

    .DESCRIPTION
    Configures the iPerf3 server scheduled task that will listen on the given port.
    Sets the scheduled task to run on startup.

    .PARAMETER Port
    The port that iPerf3 will listen on.

    .EXAMPLE
    Set-iPerf3Task -Port "5201"
#>

function Set-iPerf3Task {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port
    )

    $actionParams = @{
        Execute = "$(Get-Command -Name 'iperf3.exe' | Select-Object -ExpandProperty 'Source')";
        Argument = "-s -D -p $Port";
    }

    $taskAction = New-ScheduledTaskAction @actionParams
    $taskTrigger = New-ScheduledTaskTrigger -AtStartup
    $taskPrincipal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
    $taskSettings = New-ScheduledTaskSettingsSet
    
    $taskParams = @{
        Action = $taskAction;
        Description = 'iPerf3 Speed Test Server';
        Principal = $taskPrincipal;
        Settings = $taskSettings;
        Trigger = $taskTrigger;
        ErrorAction = 'SilentlyContinue';
    }

    $task = New-ScheduledTask @taskParams
    $result = Register-ScheduledTask -InputObject $task -TaskName "iPerf3 Server" -ErrorAction 'SilentlyContinue'

    if (!($result)) {
        throw 'Scheduled task was not registered'
    }
    else {
        Start-ScheduledTask -TaskName $result.TaskName
        return 'Registered/started scheduled task'
    }
}