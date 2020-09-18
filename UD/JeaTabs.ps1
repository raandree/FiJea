New-UDDashboard -Title "JeaTabs" -Content {
    $user = 'contoso\install'
    $cred = New-Object pscredential($user, ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
    $session:jeaServer = 'fiweb1'
    # JEA MODE
    #$session:endpoints = Invoke-Command -ComputerName $session:jeaServer -ConfigurationName JeaDiscovery -ScriptBlock { Get-JeaEndpoint }
    # LOCAL DEV MODE
    $session:endpoints = @(
        [PSCustomObject]@{ Name = 'Local 1' },
        [PSCustomObject]@{ Name = 'Local 2' }
    )

    New-UDTypography -Text "Current process is $PID, current user is '$user'"
    
    New-UDTabs -Tabs {
        #Wait-Debugger
        foreach ($endpoint in $session:endpoints) {
            New-UDTab -Text $endpoint.Name -Content {
                 # JEA MODE
                #$session:tasks = Invoke-Command -ComputerName $session:jeaServer -ConfigurationName JeaDiscovery -ScriptBlock {
                #    Get-PSSessionCapability -ConfigurationName $args[0] -Username $args[1] | Select-Object -Property Name, Parameters, CommandType
                #} -ArgumentList $endpoint.Name, $user
                # LOCAL DEV MODE
                $session:tasks = Get-Command -Name Set-Content -CommandType Cmdlet | Where-Object { $_.Parameters } | Select-Object -First 550 -Property Name, Parameters, CommandType
                Start-Sleep -Seconds 5 #Retrieving the capabilities from the JEA endpoints can take some seconds

                New-UDDynamic -Id dyn1 -Content {
                    $columns = @(
                        New-UDTableColumn -Property Name -Title Name
                        New-UDTableColumn -Property Action -Render {
                            $item = $body | ConvertFrom-Json

                            $parameters = ($session:tasks | Where-Object Name -eq $item.Name).Parameters

                            New-UDButton -Id "btn$($item.Name)" -Text $item.Name -OnClick {

                                Show-UDToast -Id "$(Get-Random)" -Message $item.Name -Duration 2500
                                Show-UDToast -Id "$(Get-Random)" -Message $parameters.Count -Duration 2500

                                Show-UDModal -Content {
                                    New-UDForm -Content {
                                        $session:parameterElements = foreach ($p in $parameters.GetEnumerator()) {

                                            switch ([type]$p.value.parameterType) {
                                                { $_ -eq [string] } { New-UDTextbox -Id $p.Key -Type text -Label "$($p.Key) (string)" }
                                                { $_ -eq [string[]] } { New-UDTextbox -Id $p.Key -Type text -Label "$($p.Key) (string[])" }
                                                { $_ -eq [object] } { New-UDTextbox -Id $p.Key -Type text -Label "$($p.Key) (object)" }
                                                { $_ -eq [object[]] } { New-UDTextbox -Id $p.Key -Type text -Label "$($p.Key) (object[])" }
                                                { $_ -eq [switch] } { New-UDCheckBox -Id $p.Key -Label $p.Key }
                                                { $_ -eq [int] } { New-UDTextbox -Id $p.Key -Type text -Label "$($p.Key) (int)" }
                                            }  
                                        }

                                        $session:parameterElements

                                        New-UDElement -Tag p -Attributes @{'class' = 'right-align' } -Content {
                                            New-UDButton -Text "Close" -Icon (New-UDIcon -Icon stop) -OnClick { Hide-UDModal }
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
                                        & $item.Name @param
                                    }
                                }
                            }
                        }
                    )
                
                    New-UdTable -Data $session:tasks -Columns $columns -Id tbl -Sort -Filter -Search
                }
            } -Stacked -Id dyn1
        }
    } -RenderOnActive        
}
