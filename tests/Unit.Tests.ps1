$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\$Env:BHProjectName"
$Script:ModuleName = Split-Path $moduleRoot -Leaf

Describe "Unit tests for $Script:ModuleName" {
    BeforeAll {
        Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
        Import-Module $Global:TestThisModule
    }

    AfterAll {
        Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
    }
}