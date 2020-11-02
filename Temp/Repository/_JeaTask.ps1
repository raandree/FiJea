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

function New-xTaskForm {
    param(
        [Parameter(Mandatory)]
        [string]$ParameterSetName
    )

    $parameters = Get-FunctionParameter -ScriptBlock ([scriptblock]::Create($task.ScriptBlock)) -ParameterSetName $ParameterSetName
    $parameterDefaultValues = Get-FunctionDefaultParameter -Scriptblock ([scriptblock]::Create($item.ScriptBlock))
    $session:parameterSetName = $ParameterSetName

    New-UDDynamic -Id "dyn_$($session:parameterSetName)" -Content {
        New-UDForm -Content {
            if ($Session:formProcessing) {
                New-Progress -Text 'Submitting form...'
            }
            else {
                $alParameters = New-Object System.Collections.ArrayList
                $alParameters.AddRange(@($parameters))
                $session:parameterElements = foreach ($p in $alParameters) {

                    if ($p.value.parameterType -eq 'System.Management.Automation.SwitchParameter') { 
                        New-UDCheckBox -Id "udElement_$($p.Key)" -Label $p.Key
                    }
                    else {
                        $udTextboxParam = @{
                            Id    = "udElement_$($p.Key)"
                            Label = "$($p.Key) ($($p.value.parameterType.Name))"
                            Type  = 'text'
                        }

                        if ($p.value.parameterType -eq 'System.Security.SecureString') {
                            $udTextboxParam.Type = 'password'
                        }

                        if ($parameterDefaultValues.ContainsKey($p.Key)) {
                            $udTextboxParam.Value = $parameterDefaultValues[$p.Key]
                        }
                    }

                    New-UDTextbox @udTextboxParam 
                }

                $session:parameterElements

            }
        
        } -OnSubmit {
            $Session:formProcessing = $true 
            Sync-UDElement -Id "dyn_$($session:parameterSetName)"

            $alParameterElements = New-Object System.Collections.ArrayList
            $alParameterElements.AddRange(@($session:parameterElements))

            $param = @{}

            foreach ($parameterElement in $alParameterElements) {

                $getUDElementRetryCount = 3
                $parameterElementId = $parameterElement.id
                $parameterElement = $null
                while (-not $parameterElement -and $getUDElementRetryCount -gt 0) {
                    $parameterElement = Get-UDElement -Id $parameterElementId
                    $getUDElementRetryCount--
                    Start-Sleep -Milliseconds 100
                }
                $parameterName = $parameterElement.id -replace 'udElement_', ''

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
                }
            }

            $param | Export-Clixml -Path c:\param.xml
        
            $adminSession = New-PSSession -ComputerName $cache:jeaServer -ConfigurationName $session:jeaEndpointName

            Import-PSSession -Session $adminSession
        
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
                        New-UDTypography -Text 'The result is:' -Variant h5
                        New-UDTypography -Text $result -Variant h5
                    }
                }
            }
        }
    }
}

New-UDDashboard -Title "JEA Task" -Content {
    
    $user = 'contoso\install'
    $cred = New-Object pscredential($user, ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
    $cache:jeaServer = 'fiweb1'

    #if (-not $JeaEndpointName) {
    #    $JeaEndpointName = 'JeaDemo2'
    #}
    #if (-not $TaskName) {
    #    $TaskName = 'Get-ParamSetTest'
    #}

    $session:taskName = $TaskName
    $session:jeaEndpointName = $JeaEndpointName

    try {
        $task = Get-JeaEndpointCapability -ComputerName $cache:jeaServer -JeaEndpointName $session:jeaEndpointName -Username $user -ErrorAction Stop | Where-Object Name -eq $session:taskName
    }
    catch {
        Write-Error "Task '$($session:taskName)' not found in Jea Endpoint '$($session:jeaEndpointName)'. Error message: '$($_.Exception.Message)'" -ErrorAction Stop
    }

    $parameterSets = Get-FunctionParameterSet -ScriptBlock ([scriptblock]::Create($task.ScriptBlock)) #| Select-Object -First 1
    if (-not $parameterSets) {
        $parameterSets = 'Default', 'Dummy'
    }

    New-UDCard -Content {
        @"
    TaskName        = $session:taskName
    JeaEndpointName = $session:jeaEndpointName
"@
    }

    $PID | Out-File c:\pid.txt
    New-UDTabs -Id ParameterSetTabs -Tabs {
        foreach ($parameterSet in $parameterSets) {

            New-UDTab -Id "tab_$parameterSet" -Text $parameterSet -Content {                
                Invoke-Expression "New-xTaskForm -ParameterSetName $parameterSet"
            }
        }
    } -RenderOnActive

}
