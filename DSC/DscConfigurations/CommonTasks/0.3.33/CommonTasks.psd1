@{
    ModuleVersion        = '0.3.33'

    GUID                 = 'b095161b-ceef-4856-89a3-2c4af3f81c4d'

    Author               = 'NA'

    CompanyName          = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'PSDesiredStateConfiguration'; ModuleVersion = '1.1' }
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #    @{ ModuleName = 'NetworkingDsc'; ModuleVersion = '6.1.0.0' }
    #    @{ ModuleName = 'ComputerManagementDsc'; ModuleVersion = '5.2.0.0' }
    #)

    DscResourcesToExport = @('*')

    Description          = 'DSC composite resource for https://github.com/AutomatedLab/DscWorkshop'

    PrivateData          = @{

        PSData = @{

            Tags                       = @('DSC', 'Configuration', 'Composite', 'Resource')

            ExternalModuleDependencies = @('PSDesiredStateConfiguration')

        }
    }
}