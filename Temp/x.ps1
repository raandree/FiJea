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
    
    if (-not $script:psSession -or $script:psSession.State -ne 'Opened') {
        $param = @{
            ComputerName      = $ComputerName
            ConfigurationName = $DiscoveryEndpoint
        }
        if ($Credential) {
            $param.Add('Credential', $Credential)
        }

        $script:psSession = New-PSSession @param
    }
    
    Invoke-Command -Session $script:psSession -ScriptBlock { Get-JeaEndpoint }
}

function Get-JeaEndpointCapability {
    param(
        [Parameter(Mandatory)]
        [string]
        $JeaEndpointName,

        [Parameter(Mandatory)]
        [string]
        $Username
    )

    $script:tasks = Invoke-Command -Session $script:psSession -ScriptBlock {
        Get-JeaPSSessionCapability -ConfigurationName $args[0] -Username $args[1]
    } -ArgumentList $JeaEndpointName, $Username
    
    #Set-Item -Path Session:"tasks.$JeaEndpointName" -Value $tasks
}

Get-JeaEndpoint -ComputerName fiweb1
Get-JeaEndpointCapability -Username install -JeaEndpointName JeaDemo1