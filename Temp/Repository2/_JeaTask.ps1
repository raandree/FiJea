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

function New-xTaskForm {
    param(
        [Parameter(Mandatory)]
        [string]$ParameterSetName
    )

    $parameters = Get-FunctionParameter -ScriptBlock ([scriptblock]::Create($task.ScriptBlock)) -ParameterSetName $ParameterSetName
    $parameterDefaultValues = Get-FunctionDefaultParameter -Scriptblock ([scriptblock]::Create($item.ScriptBlock))
    $session:parameterSetName = $ParameterSetName
    $session:currentTask = $task

    New-UDDynamic -Id "dyn_$($session:parameterSetName)" -Content {
        New-UDForm -Content {
            if ($Session:formProcessing) {
                New-Progress -Text 'Submitting form...'
            }
            else {
                $alParameters = New-Object System.Collections.ArrayList
                $alParameters.AddRange(@($parameters))
                foreach ($p in $alParameters) {
                    #Wait-Debugger
                    $newElement = if ($p.Value.Name -eq 'FilePath' -and $ParameterSetName -eq 'FileUpload') {
                        New-UDUpload -Text 'File Upload' -OnUpload {
                            $Data = $Body | ConvertFrom-Json
                            $bytes = [System.Convert]::FromBase64String($Data.Data)
                            mkdir -Path "C:\Temp\$($session:currentTask.Name)" -Force
                            [System.IO.File]::WriteAllBytes("C:\Temp\$($session:currentTask.Name)\$($Data.Name)", $bytes)
                        } -Id "udElement_FilePath"
                    }
                    elseif ($p.Value.ParameterType.Name -eq 'SwitchParameter') { 
                        New-UDCheckBox -Id "udElement_$($p.Key)" -Label $p.Key
                    }
                    elseif ($p.Value.ParameterType.Name -eq 'PSCredential') {
                        $udTextboxParam = @{
                            Id    = "udElement_$($p.Key)_username"
                            Label = "$($p.Key) ($($p.value.parameterType.Name)) Username"
                            Type  = 'text'
                        }

                        if ($parameterDefaultValues.ContainsKey($p.Key)) {
                            $udTextboxParam.Value = $parameterDefaultValues[$p.Key]
                        }

                        New-UDTextbox @udTextboxParam

                        #-------------------------------------------------------------

                        $udTextboxParam = @{
                            Id    = "udElement_$($p.Key)_password"
                            Label = "$($p.Key) ($($p.value.parameterType.Name)) Password"
                            Type  = 'password'
                        }

                        if ($parameterDefaultValues.ContainsKey($p.Key)) {
                            $udTextboxParam.Value = $parameterDefaultValues[$p.Key]
                        }

                        New-UDTextbox @udTextboxParam
                    }
                    else {
                        $udTextboxParam = @{
                            Id    = "udElement_$($p.Key)"
                            Label = "$($p.Key) ($($p.value.parameterType.Name))"
                            Type  = 'text'
                        }

                        if ($p.value.parameterType.Name -eq 'SecureString') {
                            $udTextboxParam.Type = 'password'
                        }

                        if ($parameterDefaultValues.ContainsKey($p.Key)) {
                            $udTextboxParam.Value = $parameterDefaultValues[$p.Key]
                        }

                        New-UDTextbox @udTextboxParam
                    }

                    $newElement | Add-Member -Name ParameterSetName -Value $ParameterSetName -Type NoteProperty -PassThru
                    $session:parameterElements.Add($newElement)
                }
            }
        
        } -OnSubmit {
            $Session:formProcessing = $true
            $currentParameterSetName = ($EventId -split '_')[1]
            Sync-UDElement -Id "dyn_$currentParameterSetName"

            $alParameterElements = New-Object System.Collections.ArrayList
            $alParameterElements.AddRange(@($session:parameterElements))

            $param = @{}
            #Wait-Debugger
            foreach ($parameterElement in ($session:parameterElements | Where-Object ParameterSetName -eq $currentParameterSetName)) {

                $getUDElementRetryCount = 3
                $parameterElementId = $parameterElement.id
                $parameterElement = $null
                while (-not $parameterElement -and $getUDElementRetryCount -gt 0) {
                    $parameterElement = Get-UDElement -Id $parameterElementId
                    $getUDElementRetryCount--
                    Start-Sleep -Milliseconds 100
                }
                $parameterName = $parameterElement.id -replace 'udElement_', ''
                #Wait-Debugger
                switch ($parameterElement) {

                    { $_.type -eq 'mu-textbox' } {
                        if ($_.value) { 
                            if ($_.textType -eq 'password') {
                                $param.Add($parameterName, ($_.value | ConvertTo-SecureString -AsPlainText -Force))
                            }
                            else {
                                $param.Add($parameterName, $_.value)
                            }
                        }
                    }
                    { $_.type -eq 'mu-checkbox' } {
                        if ($_.checked) {
                            $param.Add($parameterName, $_.checked)
                        }
                    }
                    { $_.type -eq 'mu-upload' } {
                        #Wait-Debugger
                        if ($_.value) {
                            $param.Add($parameterName, "C:\Temp\$($session:currentTask.Name)\$($_.value.name)")
                        }
                    }
                }
            }

            #Wait-Debugger
            $param | Export-Clixml -Path c:\param.xml
        
            $adminSession = New-PSSession -ComputerName $cache:jeaServer -ConfigurationName $session:jeaEndpointName

            Import-PSSession -Session $adminSession | Out-Null
        
            $result = try {
                & $session:taskName @param -ErrorAction Stop
            }
            catch {
                $errorOccured = $true
                $_.Exception.Message
            }

            $Session:formProcessing = $false 
            Sync-UDElement -Id "dyn_$($session:parameterSetName)"

            if ($result) {
                if ($errorOccured) {
                    Show-UDModal -Content {
                        New-UDTypography -Text 'An error occured:' -Variant h5
                        New-UDTypography -Text $result -Variant h5
                    }
                }
                else {
                    Show-UDModal -Content {
                        #Wait-Debugger
                        New-UDTypography -Text 'The result is:' -Variant h5
                        New-UDTypography -Text $result -Variant h5
                    } -FullWidth
                }
            }
        } -Id "form_$ParameterSetName"
    }
}

Import-Module -Name Universal
$user = 'contoso\install'
$cred = New-Object pscredential($user, ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
$cache:jeaServer = 'fiweb1'
$jeaServer = 'fiweb1'

New-UDDashboard -Title "JEA Task" -Content {

    if (-not $JeaEndpointName) {
        $JeaEndpointName = 'JeaDemo2'
    }
    if (-not $TaskName) {
        $TaskName = 'Set-xContent1'
    }

    $user = 'contoso\install'
    $session:jeaEndpointName = $JeaEndpointName
    $session:taskName = $TaskName
    $session:parameterElements = New-Object System.Collections.ArrayList

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
            
            New-UDTab -Id "tab_$parameterSet" -Text $parameterSet -Content {                
                Invoke-Expression "New-xTaskForm -ParameterSetName $parameterSet"
            }

        }
    } -RenderOnActive
}