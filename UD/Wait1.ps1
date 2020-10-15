function New-Progress {
    param(
        $Text
    )

    New-UDElement -tag 'div' -Attributes @{ style = @{ padding = "20px"; textAlign = 'center'} } -Content {
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

$pages = @()

$pages += New-UDPage -Name 'Session' -Content {
    New-UDDynamic -Id 'content' -Content {
        if ($Session:SessionPageLoaded)
        {
            New-UDTypography -Text "Some random text $($Session:SessionData)"
        }
        else 
        {
            New-Progress -Text 'Loading session data...'
            
            New-UDElement -Tag 'div' -Endpoint {
                Start-Sleep 5
                $Session:SessionPageLoaded = $true
                $Session:SessionData = Get-Random
                Sync-UDElement -Id 'content'
            }
        }
    }
}

$pages += New-UDPage -Name 'Cache' -Content {
    New-UDDynamic -Id 'content' -Content {
        if ($Cache:CachePageLoaded)
        {
            New-UDTypography -Text "Some random text $($Cache:CacheData) $var"
        }
        else 
        {
            New-Progress -Text 'Loading cache data...'
            New-UDElement -Tag 'div' -Endpoint {
                Start-Sleep 5
                $Cache:CachePageLoaded = $true
                $Cache:CacheData = Get-Random
                Sync-UDElement -Id 'content'
            }
        }
    }
}

$pages += New-UDPage -Name 'Component' -Content {

    New-UDTabs -Tabs {
        New-UDTab -Text 'Tab 1' -Content {
            New-UDDynamic -Id 'tabContent' -Content {
                if ($Cache:TabLoaded)
                {
                    New-UDTypography -Text "Some random text $($Cache:TabData)"
                }
                else 
                {
                    New-Progress -Text 'Loading tab data...'
                    New-UDElement -Tag 'div' -Endpoint {
                        Start-Sleep 5
                        $Cache:TabLoaded = $true
                        $Cache:TabData = Get-Random
                        Sync-UDElement -Id 'tabContent'
                    }
                }
            }
        }
        New-UDTab -Text 'Tab 2' -Content {
            
        }
    }
}

$pages += New-UDPage -Name 'Percent Complete' -Content {

    New-UDDynamic -Id 'percent' -Content {
        New-UDProgress -PercentComplete $Session:PercentComplete
    }

    New-UDElement -Tag 'div' -Endpoint {
        1..100 | ForEach-Object {
            $Session:PercentComplete = $_
            Sync-UDElement -Id 'percent'
            Start-Sleep -Milli 100
        }
    }
}

$pages += New-UDPage -Name 'Form' -Content {
    New-UDDynamic -Id 'form' -Content {
        if ($Session:FormProcessing)
        {
            New-Progress -Text 'Submitting form...'
        }
        else 
        {
            New-UDForm -Content {
                New-UDTextbox -Label 'Name'
            } -OnSubmit {
                $Session:FormProcessing = $true 
                Sync-UDElement -Id 'form'
                Start-Sleep 5
                $Session:FormProcessing = $false 
                Sync-UDElement -Id 'form'
            }
        }
    }
}

New-UDDashboard -Pages $pages