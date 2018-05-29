[CmdletBinding()]
Param (
    $Task = 'Default',
    $VersionIncrement = 'Patch'
)

Write-Output "Starting build of PSSpeedTest"
Invoke-Build -Task $Task -Result BuildResult -VersionIncrement $VersionIncrement

if ($BuildResult.Errors) {
    foreach($t in $Result.Tasks) {
        if ($t.Error) {
            "Task '$($t.Name)' at $($t.InvocationInfo.ScriptName):$($t.InvocationInfo.ScriptLineNumber)"
            $t.Error
        }
    }

    exit 1
}
else {
    exit 0
}
