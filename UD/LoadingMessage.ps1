$Page1 = New-UDPage -Name "Home" -Content { 
    #region Loading Indicator
    $Session:DoneLoading = $false

    New-UDRow -Columns {
        New-UDColumn -Endpoint {
            New-UDElement -Id 'LoadingMessage' -Tag div -Endpoint {
                if ($Session:DoneLoading -ne $true) {
                    New-UDHeading -Text "Loading...Please wait..." -Size 5
                    New-UDPreloader -Size small
                }
            }
        }
    }
    #endregion


    New-UDColumn -Size 12 -Endpoint {
        <#
        Build your time-intensive page here.
        #>
    

        # Remove the Loading Indicator
        $Session:DoneLoading = $true
        Sync-UDElement -Id 'LoadingMessage' -Broadcast
    }
}
$Page2 = New-UDPage -Name "Links" -Content { New-UDCard }    
New-UDDashboard -Title T4 -Pages $Page1, $Page2