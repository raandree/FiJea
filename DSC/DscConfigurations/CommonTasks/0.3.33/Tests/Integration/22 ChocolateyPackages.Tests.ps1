$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'ChocolateyPackages DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'ChocolateyPackages Compiles' {
        configuration Config_ChocolateyPackages {

            Import-DscResource -ModuleName CommonTasks

            node localhost_ChocolateyPackages {
                ChocolateyPackages ChocolateyPackages {
                    Package = $ConfigurationData.ChocolateyPackages.Packages
                }
            }
        }

        { Config_ChocolateyPackages -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'ChocolateyPackages should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_ChocolateyPackages.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}