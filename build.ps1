[CmdletBinding()]
Param (
    $Task = 'Default',
    $VersionIncrement = 'Patch'
)

Write-Output "Starting build of PSSpeedTest"

if (!(Get-PackageProvider -Name 'NuGet')) {
    Write-Output "Installing Nuget package provider..."
    Install-PackageProvider -Name 'NuGet' -Force -Confirm:$false | Out-Null
}

Write-Output "Install/Import Build-Dependent Modules"
$PSDependVersion = '0.2.3'
if (!(Get-InstalledModule -Name 'PSDepend' -RequiredVersion $PSDependVersion -ErrorAction 'SilentlyContinue')) {
    Install-Module -Name 'PSDepend' -RequiredVersion $PSDependVersion -Force -Scope 'CurrentUser'
}
Import-Module -Name 'PSDepend' -RequiredVersion $PSDependVersion
Invoke-PSDepend -Path "$PSScriptRoot\build.Depend.psd1" -Install -Import -Force

Invoke-Build -Task $Task -Result BuildResult -VersionIncrement $VersionIncrement -Verbose -Debug

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
