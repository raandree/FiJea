function New-DhcpReservation {
param (
    [Parameter(Mandatory, ParameterSetName = 'ByParameters')]
    [string]$ScopeId,

    [Parameter(Mandatory, ParameterSetName = 'ByParameters')]
    [string]$IPAddress,

    [Parameter(Mandatory, ParameterSetName = 'ByParameters')]
    [string]$ClientId,

    [Parameter(Mandatory, ParameterSetName = 'ByParameters')]
    [string]$Name,

    [Parameter(Mandatory, ParameterSetName = 'FileUpload')]
    [string]$FilePath
)

if ($PSCmdlet.ParameterSetName -eq 'ByParameter') {
    Add-DhcpServerv4Reservation @PSBoundParameters
}
elseif ($PSCmdlet.ParameterSetName -eq 'FileUpload') {
    Get-Content -Path $FilePath | Add-DhcpServerv4Reservation
}
else {
    Write-Error 'Unknown parameter set'
}
    
}