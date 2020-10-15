New-UDDashboard -Title Test -Content {
    $users = Import-Csv -Path C:\People.csv -Delimiter ';'
    <#
    New-UDDynamic -Content {
        $DynamicData = @(
            @{Dessert = 'Frozen yoghurt'; Calories = (Get-Random); Fat = 6.0; Carbs = 24; Protein = 4.0 }
            @{Dessert = 'Ice cream sandwich'; Calories = (Get-Random); Fat = 6.0; Carbs = 24; Protein = 4.0 }
            @{Dessert = 'Eclair'; Calories = (Get-Random); Fat = 6.0; Carbs = 24; Protein = 4.0 }
            @{Dessert = 'Cupcake'; Calories = (Get-Random); Fat = 6.0; Carbs = 24; Protein = 4.0 }
            @{Dessert = 'Gingerbread'; Calories = (Get-Random); Fat = 6.0; Carbs = 24; Protein = 4.0 }
        )

        New-UDTable -Id 'dynamicTable' -Data $DynamicData
    } -AutoRefresh -AutoRefreshInterval 2

    New-UDDynamic -Id dyn1 -Content {
        $columns = @(
            New-UDTableColumn -Property Givenname -Title Givenname #-Sort -Filter
            New-UDTableColumn -Property Surname -Title Surname #-Sort -Filter
            New-UDTableColumn -Property Icon -Render {
                New-UDIcon -Icon bug 
            }
            New-UDTableColumn -Property Action -Render {
                $item = $body | ConvertFrom-Json
                New-UDButton -Id "$(Get-Random)" -Text $item.Surname -OnClick {
                    Show-UDToast -Id "$(Get-Random)" -Message $item.Surname
                    $u = $users | Where-Object Surname -eq $item.Surname
                    $u.Surname = 'xxx'
                    Sync-UDElement -Id dyn1
                }
            }
        )

        New-UdTable -Data $users -Columns $columns -Id tbl
    } -AutoRefresh
    #>

    New-UDTabs -Tabs {
        New-UDTab -Text "Tab 1" -Content {
            New-UDElement -Tag 'div' -Content { "Tab 1 Content $(Get-Date)"}
        } -Stacked -Dynamic
        New-UDTab -Text "Tab 2" -Content {
            New-UDElement -Tag 'div' -Content { "Tab 2 Content $(Get-Date)"}
        } -Stacked
        New-UDTab -Text "Tab 3" -Content {
            New-UDElement -Tag 'div' -Content {
                New-UDDynamic -Id dyn1 -Content {
                    $columns = @(
                        New-UDTableColumn -Property Givenname -Title Givenname #-Sort -Filter
                        New-UDTableColumn -Property Surname -Title Surname #-Sort -Filter
                        New-UDTableColumn -Property Icon -Render {
                            New-UDIcon -Icon bug 
                        }
                        New-UDTableColumn -Property Action -Render {
                            $item = $body | ConvertFrom-Json
                            New-UDButton -Id "$(Get-Random)" -Text $item.Surname -OnClick {
                                Show-UDToast -Id "$(Get-Random)" -Message $item.Surname
                                $u = $users | Where-Object Surname -eq $item.Surname
                                $u.Surname = 'xxx'
                                Sync-UDElement -Id dyn1
                            }
                        }
                    )
            
                    New-UdTable -Data $users -Columns $columns -Id tbl
                } #-AutoRefresh
            }
        } -Stacked -Id dyn1
    } -RenderOnActive
}
<#
return 
$Service = Get-Service
#Stop-UDDashboard -port 1001



$page0 = New-UDPage -name "Current" -Endpoint {

    New-UDCard -Content {
        New-UDParagraph -text "This was made by Maylife"
        New-UDParagraph -text "This one just works"
        New-UDParagraph -text 'Other pages contain my testing and other examples'
    }

    New-UdGrid -Title "Service" -PageSize 20 -AutoRefresh -RefreshInterval 60 -Id "Grid1" -Endpoint {
        Get-Service | select Name, DisplayName, Status | ForEach-Object {
            $button_name = $_.Name
            Switch ($_.Status) {
                'Stopped' { 
                    $button_text = "Start"
                    $button_colour = "Green"
                }
                'Running' { 
                    $button_text = "Stop"
                    $button_colour = "Red"
                }
                Default { 
                    $button_text = "ERROR"
                    $button_colour = "black"
                }
            }
            [PSCustomObject] @{
                "Name"         = $_.Name
                "Display Name" = $_.DisplayName
                "Status"       = Switch ($_.Status) {
                    'Stopped' { New-UDParagraph -Text $_ -Color red }
                    'Running' { New-UDParagraph -Text $_ -Color green }
                    Default { New-UDParagraph -Text $_ }
                }
                'Start/Stop'   = Switch ($_.Status) {
                    'Stopped' { 
                        New-UDButton -Text "Start" -BackgroundColor Green -OnClick (New-UDEndpoint -Endpoint {       
                                Start-Service $button_name;
                                Sync-UDElement -Id "Grid1"
                                Show-UDToast -Message "Started $button_name" -Duration 5000 -CloseOnClick
                            })
                    }
                    'Running' {
                        New-UDButton -Text "Stop" -BackgroundColor Red -OnClick (New-UDEndpoint -Endpoint {       
                                stop-Service $button_name;                      
                                Sync-UDElement -Id "Grid1"
                                Show-UDToast -Message "Stopped $button_name" -Duration 5000 -CloseOnClick
                            })
                    }
                    Default { 
                        New-UDButton -Text "ERROR" -BackgroundColor BLACK -OnClick (New-UDEndpoint -Endpoint {       
                                get-Service $button_name;
                                Sync-UDElement -Id "Grid1"            
                                Show-UDToast -Message "error $button_name" -Duration 5000 -CloseOnClick
                            })
                    }
                }
            }
        } | Out-UDGridData 
    }
}

$page1 = New-udpage  -name "Dympage" -Content {

New-UDCard -Content {
    New-UDParagraph -text "This was made by Maylife"
    New-UDParagraph -text "Its very buggy so I have moved away from cards"
    New-UDParagraph -text 'See $Page[0] and Page[4]'
    }

New-UDHeading -Text "Here is a list of Services Running on your computer" -Size 5
New-UDElement -Tag div -Id "Div1" -Endpoint {
New-UDLayout   -Columns 6 -Content {  
   
    ForEach ($S in $Service) {
        New-UDCard  -Content {
            New-UDParagraph -Text ('Name: '+ $S.name) 
            New-UDParagraph -Text ('DisplayName: ' + $S.DisplayName)
            
            Switch ((Get-Service ($S.name)).Status) {
                'Stopped' { New-UDParagraph -Text ('Status: ' + (Get-Service (($S).name)).Status) -Color red }
                'Running' { New-UDParagraph -Text ('Status: ' + (Get-Service (($S).name)).Status) -Color green }
                 Default  { New-UDParagraph -Text ('Status: ' + (Get-Service (($S).name)).Status) }
            }

            New-UDInput -Title "Stop-Service" -SubmitText 'Stop' -Endpoint {
                stop-Service $S.name
                New-UDInputAction -Toast (Get-Service $S.name).Status
                New-UDInputAction -Content {Sync-UDElement -Id "Div1"}
                sleep -Seconds 5
                New-UDInputAction -RedirectUrl "Dympage"
            }

            New-UDInput -Title "Start-Service" -SubmitText 'Start'  -Endpoint {
                Start-Service $S.name
                New-UDInputAction -Toast (Get-Service $S.name).Status
                New-UDInputAction -Content { Sync-UDElement -Id "Div1"}
                sleep -Seconds 5
                New-UDInputAction -RedirectUrl "Dympage"
                }
            } 
        }

        
    }
}
}

$page2 = New-UDPage -Name "Windows-Service-Dashboard" -Content  {

New-UDCard -Content {
    New-UDParagraph -text "This was made by cadayton"
    New-UDParagraph -text "URL of post https://forums.universaldashboard.io/t/refresh-content-in-new-udparagraph-after-a-new-udinput-event/1311/7"
    New-UDParagraph -text "Press the button, then press the refresh on the table"
    }

New-UDGrid -Title "Windows-Service-Report" -Endpoint {
$servicesDB = Get-Service;
[int]$psIdx = $servicesDB.Count - 1;
if ($psIdx -gt 0) {
  $PSreports = 0 .. $psIdx | ForEach-Object {
    [PSCustomObject] @{Status = 'data1'; Name = 'data2'; DisplayName = 'data3'; Action = 'data4';}
  }
} else {
  $PSreports = [PSCustomObject] @{Status = 'data1'; Name = 'data2'; DisplayName = 'data3'; Action = 'data4';}
}
$psIdx = 0;
$servicesDB | ForEach-Object {
    $PSreports[$psIdx].Name = $_.Name
    $PSreports[$psIdx].DisplayName = $_.DisplayName
    if ($_.Status -eq "Running") {
      $PSreports[$psIdx].Status = "Running";
      $PSreports[$psIdx].Action = New-UDButton -Text "Stop" -BackgroundColor Red -OnClick (New-UDEndpoint -Endpoint {
        Stop-Service $_.Name;
        New-UDElement -
        Show-UDToast -Message "Stopped $_.Name" -CloseOnClick
        
      })
    } else {
      $PSreports[$psIdx].Status = "Stopped";
      $PSreports[$psIdx].Action = New-UDButton -Text "Start" -BackgroundColor Green -OnClick (New-UDEndpoint -Endpoint {
        Start-Service $_.Name;
        
        Show-UDToast -Message "Started $_.Name" -CloseOnClick

        
      })
    }
    $psIdx++;
}

$PSreports  | Select-Object Status,Name,DisplayName,Action  | Out-UDGridData

  }
}

$Page3 = New-UDPage -name "Server Performance Dashboard"  -Content {

New-UDCard -Content {
    New-UDParagraph -text "This was made by Ironman Software LLC"
    New-UDParagraph -text "The URL for this is https://www.powershellgallery.com/packages/server-performance-dashboard/1.0/Content/server-performance-dashboard.ps1"
    New-UDParagraph -text 'I added a services and converted it to a $page'
    New-UDParagraph -text "I have left all of my test buttons on this page aswell"
    }

New-UdRow {
    New-UdColumn -Size 6 -Content {
        New-UdRow {
            New-UdColumn -Size 12 -Content {
                New-UdTable -Title "Server Information" -Headers @(" ", " ") -Endpoint {
                    @{
                        'Computer Name' = $env:COMPUTERNAME
                        'Operating System' = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
                        'Total Disk Space (C:)' = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'").Size / 1GB | ForEach-Object { "$([Math]::Round($_, 2)) GBs " }
                        'Free Disk Space (C:)' = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace / 1GB | ForEach-Object { "$([Math]::Round($_, 2)) GBs " }
                    }.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
                }
            }
        }
        New-UdRow {
            New-UdColumn -Size 3 -Content {
                New-UdChart -Title "Memory by Process" -Type Doughnut -RefreshInterval 30 -Endpoint {
                    Get-Process | ForEach-Object { [PSCustomObject]@{ Name = $_.Name; WorkingSet = [Math]::Round($_.WorkingSet / 1MB, 2) }} |  Out-UDChartData -DataProperty "WorkingSet" -LabelProperty Name
                } -Options @{
                    legend = @{
                        display = $false
                    }
                }
            }
            New-UdColumn -Size 3 -Content {
                New-UdChart -Title "CPU by Process" -Type Doughnut -RefreshInterval 30 -Endpoint {
                    Get-Process | ForEach-Object { [PSCustomObject]@{ Name = $_.Name; CPU = $_.CPU } } |  Out-UDChartData -DataProperty "CPU" -LabelProperty Name
                } -Options @{
                    legend = @{
                        display = $false
                    }
                }
            }
            New-UdColumn -Size 3 -Content {
                New-UdChart -Title "Handle Count by Process" -Type Doughnut -RefreshInterval 30 -Endpoint {
                    Get-Process | Out-UDChartData -DataProperty "HandleCount" -LabelProperty Name
                } -Options @{
                    legend = @{
                        display = $false
                    }
                }
            }
            New-UdColumn -Size 3 -Content {
                New-UdChart -Title "Threads by Process" -Type Doughnut -RefreshInterval 30 -Endpoint {
                    Get-Process | ForEach-Object { [PSCustomObject]@{ Name = $_.Name; Threads = $_.Threads.Count } } |  Out-UDChartData -DataProperty "Threads" -LabelProperty Name
                } -Options @{
                    legend = @{
                        display = $false
                    }
                }
            }
        }
        New-UdRow {
            New-UdColumn -Size 12 -Content {
                New-UdChart -Title "Disk Space by Drive" -Type Bar -AutoRefresh -Endpoint {
                    Get-CimInstance -ClassName Win32_LogicalDisk | ForEach-Object {
                            [PSCustomObject]@{ DeviceId = $_.DeviceID;
                                               Size = [Math]::Round($_.Size / 1GB, 2);
                                               FreeSpace = [Math]::Round($_.FreeSpace / 1GB, 2); } } | Out-UDChartData -LabelProperty "DeviceID" -Dataset @(
                        New-UdChartDataset -DataProperty "Size" -Label "Size" -BackgroundColor "#80962F23" -HoverBackgroundColor "#80962F23"
                        New-UdChartDataset -DataProperty "FreeSpace" -Label "Free Space" -BackgroundColor "#8014558C" -HoverBackgroundColor "#8014558C"
                    )
                }
            }
            New-UdColumn -Size 12 {
                New-UdGrid -Title "Processes" -Headers @("Name", "ID", "Working Set", "CPU") -Properties @("Name", "Id", "WorkingSet", "CPU") -AutoRefresh -RefreshInterval 60 -Endpoint {
                    Get-Process |Select-Object "Name","ID","WorkingSet","CPU" | Out-UDGridData
                }
            }
        }
    }
    New-UdColumn -Size 6 -Content {
        New-UdRow {
            New-UdColumn -Size 6 -Content {
                New-UdMonitor -Title "CPU (% processor time)" -Type Line -DataPointHistory 20 -RefreshInterval 30 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
                    try {
                        Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
                    }
                    catch {
                        0 | Out-UDMonitorData
                    }
                }
            }
            New-UdColumn -Size 6 -Content {
                New-UdMonitor -Title "Memory (% in use)" -Type Line -DataPointHistory 20 -RefreshInterval 30 -ChartBackgroundColor '#8028E842' -ChartBorderColor '#FF28E842'  -Endpoint {
                    try {
                        Get-Counter '\memory\% committed bytes in use' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
                    }
                    catch {
                        0 | Out-UDMonitorData
                    }
                }
            }
        }
        New-UdRow {
            New-UdColumn -Size 6 -Content {
                New-UdMonitor -Title "Network (IO Read Bytes/sec)" -Type Line -DataPointHistory 20 -RefreshInterval 30 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D'  -Endpoint {
                    try {
                        Get-Counter '\Process(_Total)\IO Read Bytes/sec' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
                    }
                    catch {
                        0 | Out-UDMonitorData
                    }
                }
            }
            New-UdColumn -Size 6 -Content {
                New-UdMonitor -Title "Disk (% disk time)" -Type Line -DataPointHistory 20 -RefreshInterval 30 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D'  -Endpoint {
                    try {
                        Get-Counter '\physicaldisk(_total)\% disk time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
                    }
                    catch {
                        0 | Out-UDMonitorData
                    }
                }
            }
        }
        New-UdColumn -Size 12 {
            New-UdGrid -Title "Service" -PageSize 20 -AutoRefresh  -RefreshInterval 60 -Endpoint {
                Get-Service | select Name, DisplayName, Status | ForEach-Object {
                    $button_text = "ERROR"
                    $button_colour = "Black"
                    $button_name = $_.Name
                   
                    Switch ($_.Status) {
                        'Stopped' { 
                            $button_text = "Start"
                            $button_colour = "Green"
                        }
                        'Running' { 
                            $button_text = "Stop"
                            $button_colour = "Red"
                        }
                        Default { 
                            $button_text = "ERROR"
                            $button_colour = "black"
                        }
                    }
                    [PSCustomObject] @{
                        "Name" = $_.Name
                        "Display Name" = $_.DisplayName
                        "Status" = [string]$_.Status
                        "Status2" = Switch ($_.Status) {
                            'Stopped' { New-UDParagraph -Text $_ -Color red }
                            'Running' { New-UDParagraph -Text $_ -Color green }
                             Default  { New-UDParagraph -Text $_ }
                        }
                        "Status3" = Switch ($_.Status) {
                            'Stopped' { 
                                New-UDButton -Text "Start" -BackgroundColor Green -OnClick (New-UDEndpoint -Endpoint {       
                                    Start-Service $button_name;            
                                    Show-UDToast -Message "Started $button_name" -CloseOnClick
                                  })
                              }
                            'Running' {
                                 New-UDButton -Text "Stop" -BackgroundColor Red -OnClick (New-UDEndpoint -Endpoint {       
                                    stop-Service $button_name;            
                                    Show-UDToast -Message "stopped $button_name" -CloseOnClick
                                  })
                              }
                             Default  { 
                                New-UDButton -Text "ERROR" -BackgroundColor BLACK -OnClick (New-UDEndpoint -Endpoint {       
                                    get-Service $button_name;            
                                    Show-UDToast -Message "error $button_name" -CloseOnClick
                                  })
                              }
                        }
                        "Status4" = New-UDButton -Text $button_text -BackgroundColor $button_colour -OnClick (New-UDEndpoint -Endpoint {
                            Switch ($_.Status) {
                                'Stopped' { Start-Service $button_name
                                    Show-UDToast -Message "Started $button_name" -CloseOnClick
                                 }
                                'Running' { Stop-Service $button_name 
                                    Show-UDToast -Message "stopped $button_name" -CloseOnClick
                                 }
                                 Default  { Get-Service $button_name }
                            }
                        })
                    }
                } | Out-UDGridData 
            }
        }
    }
}
} 




$Navigation = New-UDSideNav -Content {
New-UDSideNavItem -Text "Current" -PageName "$($page0.name)" -Icon car
New-UDSideNavItem -Text "Dympage" -PageName "$($page1.name)" -Icon house_damage
New-UDSideNavItem -Text "Windows-Service-Dashboard" -PageName "$($page2.name)" -Icon _try
New-UDSideNavItem -Text "Server Performance Dashboard" -PageName "$($page3.name)" -Icon address_book
New-UDSideNavItem -Text "Google" -Url 'https://www.google.com.au' -Icon google
}

New-UDDashboard -Pages @($page0) #,$Page1,$page2,$page3) #-Navigation $Navigation

return
New-UDDashboard -Title "Dashboard" -Pages @(
    New-UDPage -Name ListTest -Content {
        New-UDForm -Content {

            New-UDTextbox -Value 123 -Id 123

            New-UDList -Content {
                New-UDListItem -Label 'Inbox' -Icon (New-UDIcon -Icon envelope -Size 3x) -SubTitle 'New Stuff'
                New-UDListItem -Label 'Drafts' -Icon (New-UDIcon -Icon edit -Size 3x) -SubTitle "Stuff I'm working on "
                New-UDListItem -Label 'Trash' -Icon (New-UDIcon -Icon trash -Size 3x) -SubTitle 'Stuff I deleted'
                New-UDListItem -Label 'Spam' -Icon (New-UDIcon -Icon bug -Size 3x) -SubTitle "Stuff I didn't want" -OnClick {
                    $e = Get-UDElement -Id 123
                    $e.Value = 456
                    $e | Set-UDElement -Properties @{ Value = 456 }
                    Sync-UDElement -Id 123
                }
            }
        } -OnSubmit { }   
    }
    <#
    New-UDPage -Name 'AppBar' -Content {

        $Drawer = New-UDDrawer -Id 'drawer' -Children {
            New-UDList -Content {
                New-UDListItem -Id 'lstHome' -Label 'Home' -OnClick { 
                    Set-TestData 'Home'
                 } -Content {
                     New-UDListItem -Id 'lstNested' -Label 'Nested' -OnClick {
                        Set-TestData 'Nested'
                     }
                 } 
            }
        }

        New-UDElement -Tag 'main' -Content {
            New-UDAppBar -Content { New-UDTypography -Text 'Hello' -Paragraph } -Position relative -Drawer $Drawer
        }
    }

    New-UDPage -Name 'Home' -Content {
        $Drawer = New-UDDrawer -Children {
            New-UDList -Children {
                New-UDListItem -Label "Home"
                New-UDListItem -Label "Getting Started" -Children {
                    New-UDListItem -Label "Installation" -OnClick {}
                    New-UDListItem -Label "Usage" -OnClick {}
                    New-UDListItem -Label "FAQs" -OnClick {}
                    New-UDListItem -Label "System Requirements" -OnClick {}
                    New-UDListItem -Label "Purchasing" -OnClick {}
                }
            }
        }
    
        New-UDAppBar -Position relative -Children { New-UDElement -Tag 'div' -Content { "Title" } } -Drawer $Drawer
        
        New-UDTextbox -Id 'txtTextfield' -Label 'test' 
    }
   
) 


return
New-UDDashboard -Title "Hello, World!" -Content {
    New-UDTypography -Text "Hello, World!"

    New-UDForm -Content {
        New-UDSelect -Id 'seTask' -Label 'Task' -Option { 
            New-UDSelectOption -Name 1 -Value 1
            New-UDSelectOption -Name 2 -Value 2
        } -OnChange {
            Show-UDToast $body
        }
    } -OnSubmit {

    }
}

 #> 