@{
    # Version number of this module.
    moduleVersion = '3.1.1'

    # ID used to uniquely identify this module
    GUID = 'b3239f27-d7d3-4ae6-a5d2-d9a1c97d6ae4'

    # Author of this module
    Author = 'DSC Community'

    # Company or vendor of this module
    CompanyName = 'DSC Community'

    # Copyright statement for this module
    Copyright = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Module with DSC Resources for Web Administration'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion = '4.0'

    # Functions to export from this module
    FunctionsToExport = @()

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    DscResourcesToExport = @(
        'WebApplicationHandler'
        'xIisFeatureDelegation'
        'xIIsHandler'
        'xIisLogging'
        'xIisMimeTypeMapping'
        'xIisModule'
        'xSslSettings'
        'xWebApplication'
        'xWebAppPool'
        'xWebAppPoolDefaults'
        'xWebConfigKeyValue'
        'xWebConfigProperty'
        'xWebConfigPropertyCollection'
        'xWebSite'
        'xWebSiteDefaults'
        'xWebVirtualDirectory'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{
            Prerelease = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/dsccommunity/xWebAdministration/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/dsccommunity/xWebAdministration'

            # A URL to an icon representing this module.
            IconUri = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '# Change log for xWebAdministration

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For older change log history see the [historic changelog](HISTORIC_CHANGELOG.md).

## [Unreleased]

### Changed

- xWebAdministration
  - Set `testRunTitle` for PublishTestResults task so that a helpful name is
    displayed in Azure DevOps for each test file artifact.
  - Update Visual Studio Code workspace settings for the repository.
  - Set a display name on all the jobs and tasks in the CI pipeline.
  
### Fixed

- xWebAdministration
  - Update GitVersion.yml with the correct regular expression.
- xWebsite
  - Fixed HTTPS binding issue causing failure when CertificateSubject matches
    multiple certificates.

## [3.1.0] - 2019-12-30

### Added

- xWebAdministration
  - Added continuous delivery with a new CI pipeline
    ([issue #547](https://github.com/PowerShell/xWebAdministration/issues/547)).
  - Added CONTRIBUTION.md.

### Changed

- xWebAdministration.Common
  - Added new helper function `Get-WebConfigurationPropertyValue` to
    help return a value of a `WebConfigurationProperty`. *This helper*
    *function is unable to be unit tested because it is using a type*
    *that cannot be mocked.*
- xWebAppPoolDefaults
  - Changed to use the new helper function `Get-WebConfigurationPropertyValue`
    so that the resource can be properly unit tested.
- xWebConfigProperty
  - Changed to use the new helper function `Get-WebConfigurationPropertyValue`
    so that the resource can be properly unit tested.

### Fixed

- WebApplicationHandler
  - Fix Test-TargetResource to compare only properties that are specified
    in the configuration ([issue #544](https://github.com/PowerShell/xWebAdministration/issues/544)).
- xWebConfigProperty
  - In some cases a verbose message was not outputted with any text, now
    all verbose messages are correctly shown.
- xWebSite
  - In some cases a verbose message was not outputted with any text, now
    all verbose messages are correctly shown.

### Removed

- CommonTestHelper
  - Removed unused functions `Get-InvalidArgumentRecord` and
    `Get-InvalidOperationRecord`.
'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}





