function Get-JeaEndpoint {
    param(
        [Parameter(Mandatory)]
        [string]
        $ComputerName,

        [Parameter()]
        [string]
        $DiscoveryEndpoint = 'JeaDiscovery',

        [Parameter()]
        [pscredential]
        $Credential
    )
    
    $param = @{
        ComputerName      = $ComputerName
        ConfigurationName = $DiscoveryEndpoint
        ScriptBlock       = { Get-JeaPSSessionConfiguration }
    }
    if ($Credential) {
        $param.Add('Credential', $Credential)
    }

    Invoke-Command @param | Where-Object Name -ne JeaDiscovery | ForEach-Object {
        [pscustomobject]@{
        Author = $_.Author
        GroupManagedServiceAccount = $_.GroupManagedServiceAccount
        RoleDefinitions = $_.RoleDefinitions
        SessionType = $_.SessionType
        #SchemaVersion                 : 2.0.0.0
        #GUID                          : 7da04eca-39fd-4aef-b3a4-7f25d7d083d3
        #RunAsPassword                 : System.Security.SecureString
        #ResourceUri                   : http://schemas.microsoft.com/powershell/AdManagement
        #Capability                    : {Shell}
        #PSVersion                     : 5.1
        #AutoRestart                   : false
        #ExactMatch                    : False
        #RunAsVirtualAccount           : false
        #SDKVersion                    : 2
        #Uri                           : http://schemas.microsoft.com/powershell/AdManagement
        #MaxConcurrentCommandsPerShell : 2147483647
        #IdleTimeoutms                 : 7200000
        #ParentResourceUri             : http://schemas.microsoft.com/powershell/AdManagement
        RunAsUser = $_.RunAsUser
        #OutputBufferingMode           : Block
        #Architecture                  : 64
        #UseSharedProcess              : false
        #MaxProcessesPerShell          : 2147483647
        #Filename                      : %windir%\system32\pwrshplugin.dll
        #MaxShellsPerUser              : 2147483647
        #ConfigFilePath                : C:\Windows\System32\WindowsPowerShell\v1.0\SessionConfig\AdManagement_7da04eca-39fd-4aef-b3a4-7f25d7d083d3.pssc
        #MaxShells                     : 2147483647
        #SupportsOptions               : true
        #lang                          : en-US
        #MaxIdleTimeoutms              : 2147483647
        #xmlns                         : http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration
        #Enabled                       : True
        SecurityDescriptorSddl = $_.SecurityDescriptorSddl
        Name = $_.Name
        #ProcessIdleTimeoutSec         : 0
        #MaxConcurrentUsers            : 2147483647
        #MaxMemoryPerShellMB           : 2147483647
        RunAsVirtualAccountGroups = $_.RunAsVirtualAccountGroups
        #XmlRenderingType              : text
        Permission = $_.Permission
        #PSComputerName                : localhost
        RunspaceId = $_.RunspaceId
        #PSShowComputerName            : True
        }
    }
}

$d = Get-JeaEndpoint -ComputerName localhost