#usually the process consuming the most memory is the one that hosts the LCM
$p = Get-Process -Name WmiPrvSE | Sort-Object -Property WS -Descending | Select-Object -First 1

Enter-PSHostProcess -Process $p -AppDomainName DscPsPluginWkr_AppDomain
Start-Sleep -Seconds 1
$rs = Get-Runspace | Where-Object { $_.Debugger.InBreakpoint }
Debug-Runspace -Runspace $rs