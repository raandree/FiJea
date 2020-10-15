New-UDDashboard -Title "Hello, World!" -Content { 
    New-UDElement -Tag 'div' -Endpoint {
        New-UDTypography -Text "Hello, World!"
        get-variable | Export-Clixml c:\x.xml
        $pid | Out-File c:\pid.txt
        $queryStringValue = "location"
        $url = $($request.Headers["referer"]);
        $queryStringIndex = $url.IndexOf('?')
 
        # no query strings were passed in
        if ($queryStringIndex -eq -1) {
            New-UDHeading -Text "No query string passed in" -Size 1
        }
        elseif ($queryStringIndex -ge 0) {
            $queryString = $url.Substring($queryStringIndex);
            [System.Collections.Specialized.NameValueCollection]$queryStringCollection = [System.Web.HttpUtility]::ParseQueryString($querystring);
            New-UDHeading -Text "$queryStringValue = $($queryStringCollection[$queryStringValue])" -Size 1
        }
        else {
            New-UDHeading -Text "Nothing to see" -Size 1
        }
    }
}