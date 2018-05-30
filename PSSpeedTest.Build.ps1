Param(
    $VersionIncrement = 'Patch'
)

Task Default Build, Test, Distribute
Task Build CopyOutput, BuildPSM1, BuildPSD1

function PublishTestResults {
    Param (
        [string]$Path
    )

    if ($Env:BHBuildSystem -eq 'Unknown')
    {
        Write-Warning "Build system unknown; skipping test results publishing."
        return
    }

    Write-Output "Publishing test results data file..."
    switch ($Env:BHBuildSystem)
    {
        'AppVeyor'
        { 
            (New-Object 'System.Net.WebClient').UploadFile(
                "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
                $Path)
        }
        Default
        {
            Write-Warning "Publish test result not implemented for build system '$($Env:BHBuildSystem)'."
        }
    }
}

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
    $Global:TestThisModule = $Script:ManifestPath
}

Task Clean {
    Remove-Item -Path $Output -Recurse -ErrorAction Ignore | Out-Null
}

Task CopyOutput {
    Write-Output "Creating directory [$Script:Destination]"
    New-Item -Type Directory -Path $Script:Destination -ErrorAction Ignore | Out-Null

    Write-Output "Files and directories to be copied from source [$Script:Source]"
    Get-ChildItem -Path $Script:Source -File | `
        Where-Object -Property Name -NotMatch "$Script:ModuleName\.ps[md]1" | `
        Copy-Item -Destination $Script:Destination -Force -PassThru | `
        ForEach-Object {"Creating file [{0}]" -f $_.fullname.replace($PSScriptRoot, '')}

    Get-ChildItem -Path $Script:Source -Directory | `
        Copy-Item -Destination $Script:Destination -Recurse -Force -PassThru | `
        ForEach-Object {"Creating directory (recursive) [{0}]" -f $_.fullname.replace($PSScriptRoot, '')}
}

Task BuildPSM1 -Inputs (Get-ChildItem -Path $Script:Source -Recurse -Include '*.ps1') -Outputs $Script:ModulePath {

    [System.Text.StringBuilder]$StringBuilder = [System.Text.StringBuilder]::new()
    foreach ($folder in $Script:Imports)
    {
        [void]$StringBuilder.AppendLine("Write-Verbose 'Importing from [`$PSScriptRoot\`$folder]'")
        if (Test-Path "$Script:Source\$folder")
        {
            $fileList = Get-ChildItem "$Script:Source\$folder" -Include '*.ps1'
            foreach ($file in $fileList)
            {
                $importName = "$folder\$($file.Name)"
                Write-Output "  BuildPSM1 Task - Found $importName"
                [void]$StringBuilder.AppendLine( ".\$importName" )
            }
        }
    }

    [void]$StringBuilder.AppendLine("`$publicFunctions = (Get-ChildItem -Path `"`$PSScriptRoot\public`" -Filter '*.ps1').BaseName")
    [void]$StringBuilder.AppendLine("Export-ModuleMember -Function `$publicFunctions")
    
    Write-Output " BuildPSM1 Task - Creating module [$Script:ModulePath]"
    Set-Content -Path $Script:ModulePath -Value $stringbuilder.ToString() 
}

Task BuildPSD1 {
    Write-Output "Updating [$Script:ManifestPath]"
    Copy-Item "$Script:Source\$ModuleName.psd1" -Destination $Script:ManifestPath

    $moduleFunctions = Get-ChildItem "$Script:Source\public" -Include '*.ps1' | `
        Select-Object -ExpandProperty BaseName
    Set-ModuleFunctions -Name $Script:ManifestPath -FunctionsToExport $moduleFunctions
    Set-ModuleAliases -Name $Script:ManifestPath

    $currentVersion = [Version](Get-Metadata -Path $Script:ManifestPath -PropertyName 'ModuleVersion')
    if ($Env:BHCommitMessage -match '!(major|minor)') {
        $VersionIncrement = $Matches[1]
    }
    $newVersion = [Version](Step-Version -Version $currentVersion -By $VersionIncrement)
    Write-Output "Stepping module from current version [$currentVersion] to new version [$newVersion] by [$VersionIncrement]"
    Update-Metadata -Path $Script:ManifestPath -PropertyName 'ModuleVersion' -Value $newVersion
}

Task Test {
    $pesterParams = @{
        PassThru = $true;
        Strict = $true;
        OutputFormat = 'NUnitXml';
        OutputFile = $Script:TestFile;
    }
    $testResults = Invoke-Pester @pesterParams

    PublishTestResults -Path $Script:TestFile

    assert ($testResults.FailedCount -eq 0) "There was [$($testResults.FailedCount)] failed test(s)."
}

Task Distribute {
    if (
        $Env:BHBuildSystem -ne 'Unknown' -and
        $Env:BHBranchName -eq 'Master' -and
        $Env:BHCommitMessage -match '!deploy'
    ) {
        $DeployParams = @{
            Path = $BuildRoot;
            Force = $true;
        }

        Invoke-PSDeploy @DeployParams
    }
    else {
        Write-Output "Skipping deployment:"
        Write-Output "Build system: $Env:BHBuildSystem"
        Write-Output "Current branch (should be master): $Env:BHBranchName"
        Write-Output "Commit message (should include '!deploy'): $Env:BHCommitMessage"
    }
}