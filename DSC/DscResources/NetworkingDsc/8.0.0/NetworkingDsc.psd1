@{
    # Version number of this module.
    moduleVersion        = '8.0.0'

    # ID used to uniquely identify this module
    GUID                 = 'e6647cc3-ce9c-4c86-9eb8-2ee8919bf358'

    # Author of this module
    Author               = 'DSC Community'

    # Company or vendor of this module
    CompanyName          = 'DSC Community'

    # Copyright statement for this module
    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'DSC resources for configuring settings related to networking.'

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
        'DefaultGatewayAddress',
        'DnsClientGlobalSetting',
        'DnsConnectionSuffix',
        'DNSServerAddress',
        'Firewall',
        'FirewallProfile',
        'HostsFile',
        'IPAddress',
        'IPAddressOption',
        'NetAdapterAdvancedProperty',
        'NetAdapterBinding',
        'NetAdapterLso',
        'NetAdapterName',
        'NetAdapterRDMA',
        'NetAdapterRsc',
        'NetAdapterRss',
        'NetAdapterState',
        'NetBIOS',
        'NetConnectionProfile',
        'NetIPInterface',
        'NetworkTeam',
        'NetworkTeamInterface',
        'ProxySettings',
        'Route',
        'WINSSetting'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/NetworkingDsc/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/NetworkingDsc'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [8.0.0] - 2020-06-21

### Added

- NetworkingDsc:
  - Added build task `Generate_Conceptual_Help` to generate conceptual help
    for the DSC resource.
  - Added build task `Generate_Wiki_Content` to generate the wiki content
    that can be used to update the GitHub Wiki.
- Common:
  - Added Assert-IPAddress function to reduce code duplication - Fixes
    [Issue #408](https://github.com/dsccommunity/NetworkingDsc/issues/408).

### Changed

- NetworkingDsc:
  - Updated to use the common module _DscResource.Common_.
  - Fixed build failures caused by changes in `ModuleBuilder` module v1.7.0
    by changing `CopyDirectories` to `CopyPaths` - Fixes [Issue #455](https://github.com/dsccommunity/NetworkingDsc/issues/455).
  - Pin `Pester` module to 4.10.1 because Pester 5.0 is missing code
    coverage - Fixes [Issue #456](https://github.com/dsccommunity/NetworkingDsc/issues/456).
- DefaultGatewayAddress:
  - Refactored to reduce code duplication.
  - Fixed hash table style violations - fixes [Issue #429](https://github.com/dsccommunity/NetworkingDsc/issues/429).
  - Fixed general style violations.
- Added `.gitattributes` to ensure CRLF is used when pulling repository - Fixes
  [Issue #430](https://github.com/dsccommunity/NetworkingDsc/issues/430).
- BREAKING CHANGE: Changed resource prefix from MSFT to DSC.
- Updated to use continuous delivery pattern using Azure DevOps - Fixes
  [Issue #435](https://github.com/dsccommunity/NetworkingDsc/issues/435).
- Updated CI pipeline files.
- No longer run integration tests when running the build task `test`, e.g.
  `.\build.ps1 -Task test`. To manually run integration tests, run the
  following:
  ```powershell
  .\build.ps1 -Tasks test -PesterScript ''tests/Integration'' -CodeCoverageThreshold 0
  ```
- Change Azure DevOps Pipeline definition to include `source/*` - Fixes [Issue #450](https://github.com/dsccommunity/NetworkingDsc/issues/450).
- Updated pipeline to use `latest` version of `ModuleBuilder` - Fixes [Issue #451](https://github.com/dsccommunity/NetworkingDsc/issues/451).
- Merge `HISTORIC_CHANGELOG.md` into `CHANGELOG.md` - Fixes [Issue #451](https://github.com/dsccommunity/NetworkingDsc/issues/451).
- NetBios:
  - Improved integration tests by using loopback adapter.
  - Refactored unit tests to reduce code duplication and
    increase coverage.
  - Fix exception when specifying wildcard ''*'' in the
    `InterfaceAlias` - Fixes [Issue #444](https://github.com/dsccommunity/NetworkingDsc/issues/444).

### Deprecated

- None

### Removed

- None

### Fixed

- Fixed IDs of Azure DevOps pipeline in badges in README.MD - Fixes
  [Issue #438](https://github.com/dsccommunity/NetworkingDsc/issues/438).
- Fixed typo in link to Wiki in README.MD

### Security

- None

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}



