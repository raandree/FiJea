function Invoke-Ternary {
    param
    (
        [Parameter(Mandatory)]
        [scriptblock]
        $Decider,

        [Parameter(Mandatory)]
        [scriptblock]
        $IfTrue,

        [Parameter(Mandatory)]
        [scriptblock]
        $IfFalse
    )

    if (&$Decider) {
        &$IfTrue
    }
    else {
        &$IfFalse
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

function New-Progress {
    param(
        [string]$Text
    )

    New-UDElement -tag 'div' -Attributes @{ style = @{ padding = "20px"; textAlign = 'center' } } -Content {
        New-UDRow -Columns {
            New-UDColumn -Content {
                New-UDTypography -Text $Text -Variant h4
            }
        }
        New-UDRow -Columns {
            New-UDColumn -Content {
                New-UDProgress -Circular 
            }
        }
    }
}

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
    
    if (-not $cache:psSession -or $cache:psSession.State -ne 'Opened') {
        $param = @{
            ComputerName      = $ComputerName
            ConfigurationName = $DiscoveryEndpoint
        }
        if ($Credential) {
            $param.Add('Credential', $Credential)
        }

        $cache:psSession = New-PSSession @param
    }
    
    Invoke-Command -Session $cache:psSession -ScriptBlock { Get-JeaEndpoint }
}

function Get-JeaTestEndpoint {
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
    
    1..4 | ForEach-Object {
        [PSCustomObject]@{ 
            Name           = "Local$_"
            PSComputerName = $ComputerName
            PSVersion      = 5.1
            Permission     = 'contoso\Domain Users AccessAllowed, contoso\Domain Computers AccessAllowed'
        }
    }
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

    $tasks = Invoke-Command -Session $session:psSession -ScriptBlock {
        Get-JeaPSSessionCapability -ConfigurationName $args[0] -Username $args[1]
    } -ArgumentList $jeaEndpoint, $Username
    
    Set-Item -Path Session:"tasks.$JeaEndpointName" -Value $tasks
}

function Get-JeaTestEndpointCapability {
    param(
        [Parameter(Mandatory)]
        [string]
        $JeaEndpointName,

        [Parameter(Mandatory)]
        [pscredential]
        $Username
    )

    $tasks = Get-Command -CommandType Cmdlet |
    Where-Object { $_.Parameters } |
    Get-Random -Count 10 |
    Select-Object -Property Name, Parameters, CommandType

    Set-Item -Path Session:"tasks.$JeaEndpointName" -Value $tasks
}

function New-xPage {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [scriptblock]$OnLoad,

        [Parameter(Mandatory)]
        [scriptblock]$Finished,

        [ValidateSet('Session', 'Cache')]
        [string]$Store = 'Session'
    )

    $onLoadText = $OnLoad.ToString()
    if (-not ($onLoadText -match 'Sync-UDElement -Id (?<Id>\w+)')) {
        Write-Error "No ID for 'New-UDDynamic' found."
        return
    }
    else {
        Write-Host "ID for 'New-UDDynamic' is $($Matches.Id)"
        $id = $Matches.Id
    }
    $isloaded = "`${$($Store):$($id)_loaded}"
    New-UDPage -Name $Name -Content {
        New-UDTypography -Text "Endpoint name: $jeaEndpointName"
        New-UDDynamic -Id $id -Content {

            Invoke-Ternary -Decider ([scriptblock]::Create($isloaded)) -IfTrue {
                New-xTable -JeaEndpointName $jeaEndpointName
            } -IfFalse {
                New-xWait -JeaEndpointName $jeaEndpointName
            }

        }
    }
}

function New-xTable {
    param(
        [Parameter(Mandatory)]
        [string]$JeaEndpointName
    )

    $columns = @(
        New-UDTableColumn -Property Name -Title Name
        New-UDTableColumn -Property Action -Render {
            $item = $body | ConvertFrom-Json

            $parameters = ($session:tasks.$JeaEndpointName | Where-Object Name -eq $item.Name).Parameters
            $parameterDefaultValues = Get-FunctionDefaultParameter -Scriptblock ([scriptblock]::Create($item.ScriptBlock))

            New-UDButton -Id "btn$JeaEndpointName" -Text $item.Name -OnClick {
                Invoke-UDRedirect -Url "http://fiweb1:5000/RequestTest/Home?JeaEndpointName=$jeaEndpointName"
            }
        }
    )

    $data = Get-Item -Path Session:"tasks.$JeaEndpointName"
    New-UdTable -Data $data -Columns $columns -Id "tbl$($jeaEndpoint.Name)" -Sort -Filter -Search
}

function New-xWait {
    param(
        [Parameter(Mandatory)]
        [string]$JeaEndpointName
    )

    New-Progress -Text 'Loading Session data...'
    New-UDElement -Tag div -Endpoint {
        Set-Item -Path Session:"Dyn_$($JeaEndpointName)_loaded" -Value $true
        Set-Item -Path Session:"SessionData$($jeaEndpointName)" = Get-Random
        Get-JeaEndpointCapability -JeaEndpointName $jeaEndpointName -Username $user
        Sync-UDElement -Id "Dyn_$JeaEndpointName"
    }
}

Import-Module -Name Universal
$user = 'contoso\install'
$cred = New-Object pscredential($user, ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
$cache:jeaServer = 'fiweb1'

$cache:jeaEndpoints = Get-JeaEndpoint -ComputerName $cache:jeaServer

#$session:tasks."$($jeaEndpoint.Name)" = Invoke-Command -Session $session:psSession -ScriptBlock {
#    Get-JeaPSSessionCapability -ConfigurationName $args[0] -Username $args[1]
#} -ArgumentList $jeaEndpoint.Name, $user #| Where-Object Name -like *-x*
# LOCAL DEV MODE
#$session:tasks."$($jeaEndpoint.Name)" = Get-Command -Name Set-Content, Start-Sleep -CommandType Cmdlet | Where-Object { $_.Parameters } | Select-Object -First 550 -Property Name, Parameters, CommandType
#Start-Sleep -Seconds 5 #Retrieving the capabilities from the JEA endpoints can take some seconds

$pages = foreach ($jeaEndpoint in $Cache:jeaEndpoints) {
    $jeaEndpointName = $jeaEndpoint.Name
    $onLoad = @"
New-Progress -Text 'Loading Session data...'
New-UDElement -Tag 'div' -Endpoint {
    Start-Sleep 2
    `$Session:Dyn_$($jeaEndpoint.Name)_loaded = `$true
    `$Session:SessionData$jeaEndpointName = Get-Random
    Sync-UDElement -Id Dyn_$($jeaEndpoint.Name)
}
"@

    $finished = @"
New-UDCard -Title "Page $jeaEndpointName" -Id "PageCard"
`$data = `$Session:SessionData$jeaEndpointName
New-UDTypography -Text "Some random text '`$data'"
"@

    $page = New-xPage -Name "$jeaEndpointName$PID" -OnLoad ([scriptblock]::Create($onLoad)) -Finished ([scriptblock]::Create($finished)) -Store Session
    $page
}

New-UDDashboard -Pages $pages -Title New
