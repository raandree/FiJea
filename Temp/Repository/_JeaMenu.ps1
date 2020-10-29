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
    
    $param = @{
        ComputerName      = $ComputerName
        ConfigurationName = $DiscoveryEndpoint
        ScriptBlock       = { Get-JeaEndpoint }
    }
    if ($Credential) {
        $param.Add('Credential', $Credential)
    }

    Invoke-Command @param 
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
        New-UDTypography -Text "Endpoint name: $jeaEndpointName, PID: $PID"
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

            New-UDButton -Id "btn$JeaEndpointName_$($item.Name)" -Text $item.Name -OnClick {
                $item = $body | ConvertFrom-Json
                Invoke-UDRedirect -Url "http://fiweb1:5000/_JeaTask/Home?JeaEndpointName=$jeaEndpointName&TaskName=$($item.Name)"
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

        $user = 'contoso\install'
        $tasks = Get-JeaEndpointCapability -JeaEndpointName $jeaEndpointName -Username $user -ComputerName $cache:jeaServer
        Set-Item -Path Session:"tasks.$JeaEndpointName" -Value $tasks

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
