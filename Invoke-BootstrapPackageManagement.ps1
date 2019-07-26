function Invoke-BootstrapPackageManagement {
    [CmdletBinding()]
    Param()
    
    if ($PSVersionTable.PSVersion.ToString() -match '^5.1') {
        $scriptBlock = {
            Install-PackageProvider 'NuGet' -Force -MinimumVersion '2.8.5.208' -Scope AllUsers -WarningAction SilentlyContinue | Out-Null
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
            Install-Module -Name 'PackageManagement' -Force -Scope AllUsers -WarningAction SilentlyContinue | Out-Null
            Install-Module -Name 'PowerShellGet' -Force -Scope AllUsers -WarningAction SilentlyContinue | Out-Null
        }
    }
    elseif ($IsWindows) {
        $scriptBlock = {
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
            Install-Module -Name 'PackageManagement' -Force -Scope AllUsers -WarningAction SilentlyContinue | Out-Null
            Install-Module -Name 'PowerShellGet' -Force -Scope AllUsers -WarningAction SilentlyContinue | Out-Null
        }
    }
    else {
        Write-Error -Message 'This function requires Windows PowerShell or PowerShell Core on Windows.'
        throw
    }

    Write-Output 'Bootstrapping package management'

    Start-Job -ScriptBlock $scriptBlock | Wait-Job | Receive-Job | Out-Null

    Write-Output 'Package management boostrapped'
}