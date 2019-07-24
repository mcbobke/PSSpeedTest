[CmdletBinding()]
Param (
    $Task = 'Default',
    $VersionIncrement = 'Patch'
)

function Initialize-ModuleBuildRequirements {
    . (Resolve-Path -Path "$PSScriptRoot\Bootstrap-PackageManagement.ps1")
    Bootstrap-PackageManagement

    Write-Output "Install/Import Build-Dependent Modules"
    $PSDependVersion = '0.2.3'
    if (!(Get-InstalledModule -Name 'PSDepend' -RequiredVersion $PSDependVersion -ErrorAction 'SilentlyContinue')) {
        Install-Module -Name 'PSDepend' -RequiredVersion $PSDependVersion -Force -Scope 'CurrentUser'
    }
    Import-Module -Name 'PSDepend' -RequiredVersion $PSDependVersion
    Invoke-PSDepend -Path "$PSScriptRoot\build.Depend.psd1" -Install -Import -Force
}

switch ($Task) {
    'Build' {
        Write-Output "Starting build of PSSpeedTest"
        Initialize-ModuleBuildRequirements
        Invoke-Build -Task $Task -Result InvokeBuildResult -VersionIncrement $VersionIncrement
        break
    }
    'Test' {
        Write-Output "Running Pester tests for PSSpeedTest"
        Initialize-ModuleBuildRequirements
        Invoke-Build -Task $Task -Result InvokeBuildResult
        break
    }
    'Deploy' {
        Write-Output "Deploying PSSpeedTest"
        Initialize-ModuleBuildRequirements
        Invoke-Build -Task $Task -Result InvokeBuildResult
        break
    }
    'Default' {
        Write-Output "Building and testing PSSpeedTest"
        Initialize-ModuleBuildRequirements
        Invoke-Build -Task $Task -Result InvokeBuildResult -VersionIncrement $VersionIncrement
        break
    }
    Default {
        throw [System.ArgumentException]::new("Unknown task type: $Task")
    }
}

if ($InvokeBuildResult.Errors) {
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
