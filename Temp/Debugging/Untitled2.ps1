$cmd = 'Get-date'

$parameters = Get-FunctionParameter -ScriptBlock ([scriptblock]::Create($cmd)) -ParameterSetName $null
$parameters
