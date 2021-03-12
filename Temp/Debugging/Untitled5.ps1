$s = New-PSSession -ComputerName localhost -ConfigurationName admanagement
Import-PSSession $s

$task = Get-JeaEndpointCapability -ComputerName localhost -JeaEndpointName AdManagement -Username Install
$task = $task[0]
$parameterSets = Get-FunctionParameterSet -ScriptBlock ([scriptblock]::Create($task.ScriptBlock)) #| Select-Object -First 1
Get-FunctionParameterSet -FunctionName New-xAdUser
