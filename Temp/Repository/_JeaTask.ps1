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