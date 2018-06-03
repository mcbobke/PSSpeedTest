<#
    .SYNOPSIS
    Configures the iPerf3 server scheduled task that will listen on the given port.

    .DESCRIPTION
    Configures the iPerf3 server scheduled task that will listen on the given port.
    Sets the scheduled task to run on startup.

    .PARAMETER Port
    The port that iPerf3 will listen on.

    .PARAMETER PassThru
    Returns the object returned by "Get-ScheduledTask -TaskName 'iPerf3 Server' -ErrorAction 'SilentlyContinue'".

    .EXAMPLE
    Set-iPerf3Task -Port "5201"
#>

function Set-iPerf3Task {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Port,
        [Switch]
        $PassThru
    )

    $actionParams = @{
        Execute = (Get-Command -Name 'iperf3.exe' | Select-Object -ExpandProperty 'Source');
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
    Register-ScheduledTask -InputObject $task -TaskName 'iPerf3 Server' -ErrorAction 'SilentlyContinue' | Out-Null
    $toReturn = Get-ScheduledTask -TaskName 'iPerf3 Server' -ErrorAction 'SilentlyContinue'

    if ($toReturn) {
        Start-ScheduledTask -TaskName 'iPerf3 Server'
        Write-Verbose -Message 'Scheduled task for iPerf3 server started.'
    }
    else {
        throw 'Scheduled task for iPerf3 server was not registered.'
    }

    if ($PassThru) {
        return $toReturn
    }
}