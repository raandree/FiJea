function Get-FunctionDefaultParameter {
    <#
    .SYNOPSIS
    This is a function that will find all of the default parameter names and values from a given function.
    
    .EXAMPLE
    PS> Get-FunctionDefaultParameter -FunctionName Get-Something
    
    .PARAMETER FuntionName
    A mandatory string parameter representing the name of the function to find default parameters to.
    
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'FunctionName')]
        [ValidateNotNullOrEmpty()]
        [string]$FunctionName,

        [Parameter(Mandatory, ParameterSetName = 'Scriptblock')]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$Scriptblock
    )
    try {
        $ast = if ($FunctionName) {
            (Get-Command -Name $FunctionName).ScriptBlock.Ast
        }
        else {
            $Scriptblock.Ast
        }
        
        if (-not $ast) {
            return @{}
        }
        $select = @{ Name = 'Name'; Expression = { $_.Name.VariablePath.UserPath } },
        @{ Name = 'Value'; Expression = { $_.DefaultValue.Extent.Text -replace "`"|'" } }
        
        $ht = @{ }
        @($ast.FindAll( { $args[0] -is [System.Management.Automation.Language.ParameterAst] }, $true) | Where-Object { $_.DefaultValue } | Select-Object -Property $select).ForEach( {
                $ht[$_.Name] = $_.Value    
            })
        $ht
        
    }
    catch {
        Write-Error -Message $_.Exception.Message
    }
}

function Get-FunctionParameterSet {
    <#
            .SYNOPSIS
            This is a function that will find all of the default parameter names and values from a given function.
    
            .EXAMPLE
            PS> Get-FunctionDefaultParameter -FunctionName Get-Something
    
            .PARAMETER FuntionName
            A mandatory string parameter representing the name of the function to find default parameters to.
    
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'FunctionName')]
        [ValidateNotNullOrEmpty()]
        [string]$FunctionName,

        [Parameter(Mandatory, ParameterSetName = 'Scriptblock')]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$Scriptblock
    )
    try {
        $ast = if ($FunctionName) {
            (Get-Command -Name $FunctionName).ScriptBlock.Ast
        }
        else {
            $Scriptblock.Ast
        }
        
        if (-not $ast) {
            return @{}
        }
        $select = @{ Name = 'Name'; Expression = { $_.Name.VariablePath.UserPath } },
        @{ Name = 'Value'; Expression = { $_.DefaultValue.Extent.Text -replace "`"|'" } }
        
        $ht = @{ }
        $params = $ast.FindAll( { $args[0] -is [System.Management.Automation.Language.ParameterAst] }, $true)
            
        $params | ForEach-Object { ($_.Attributes.NamedArguments | Where-Object ArgumentName -eq 'ParameterSetName').Argument.Value } | Select-Object -Unique
    }
    catch {
        Write-Error -Message $_.Exception.Message
    }
}

function Get-JeaEndpointCapability {
    param(
        [Parameter(Mandatory)]
        [string]
        $ComputerName,

        [Parameter(Mandatory)]
        [string]
        $JeaEndpointName,

        [Parameter(Mandatory)]
        [string]
        $Username,

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
        ScriptBlock       = { Get-JeaPSSessionCapability -ConfigurationName $args[0] -Username $args[1] }
        ArgumentList      = $JeaEndpointName, $Username
    }
    if ($Credential) {
        $param.Add('Credential', $Credential)
    }

    Invoke-Command @param
}

function Get-JeaTestEndpointCapability {
    param(
        [Parameter(Mandatory)]
        [string]$JeaEndpointName
    )

    Get-Command -CommandType Cmdlet |
    Where-Object { $_.Parameters } |
    Get-Random -Count 10 |
    Select-Object -Property Name, Parameters, CommandType

}


Import-Module -Name Universal
$user = 'contoso\install'
$cred = New-Object pscredential($user, ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
#$cache:jeaServer = 'fiweb1'
$jeaServer = 'fiweb1'

New-UDDashboard -Title "JEA Task" -Content {

    if (-not $JeaEndpointName) {
        $JeaEndpointName = 'JeaDemo2'
    }
    if (-not $TaskName) {
        $TaskName = 'Set-xContent1'
    }
    $user = 'contoso\install'

    try {
        $task = Get-JeaEndpointCapability -ComputerName $jeaServer -JeaEndpointName $JeaEndpointName -Username $user -ErrorAction Stop | Where-Object Name -eq $TaskName
    }
    catch {
        Write-Error "Task '$TaskName' not found in Jea Endpoint '$JeaEndpointName'. Error message: '$($_.Exception.Message)'" -ErrorAction Stop
    }

    $parameterSets = Get-FunctionParameterSet -ScriptBlock ([scriptblock]::Create($task.ScriptBlock))

    New-UDCard -Content {
        @"
    TaskName        = $TaskName
    JeaEndpointName = $JeaEndpointName
"@
    }

    New-UDTabs -Tabs {
        foreach ($parameterSet in $parameterSets) {
            New-UDTab -Text $parameterSet -Content {
            }
        }
    }
}