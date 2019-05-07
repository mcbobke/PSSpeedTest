$Script:ModuleRoot = Resolve-Path "$PSScriptRoot\..\output\$Env:BHProjectName"
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$scripts = Get-ChildItem $Script:ModuleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

Describe "General project validation: $Script:ModuleName" {
    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object {@{file = $_}}
    It "Script <file> should be valid PowerShell" -TestCases $testCase {
        param($file)

        $file.fullname | Should -Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should -Be 0
    }
}

Describe "PSScriptAnalyzer for module: $Script:ModuleName" {
    $rules = Get-ScriptAnalyzerRule -Severity Error

    foreach ($script in $scripts) {
        Context "Script '$($script.FullName)'" {
            $analyzerResults = Invoke-ScriptAnalyzer -Path $script.FullName -IncludeRule $rules
            if ($analyzerResults) {
                foreach ($rule in $analyzerResults) {
                    It $rule.RuleName {
                        $message = "{0} Line {1}: {2}" -f $rule.Severity, $rule.Line, $rule.message
                        $message | Should -Be ""
                    }
                }
            }
            else {
                It "Should not fail any rules" {
                    $analyzerResults | Should -BeNullOrEmpty
                }
            }
        }
    }
}