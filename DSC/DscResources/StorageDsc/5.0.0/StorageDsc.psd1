@{
    # Version number of this module.
    moduleVersion        = '5.0.0'

    # ID used to uniquely identify this module
    GUID                 = '00d73ca1-58b5-46b7-ac1a-5bfcf5814faf'

    # Author of this module
    Author               = 'DSC Community'

    # Company or vendor of this module
    CompanyName          = 'DSC Community'

    # Copyright statement for this module
    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'DSC resources for managing storage on Windows Servers.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '4.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion           = '4.0'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @()

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # DSC resources to export from this module
    DscResourcesToExport = @(
        'DiskAccessPath',
        'MountImage',
        'OpticalDiskDriveLetter',
        'WaitForDisk',
        'WaitForVolume',
        'Disk'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'Disk', 'Storage', 'Partition', 'Volume')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/StorageDsc/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/StorageDsc'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [5.0.0] - 2020-05-05

### Changed

- Fixed hash table style violations - fixes [Issue #219](https://github.com/dsccommunity/StorageDsc/issues/219).
- Disk:
  - Updated example with size as a number in bytes and without unit of measurement
    like GB or MB - fixes [Issue #214](https://github.com/dsccommunity/StorageDsc/pull/214).
- BREAKING CHANGE: Changed resource prefix from MSFT to DSC.
- BREAKING CHANGE: Changed Disk resource prefix from MSFTDSC to DSC as there
  would no longer be a conflict with the built in MSFT_Disk CIM class.
- Updated to use continuous delivery pattern using Azure DevOps - fixes
  [Issue #225](https://github.com/dsccommunity/StorageDsc/issues/225).
- Updated Examples and Module Manifest to be DSC Community from Microsoft.
- Added Integration tests on Windows Server 2019.
- WaitForVolume:
  - Improved unit tests to use virtual disk instead of physical disk.
- Disk:
  - Added `Invalid Parameter` exception being reported when ReFS volumes are
    used with Windows Server 2019 as a known issue to README.MD - fixes
    [Issue #227](https://github.com/dsccommunity/StorageDsc/issues/227).
- Updated build badges in README.md.
- Change Azure DevOps Pipeline definition to include `source/*` - Fixes [Issue #231](https://github.com/dsccommunity/StorageDsc/issues/231).
- Updated pipeline to use `latest` version of `ModuleBuilder` - Fixes [Issue #231](https://github.com/dsccommunity/StorageDsc/issues/231).
- Merge `HISTORIC_CHANGELOG.md` into `CHANGELOG.md` - Fixes [Issue #232](https://github.com/dsccommunity/StorageDsc/issues/232).
- OpticalDiskDriveLetter:
  - Suppress exception when requested optical disk drive does not exist
    and Ensure is set to `Absent` - Fixes [Issue #194](https://github.com/dsccommunity/StorageDsc/issues/194).

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}



