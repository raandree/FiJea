New-UDDashboard -Title "Hello, World!" -Content {
    New-UDHeading -Text "Hello, World!" -Size 1

    New-UDHeading -Text "Hello, $v1!" -Size 1

    $r = Get-Content C:\param.xml -Raw
    New-UDTypography -Text $r -Variant h5
}