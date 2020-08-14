<#PSScriptInfo
.VERSION 1.0.0
.GUID f4a025e1-1134-4ebb-a11c-2e3ff331e175
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/DfsDsc/blob/master/LICENSE
.PROJECTURI https://github.com/PowerShell/DfsDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module DfsDsc

<#
    .DESCRIPTION
        Create a DFS Replication Group called Public containing two members, FileServer1 and
        FileServer2. The Replication Group contains a single folder called Software. A description
        will be set on the Software folder and it will be set to exclude the directory Temp from
        replication. An automatic fullmesh topology is assigned to the replication group connections.
#>
Configuration DFSReplicationGroupMembership_FullMesh_Config
{
    param
    (
        [Parameter()]
        [PSCredential]
        $Credential
    )

    Import-DscResource -Module DFSDsc

    Node localhost
    {
        <#
            Install the Prerequisite features first
            Requires Windows Server 2012 R2 Full install
        #>
        WindowsFeature RSATDFSMgmtConInstall
        {
            Ensure = 'Present'
            Name = 'RSAT-DFS-Mgmt-Con'
        }

        # Configure the Replication Group
        DFSReplicationGroup RGPublic
        {
            GroupName = 'Public'
            Description = 'Public files for use by all departments'
            Ensure = 'Present'
            Members = 'FileServer1','FileServer2'
            Folders = 'Software'
            Topology = 'Fullmesh'
            PSDSCRunAsCredential = $Credential
            DependsOn = '[WindowsFeature]RSATDFSMgmtConInstall'
        } # End of RGPublic Resource

        DFSReplicationGroupFolder RGSoftwareFolder
        {
            GroupName = 'Public'
            FolderName = 'Software'
            Description = 'DFS Share for storing software installers'
            DirectoryNameToExclude = 'Temp'
            PSDSCRunAsCredential = $Credential
            DependsOn = '[DFSReplicationGroup]RGPublic'
        } # End of RGPublic Resource

        DFSReplicationGroupMembership RGPublicSoftwareFS1
        {
            GroupName = 'Public'
            FolderName = 'Software'
            ComputerName = 'FileServer1'
            ContentPath = 'd:\Public\Software'
            StagingPathQuotaInMB = 4096
            PrimaryMember = $true
            PSDSCRunAsCredential = $Credential
            DependsOn = '[DFSReplicationGroupFolder]RGSoftwareFolder'
        } # End of RGPublicSoftwareFS1 Resource

        DFSReplicationGroupMembership RGPublicSoftwareFS2
        {
            GroupName = 'Public'
            FolderName = 'Software'
            ComputerName = 'FileServer2'
            ContentPath = 'e:\Data\Public\Software'
            StagingPathQuotaInMB = 4096
            PSDSCRunAsCredential = $Credential
            DependsOn = '[DFSReplicationGroupFolder]RGSoftwareFolder'
        } # End of RGPublicSoftwareFS2 Resource
    } # End of Node
} # End of Configuration
