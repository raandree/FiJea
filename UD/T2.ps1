function F1 {
    param (
        [string]$P1,
        [int]$P2,
        [switch]$P3
    )

    $PSBoundParameters | Export-Clixml C:\x.xml
    Get-Variable | Export-Clixml c:\v.xml
    whoami.exe | Export-Clixml C:\whoami.xml
    [System.Security.Principal.WindowsIdentity]::GetCurrent() | Export-Clixml C:\WindowsIdentity.xml
}

function F2 {
    param (
        [string]$P1,
        [int]$P2
    )

    $PSBoundParameters
}

New-UDDashboard -Title "Test" -Content {
    $xxuser = 'contoso\install'
    $cred = New-Object pscredential($xxuser, ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
    New-UDTypography -Text "Current process is $PID, current user is '$xxuser'"
    $session:jeaServer = 'fiweb1'
    $session:endpoints = Invoke-Command -ComputerName $session:jeaServer -ConfigurationName JeaDiscovery -ScriptBlock { Get-JeaEndpoint }

    $functions = Get-Command -Name f? -CommandType Function

    New-UDForm -Content {
        New-UDSelect -Id 'seFunction' -Label 'Function' -Option {
            foreach ($f in $functions) {
                New-UDSelectOption -Name $f.Name -Value $f.Name
            }
        } -OnChange {
            Sync-UDElement -Id 'dyParameters'
        }

        New-UDDynamic -Id 'dyParameters' -Content {

            $session:functionName = (Get-UDElement -Id 'seFunction').value
            $f = Get-Command -Name $session:functionName -CommandType Function

            $session:parameterElements = foreach ($p in $f.Parameters.GetEnumerator()) {
                switch ($p.Value.ParameterType) {
                    { $_ -eq [string] } { New-UDTextbox -Id $p.Key -Type text -Label $p.Key }
                    { $_ -eq [switch] } { New-UDCheckBox -Id $p.Key -Label $p.Key }
                    { $_ -eq [int] } { New-UDTextbox -Id $p.Key -Type text -Label $p.Key }
                    
                }  
            }
            
            $session:parameterElements
        }
    } -OnSubmit {
        $param = @{}

        foreach ($parameterElement in $session:parameterElements) {
            $parameterElement = Get-UDElement -Id $parameterElement.id

            switch ($parameterElement) {

                { $_.type -eq 'mu-textbox' } {
                    if ($_.value) { 
                        $param.Add($parameterElement.id, $_.value)
                    }
                }
                { $_.type -eq 'mu-checkbox' } {
                    if ($_.checked) {
                        $param.Add($parameterElement.id, $_.checked)
                    }
                }
            }
        }

        $param | Export-Clixml -Path c:\param.xml

        & $session:functionName @param
    }

    New-UDForm -Content {
        
        New-UDSelect -Id 'seEndpoint' -Label 'Endpoint' -Option {
            Show-UDToast $session:endpoints.count
            foreach ($endpoint in $session:endpoints) {
                New-UDSelectOption -Name $endpoint.Name -Value $endpoint.Name
            }
        } -OnChange {
            Sync-UDElement -Id 'dyTask'
        }

        New-UDDynamic -Id 'dyTask' -Content {

            $session:endpointName = (Get-UDElement -Id 'seEndpoint').value
            $session:tasks = Invoke-Command -ComputerName $session:jeaServer -ConfigurationName JeaDiscovery -ScriptBlock {
                Get-PSSessionCapability -ConfigurationName $args[0] -Username $args[1] } -ArgumentList $session:endpointName, $xxuser
            
            New-UDSelect -Id 'seTask' -Label 'Task' -Option {
                if ($session:tasks.Count) {
                    foreach ($task in $session:tasks) {
                        New-UDSelectOption -Name $task.Name -Value $task.Name
                    }
                }
                else {
                    New-UDSelectOption -Name 'Could not retreive tasks' -Value CouldNotRetreiveTasks
                }
            } -OnChange {
                Sync-UDElement -Id 'dyTask'
            }
        }
        
    } -OnSubmit {
        Show-UDToast -Message $Body

        Show-UDModal -Content {

            New-UDCard -Id "Card" -Title "Results"
     
            New-UDElement -Tag 'pa' -Attributes @{'class' = 'left-align' } -Content {
            
                New-UDButton -Text "Restore" -Icon (New-UDIcon -Icon play) -OnClick { Hide-UDModal }
            }
            New-UDElement -Tag 'p' -Attributes @{'class' = 'right-align' } -Content {
             
                New-UDButton -Text "Close" -Icon (New-UDIcon -Icon stop) -OnClick { Hide-UDModal }
            }
        } 
    }
}
