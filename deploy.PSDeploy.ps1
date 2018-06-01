# API Key is in $Env:NugetApiKey

# Folder structure:
#   Repository Root
#       PSDeploy Script
#       output
#           Module Folder
#               ModuleName.psd1

# Only deploy if the project name is known and the output directory exists.
if ($Env:BHProjectName -and (Test-Path -Path ".\output\$Env:BHProjectName")) {
    Deploy Module {
        By PSGalleryModule {
            FromSource output\$ENV:BHProjectName
            To $Env:PublishToRepo
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
            }
        }
    }
}
else {
    Write-Warning -Message "Module not deployed. Module name: $Env:BHProjectName; module path exists: $(Test-Path -Path ".\output\$Env:BHProjectName")"
}