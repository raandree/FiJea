function Get-FunctionParameterSets {
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
            
        $params | ForEach-Object { ($_.Attributes.NamedArguments | Where-Object ArgumentName -eq 'ParameterSetName').Argument.Value }
    }
    catch {
        Write-Error -Message $_.Exception.Message
    }
}

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

    $tasks = Invoke-Command @param

    if (Get-PSDrive -Name Session -ErrorAction SilentlyContinue) {
        Set-Item -Path Session:"tasks.$JeaEndpointName" -Value $tasks
    }
    else {
        $tasks
    }
}

Remove-Module tmp_*

$tasks = Get-JeaEndpointCapability -ComputerName localhost -JeaEndpointName JeaDemo2 -Username install

$s = New-PSSession localhost -ConfigurationName jeademo2
Import-PSSession -Session $s

$commandName = 'Set-xContent1'

$task = $tasks | Where-Object Name -eq $commandName
$parameters = $task.Parameters
$sb = [scriptblock]::Create($task.ScriptBlock)
$parameterDefaultValues = Get-FunctionDefaultParameter -Scriptblock $sb
$parameterSets = $parameterDefaultValues = Get-FunctionParameterSets -Scriptblock $sb

