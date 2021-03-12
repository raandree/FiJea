$jeaServer = 'fiweb1'
$user = 'test1'
$jeaEndpointName = 'NetworkServices'
$itemName = @{ Name = 'New-xDhcpReservation' }

$tasks = Get-JeaEndpointCapability -JeaEndpointName $jeaEndpointName -Username $user -ComputerName $jeaServer
Set-Item -Path Session:"tasks.$JeaEndpointName" -Value $tasks

$parameters = ($session:tasks.$JeaEndpointName | Where-Object Name -eq $item.Name).Parameters

$parameters = ($session:tasks.$JeaEndpointName | Where-Object Name -eq $item.Name).Parameters
$parameterDefaultValues = Get-FunctionDefaultParameter -Scriptblock ([scriptblock]::Create($item.ScriptBlock))

return

$ParameterSetName = Get-FunctionParameterSet -ScriptBlock $cmd
$parameters = Get-FunctionParameter -ScriptBlock $cmd -ParameterSetName $ParameterSetName
    $parameterDefaultValues = Get-FunctionDefaultParameter -Scriptblock ([scriptblock]::Create($item.ScriptBlock))
    $session:parameterSetName = $ParameterSetName
    $session:currentTask = $task