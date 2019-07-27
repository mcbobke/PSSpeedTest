Param(
    $VersionIncrement = 'Patch'
)

Task Default Build, Test
Task Build CopyOutput, GetReleasedModuleInfo, BuildPSM1, BuildPSD1

#region Read-PreviousRelease
function Read-PreviousRelease {
    Param (
        [Parameter(Mandatory)]
        [string]
        $Name,
        [Parameter(Mandatory)]
        [string]
        $Repository,
        [Parameter(Mandatory)]
        [string]
        $Path
    )

    $ModuleReader = {
        Param (
            [string]
            $Name,
            [string]
            $Repository,
            [string]
            $Path
        )

        try {
            Save-Module -Name $Name -Path $Path -Repository $Repository -ErrorAction Stop
            Import-Module -Name "$Path\$Name" -PassThru -ErrorAction Stop
        } catch {
            if ($_ -match 'No match was found for the specified search criteria') {
                @()
            } else {
                $_
            }
        }
    }

    $parameters = @{
        Name       = $Name;
        Repository = $Repository;
        Path       = $Path;
    }

    # Runspace is used to avoid importing old versions of the module in the current session
    $PowerShellRunspace = [powershell]::Create()
    $null = $PowerShellRunspace.AddScript($ModuleReader).AddParameters($parameters)

    $PowerShellRunspace.Invoke()
}
#endregion Read-PreviousRelease

#region Get-PublicFunctionInterfaces
function Get-PublicFunctionInterfaces {
    Param (
        [System.Management.Automation.FunctionInfo[]]
        $FunctionList
    )

    $functionInterfaces = New-Object -TypeName System.Collections.ArrayList

    foreach ($function in $FunctionList) {
        foreach ($parameter in $function.Parameters.Keys) {
            Write-Verbose "$($function.Name)"
            Write-Verbose "$($function.Parameters[$parameter].Name)"
            $toAdd = "{0}:{1}" -f $function.Name, $function.Parameters[$parameter].Name
            $null = $functionInterfaces.Add($toAdd)
            
            foreach ($alias in $function.Parameters[$parameter].Aliases) {
                Write-Verbose "$($function.Name)"
                Write-Verbose "$($alias)"
                $toAdd = "{0}:{1}" -f $function.Name, $alias
                $null = $functionInterfaces.Add($toAdd)
            }
        }
    }

    $functionInterfaces
}
#endregion Get-PublicFunctionInterfaces

#region Publish-TestResults
function Publish-TestResults {
    Param (
        [string]
        $Path
    )

    if ($Env:BHBuildSystem -eq 'Unknown') {
        Write-Warning 'Build system unknown; skipping test results publishing.'
        return
    }

    Write-Output 'Publishing test results data file...'
    switch ($Env:BHBuildSystem) {
        'AppVeyor' { 
            (New-Object 'System.Net.WebClient').UploadFile(
                "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
                $Path)
        }
        Default {
            Write-Warning "Publish test result not implemented for build system '$($Env:BHBuildSystem)'."
        }
    }
}
#endregion Publish-TestResults

#region Enter-Build
Enter-Build {
    $Script:publishToRepo = 'PSGallery'
    if (!(Get-Item 'Env:\BH*')) {
        Set-BuildEnvironment
        Set-Item -Path 'Env:\PublishToRepo' -Value $Script:publishToRepo
    }

    $Script:ModuleName = $Env:BHProjectName
    $Script:Source = Join-Path -Path $BuildRoot -ChildPath $Script:ModuleName
    $Script:Output = Join-Path -Path $BuildRoot -ChildPath 'output'
    $Script:Destination = Join-Path -Path $Script:Output -ChildPath $Script:ModuleName
    $Script:ModulePath = Join-Path -Path $Script:Destination -ChildPath "$Script:ModuleName.psm1"
    $Script:ManifestPath = Join-Path -Path $Script:Destination -ChildPath "$Script:ModuleName.psd1"
    $Script:Imports = ('public', 'private')
    $Script:TestFile = "$PSScriptRoot\output\TestResults_PS$PSVersion.xml"
    $Script:TestThisModule = $Script:ManifestPath
}
#endregion Enter-Build

#region Clean
Task Clean {
    Remove-Item -Path $Output -Recurse -ErrorAction Ignore | Out-Null
}
#endregion Clean

#region CopyOutput
Task CopyOutput {
    Write-Output "  Creating directory [$Script:Destination]"
    New-Item -Type Directory -Path $Script:Destination -ErrorAction Ignore | Out-Null

    Write-Output "  Files and directories to be copied from source [$Script:Source]"

    Get-ChildItem -Path $Script:Source -File |
        Where-Object -Property Name -NotMatch "$Script:ModuleName\.ps[md]1" |
        Copy-Item -Destination $Script:Destination -Force -PassThru |
        ForEach-Object {'   Creating file [{0}]' -f $_.fullname.replace($PSScriptRoot, '')}

    Get-ChildItem -Path $Script:Source -Directory |
        Copy-Item -Destination $Script:Destination -Recurse -Force -PassThru |
        ForEach-Object {'   Creating directory (recursive) [{0}]' -f $_.fullname.replace($PSScriptRoot, '')}
}
#endregion CopyOutput

#region GetReleasedModuleInfo
Task GetReleasedModuleInfo {
    $downloadPath = "$Script:Output\releasedModule"
    if (!(Test-Path $downloadPath)) {
        $null = New-Item -Path $downloadPath -ItemType Directory
    }

    $releasedModule = Read-PreviousRelease -Name $Script:ModuleName -Repository $Script:publishToRepo -Path $downloadPath

    if (($releasedModule -ne $null) -and ($releasedModule.GetType() -eq [System.Management.Automation.ErrorRecord])) {
        Write-Error $releasedModule
        return
    }

    $moduleInfo = $null

    if ($releasedModule -eq $null) {
        $moduleInfo = [PSCustomObject] @{
            Version            = [Version]::New(0, 0, 1)
            FunctionInterfaces = New-Object -TypeName System.Collections.ArrayList
        }
    } else {
        $moduleInfo = [PSCustomObject] @{
            Version            = $releasedModule.Version
            FunctionInterfaces = Get-PublicFunctionInterfaces -FunctionList $releasedModule.ExportedFunctions.Values
        }
    }

    $moduleInfo | Export-Clixml -Path "$Script:Output\released-module-info.xml"
}
#endregion GetReleasedModuleInfo

#region BuildPSM1
Task BuildPSM1 {
    [System.Text.StringBuilder]$StringBuilder = [System.Text.StringBuilder]::new()
    foreach ($folder in $Script:Imports) {
        if (Test-Path "$Script:Source\$folder") {
            $fileList = Get-ChildItem "$Script:Source\$folder" -Filter '*.ps1'
            foreach ($file in $fileList) {
                $importName = "$folder\$($file.Name)"
                Write-Output "  Found $importName"
                
                $filePath = Resolve-Path -Path "$Script:Source\$importName" -ErrorAction 'Ignore'
                if ($filePath) {
                    $functionFileEndBlock = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$null, [ref]$null) |
                        Select-Object -ExpandProperty 'EndBlock'
                    
                    $functionContents = $functionFileEndBlock.ToString()

                    $null = $StringBuilder.AppendLine($functionContents)
                }
            }
        }
    }
    
    Write-Output "  Creating module [$Script:ModulePath]"
    Set-Content -Path $Script:ModulePath -Value $StringBuilder.ToString()
}
#endregion BuildPSM1

#region BuildPSD1
Task BuildPSD1 {
    Write-Output "  Updating [$Script:ManifestPath]"
    Copy-Item "$Script:Source\$ModuleName.psd1" -Destination $Script:ManifestPath

    $moduleFunctions = Get-ChildItem -Path "$Script:Source\public" -Filter '*.ps1' |
        Select-Object -ExpandProperty BaseName
    Set-ModuleFunctions -Name $Script:ManifestPath -FunctionsToExport $moduleFunctions
    Set-ModuleAliases -Name $Script:ManifestPath

    $releasedModuleInfo = Import-Clixml -Path "$Script:Output\released-module-info.xml"
    Get-Module -Name $Script:ModuleName -All | Remove-Module -Force -ErrorAction 'Ignore'
    $newFunctionList = (Import-Module -Name $Script:ManifestPath -PassThru).ExportedFunctions.Values
    Get-Module -Name $Script:ModuleName -All | Remove-Module -Force -ErrorAction 'Ignore'
    $newFunctionInterfaces = Get-PublicFunctionInterfaces -FunctionList $newFunctionList
    $oldFunctionInterfaces = $releasedModuleInfo.FunctionInterfaces

    Write-Output '  Detecting new features'
    foreach ($interface in $newFunctionInterfaces) {
        if ($interface -notin $oldFunctionInterfaces) {
            $VersionIncrement = 'Minor'
            Write-Output "      $interface"
        }
    }
    Write-Output '  Detecting lost features (breaking changes)'
    foreach ($interface in $oldFunctionInterfaces) {
        if ($interface -notin $newFunctionInterfaces) {
            $VersionIncrement = 'Major'
            Write-Output "      $interface"
        }
    }
    
    $version = [Version](Get-Metadata -Path $Script:ManifestPath -PropertyName 'ModuleVersion')

    # Don't bump major version if in pre-release
    if ($version -lt ([Version]'1.0.0')) {
        if ($VersionIncrement -eq 'Major') {
            $VersionIncrement = 'Minor'
        } else {
            $VersionIncrement = 'Patch'
        }
    }

    $releasedVersion = $releasedModuleInfo.Version
    if ($version -lt $releasedVersion) {
        $version = $releasedVersion
    }
    if ($version -eq $releasedVersion) {
        $version = [Version](Step-Version -Version $releasedVersion -By $VersionIncrement)
        Write-Output "  Stepping module from released version [$releasedVersion] to new version [$version] by [$VersionIncrement]"
        Update-Metadata -Path $Script:ManifestPath -PropertyName 'ModuleVersion' -Value $version
    } else {
        Write-Output "  Using version from $Script:ModuleName.psd1: $version"
    }
}
#endregion BuildPSD1

#region Test
Task Test {
    Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
    Import-Module -Name $Script:TestThisModule
    $origConfirmPreference = $Global:ConfirmPreference
    $Global:ConfirmPreference = 'None'

    $pesterParams = @{
        PassThru     = $true;
        Strict       = $true;
        OutputFormat = 'NUnitXml';
        OutputFile   = $Script:TestFile;
    }
    $testResults = Invoke-Pester @pesterParams

    $Global:ConfirmPreference = $origConfirmPreference
    Publish-TestResults -Path $Script:TestFile
    assert ($testResults.FailedCount -eq 0) "There was [$($testResults.FailedCount)] failed test(s)."
}
#endregion Test

#region Deploy
Task Deploy {
    if (
        $Env:BHBuildSystem -ne 'Unknown' -and
        $Env:BHBranchName -eq 'Master' -and
        $Env:BHCommitMessage -match '!deploy'
    ) {
        $DeployParams = @{
            Path  = $BuildRoot;
            Force = $true;
        }

        Invoke-PSDeploy @DeployParams
    } else {
        Write-Output '  Skipping deployment:'
        Write-Output "  Build system: $Env:BHBuildSystem"
        Write-Output "  Current branch (should be master): $Env:BHBranchName"
        Write-Output "  Commit message (should include '!deploy'): $Env:BHCommitMessage"
    }
}
#endregion Deploy