$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$scripts = Get-ChildItem $Script:ModuleRoot -Filter '*.ps1' -Recurse

Describe "Function Help tests for $Script:ModuleName" {
    BeforeAll {
        Get-Module -All -Name $Script:ModuleName | Remove-Module -Force -ErrorAction 'Ignore'
        Import-Module $Global:TestThisModule
    }

    It "Functions all have necessary comment-based help items" {
        foreach ($script in $scripts) {
            . $script.FullName
            $functionName = $script.BaseName
            $functionHelp = Get-Help $functionName -Full

            $functionHelp.Synopsis | Should -Not -BeNullOrEmpty
            $functionHelp.description | Should -Not -BeNullOrEmpty
            $functionHelp.examples | Should -Not -BeNullOrEmpty

            Remove-Item -Path "Function:\$($script.BaseName)"
        }
    }
}