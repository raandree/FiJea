@{

    RootModule           = 'JeaDsc.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = 'c7c41e83-55c3-4e0f-9c4f-88de602e04db'

    Author               = 'DSC Community'

    CompanyName          = 'DSC Community'

    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    Description          = 'This module contains resources to configure Just Enough Administration endpoints.'

    PowerShellVersion    = '5.1'

    NestedModules        = @(
        'DSCClassResources\JeaSessionConfiguration\JeaSessionConfiguration.psd1'
        'DSCClassResources\JeaRoleCapabilities\JeaRoleCapabilities.psd1'
    )

    FunctionsToExport    = @(
        'ConvertTo-Expression'
    )

    CmdletsToExport      = @()

    VariablesToExport    = @()

    AliasesToExport      = @()

    DscResourcesToExport = @(
        'JeaSessionConfiguration'
        'JeaRoleCapabilities'
    )

    PrivateData          = @{

        PSData = @{

            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'JEA', 'JustEnoughAdministration')

            LicenseUri   = 'https://github.com/dsccommunity/JeaDsc/blob/master/LICENSE'

            ProjectUri   = 'https://github.com/dsccommunity/JeaDsc'

            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            Prerelease   = ''

            ReleaseNotes = '## [0.0.1] - 2020-08-14

- Renamed ''Test-DscParameterState'' to ''Test-DscParameterState2'' for a conflict with ''DscResource.Common''.
- Removing functions provided by ''DscResource.Common''
- Making property ''RoleDefinitions'' non-mandatory
- Replacing ''New-PSRoleCapabilityFile'' by writing the file directly
- Making ''ConvertTo-Expression'' visible as it is required also from the outside

### Added

- Migrated the resource to Sampler

### Changed

- Fixed a lot of issues.

### Deprecated

- None

### Removed

- None

### Fixed

- None

### Security

- None
'

        }

    }
}



