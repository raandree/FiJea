$dscLcmControllerScript = @'
function Set-LcmPostpone {
    $postponeInterval = 14
    if ($lastLcmPostpone.AddDays($postponeInterval) -gt (Get-Date)) {
        Write-Host "Last LCM postpone was done at '$lastLcmPostpone'. Next one will not be triggered before '$($lastLcmPostpone.AddDays($postponeInterval))'"
        Write-Host
        return
    }
    else {
        Write-Host "Last LCM postpone was done at '$lastLcmPostpone'. Triggering LCM postone as the last time was more than $postponeInterval ago"
        Write-Host
    }

    $currentLcmSettings = Get-DscLocalConfigurationManager
    $maxConsistencyCheckInterval = if ($currentLcmSettings.ConfigurationModeFrequencyMins -eq 44640) {
        44639 #value must be changed in order to reset the LCM timer
    }
    else {
        44640 #minutes for 31 days
    }
    
    $maxRefreshInterval = if ($currentLcmSettings.RefreshFrequencyMins -eq 44640) {
        44639 #value must be changed in order to reset the LCM timer
    }
    else {
        44640 #minutes for 31 days
    }
    
    $metaMofFolder = mkdir -Path "$path\MetaMof" -Force
    
    if (Test-Path -Path C:\Windows\System32\Configuration\MetaConfig.mof) {
        $mofFile = Copy-Item -Path C:\Windows\System32\Configuration\MetaConfig.mof -Destination "$path\MetaMof\localhost.meta.mof" -Force -PassThru
    }
    else {
        $mofFile = Get-Item -Path "$path\MetaMof\localhost.meta.mof" -ErrorAction Stop
    }
    $content = Get-Content -Path $mofFile.FullName -Raw -Encoding Unicode
    
    $pattern = '(ConfigurationModeFrequencyMins(\s+)?=(\s+)?)(\d+)(;)'
    $content = $content -replace $pattern, ('$1 {0}$5' -f $maxConsistencyCheckInterval)
    
    $pattern = '(RefreshFrequencyMins(\s+)?=(\s+)?)(\d+)(;)'
    $content = $content -replace $pattern, ('$1 {0}$5' -f $maxRefreshInterval)
    
    $content | Out-File -FilePath $mofFile.FullName -Encoding unicode
    
    Set-DscLocalConfigurationManager -Path $metaMofFolder
    
    "$(Get-Date) - Postponed LCM" | Add-Content -Path "$path\LcmPostponeSummary.log"
    
    Set-ItemProperty -Path $dscLcmController.PSPath -Name LastLcmPostpone -Value (Get-Date) -Type String -Force
}

function Test-InMaintenanceWindow {
    if ($maintenanceWindows) {
        $inMaintenanceWindow = foreach ($maintenanceWindow in $maintenanceWindows) {
            Write-Host "Reading maintenance window '$($maintenanceWindow.PSChildName)'"
            [datetime]$startTime = Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name StartTime
            [timespan]$timespan = Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name Timespan
            [datetime]$endTime = $startTime + $timespan
            [string]$dayOfWeek = try {
                Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name DayOfWeek
            }
            catch { }
            [string]$on = try {
                Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name On
            }
            catch { }

            if ($dayOfWeek) {
                if ((Get-Date).DayOfWeek -ne $dayOfWeek) {
                    Write-Host "DayOfWeek is set to '$dayOfWeek'. Current day of week is '$((Get-Date).DayOfWeek)', maintenance window does not apply"
                    continue
                }
                else {
                    Write-Host "Maintenance Window is configured for week day '$dayOfWeek' which is the current day of week."
                }
            }

            if ($on) {

                if ($on -ne 'last') {
                    $on = [int][string]$on[0]
                }

                $daysInMonth = [datetime]::DaysInMonth($now.Year, $now.Month)
                $daysInMonth = for ($i = 1; $i -le $daysInMonth; $i++) {
                    Get-Date -Date $now -Day $i
                }

                $daysInMonth = $daysInMonth | Where-Object { $_.DayOfWeek -eq $dayOfWeek }

                $daysInMonth = if ($on -eq 'last') {
                    $daysInMonth | Select-Object -Last 1
                }
                else {
                    $daysInMonth | Select-Object -Index ($on - 1)
                }

                if ($daysInMonth.ToShortDateString() -ne $now.ToShortDateString()) {
                    Write-Host "Today is not the '$on' $dayOfWeek in the current month"
                    continue
                }
                else {
                    Write-Host "The LCM is supposed to run on the '$on' $dayOfWeek which applies to today"
                }
            }

            Write-Host "Maintenance window: $($startTime) - $($endTime)."
            if ($currentTime -gt $startTime -and $currentTime -lt $endTime) {
                Write-Host "Current time '$currentTime' is in maintenance window '$($maintenanceWindow.PSChildName)'"

                Write-Host "IN MAINTENANCE WINDOW: Setting 'inMaintenanceWindow' to 'true' as the current time is in a maintanence windows."
                $true
               break
            }
            else {
                Write-Host "Current time '$currentTime' is not in maintenance window '$($maintenanceWindow.PSChildName)'"
            }
        }
    }
    else {
        Write-Host "No maintenance windows defined. Setting 'inMaintenanceWindow' to 'false'."
        $false
    }
    Write-Host

    if (-not $inMaintenanceWindow -and $maintenanceWindowOverride) {
        Write-Host "OVERRIDE: 'inMaintenanceWindow' is 'false' but 'maintenanceWindowOverride' is enabled, setting 'inMaintenanceWindow' to 'true'"
        $true
    }
    elseif (-not $inMaintenanceWindow) {
        Write-Host "NOT IN MAINTENANCE WINDOW: 'inMaintenanceWindow' is 'false'. The current time is not in any of the $($maintenanceWindows.Count) maintenance windows."
        $false
    }
    else {
        $inMaintenanceWindow
    }
}

function Set-LcmMode {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('ApplyAndAutoCorrect', 'ApplyAndMonitor')]
        [string]$Mode
    )
    $metaMofFolder = mkdir -Path "$path\MetaMof" -Force
    
    if (Test-Path -Path C:\Windows\System32\Configuration\MetaConfig.mof) {
        $mofFile = Copy-Item -Path C:\Windows\System32\Configuration\MetaConfig.mof -Destination "$path\MetaMof\localhost.meta.mof" -Force -PassThru
    }
    else {
        $mofFile = Get-Item -Path "$path\MetaMof\localhost.meta.mof" -ErrorAction Stop
    }
    $content = Get-Content -Path $mofFile.FullName -Raw -Encoding Unicode
    
    $pattern = '(ConfigurationMode(\s+)?=(\s+)?)("\w+")(;)'
    $content = $content -replace $pattern, ('$1 "{0}"$5' -f $Mode)
    
    $content | Out-File -FilePath $mofFile.FullName -Encoding unicode
    
    Set-DscLocalConfigurationManager -Path $metaMofFolder

    Write-Host "LCM put into '$Mode' mode"
}

function Test-StartDscAutoCorrect {
    if ($maintenanceWindowMode -eq 'AutoCorrect') {

        $nextAutoCorrect = $lastAutoCorrect + $autoCorrectInterval
        Write-Host ""
        Write-Host "The previous AutoCorrect was done on '$lastAutoCorrect', the next one will not be triggered before '$nextAutoCorrect'. AutoCorrectInterval is $autoCorrectInterval."
        if ($currentTime -gt $nextAutoCorrect) {
            Write-Host 'It is time to trigger an AutoCorrect per the defined interval.'
            $doAutoCorrect = $true
        }
        else {
            if ($autoCorrectIntervalOverride) {
                Write-Host "OVERRIDE: It is NOT time to trigger an AutoCorrect per the defined interval but 'AutoCorrectIntervalOverride' is enabled."
                $doAutoCorrect = $true
            }
            else {
                Write-Host 'It is NOT time to trigger an AutoCorrect per the defined interval.'
                $doAutoCorrect = $false
            }
        }
        $doAutoCorrect
    }
    else {
        $false
    }
    
}

function Test-StartDscRefresh {
    if ($maintenanceWindowMode -eq 'AutoCorrect') {

        $nextRefresh = $lastRefresh + $refreshInterval
        Write-Host ""
        Write-Host "The previous Refresh was done on '$lastRefresh', the next one will not be triggered before '$nextRefresh'. RefreshInterval is $refreshInterval."
        if ($currentTime -gt $nextRefresh) {
            Write-Host 'It is time to trigger an Refresh per the defined interval.'
            $doRefresh = $true
        }
        else {
            if ($refreshIntervalOverride) {
                Write-Host "OVERRIDE: It is NOT time to trigger a Refresh check per the defined interval but 'refreshIntervalOverride' is enabled."
                $doRefresh = $true
            }
            else {
                Write-Host 'It is NOT time to trigger a Refresh check per the defined interval.'
                $doRefresh = $false
            }
        }
        $doRefresh
    }
    else {
        $false
    }
    
}

function Start-AutoCorrect {
    Write-Host "ACTION: Invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '1' (Consistency Check)."
    try {
        Invoke-CimMethod -ClassName $className -Namespace $namespace -MethodName PerformRequiredConfigurationChecks -Arguments @{ Flags = [uint32]1 } -ErrorAction Stop | Out-Null
        $dscLcmController = Get-Item -Path HKLM:\SOFTWARE\DscLcmController
    }
    catch {
        Write-Error "Error invoking 'PerformRequiredConfigurationChecks'. The message is: '$($_.Exception.Message)'"
        $script:autoCorrectErrors = $true
    }

    Set-ItemProperty -Path $dscLcmController.PSPath -Name LastAutoCorrect -Value (Get-Date) -Type String -Force
}

function Start-Monitor {
    Write-Host "ACTION: Invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '1' (Consistency Check)."
    try {
        Invoke-CimMethod -ClassName $className -Namespace $namespace -MethodName PerformRequiredConfigurationChecks -Arguments @{ Flags = [uint32]1 } -ErrorAction Stop | Out-Null
        $dscLcmController = Get-Item -Path HKLM:\SOFTWARE\DscLcmController
    }
    catch {
        Write-Error "Error invoking 'PerformRequiredConfigurationChecks'. The message is: '$($_.Exception.Message)'"
        $script:monitorErrors = $true
    }

    Set-ItemProperty -Path $dscLcmController.PSPath -Name LastMonitor -Value (Get-Date) -Type String -Force
}

function Start-Refresh {
    Write-Host "ACTION: Invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags'5' (Pull and Consistency Check)."
    try {
        Invoke-CimMethod -ClassName $className -Namespace $namespace -MethodName PerformRequiredConfigurationChecks -Arguments @{ Flags = [uint32]5 } -ErrorAction Stop | Out-Null
        $dscLcmController = Get-Item -Path HKLM:\SOFTWARE\DscLcmController
    }
    catch {
        Write-Error "Error invoking 'PerformRequiredConfigurationChecks'. The message is: '$($_.Exception.Message)'"
        $script:refreshErrors = $true
    }

    Set-ItemProperty -Path $dscLcmController.PSPath -Name LastRefresh -Value (Get-Date) -Type String -Force
}

function Test-StartDscMonitor {
    $nextMonitor1 = $lastMonitor + $monitorInterval
    $nextMonitor2 = $lastAutoCorrect + $monitorInterval
    $nextMonitor = [datetime][math]::Max($nextMonitor1.Ticks, $nextMonitor2.Ticks)

    Write-Host ''
    Write-Host "The previous Monitor was done on '$lastMonitor', the next one will not be triggered before '$nextMonitor'. MonitorInterval is $monitorInterval."
    if ($currentTime -gt $nextMonitor) {
        Write-Host 'It is time to trigger a Monitor per the defined interval.'
        $doMonitor = $true
    }
    else {
        Write-Host 'It is NOT time to trigger a Monitor per the defined interval.'
        $doMonitor = $false
    }
    $doMonitor
}

$writeTranscripts = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name WriteTranscripts
$path = Join-Path -Path ([System.Environment]::GetFolderPath('CommonApplicationData')) -ChildPath 'Dsc\LcmController'
if ($writeTranscripts) {
    Start-Transcript -Path "$path\LcmController.log" -Append
}

$namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
$className = 'MSFT_DSCLocalConfigurationManager'

$now = Get-Date
$currentConfigurationMode = (Get-DscLocalConfigurationManager).ConfigurationMode
$lcmModeChanged = ''
$doConsistencyCheck = $false
$doRefresh = $false
$inMaintenanceWindow = $false
$doAutoCorrect = $false
$doRefresh = $false
$doMonitor = $false
$autoCorrectErrors = $false
$refreshErrors = $false
$monitorErrors = $false
$currentTime = Get-Date
$dscLcmController = Get-Item -Path HKLM:\SOFTWARE\DscLcmController

$maintenanceWindows = Get-ChildItem -Path HKLM:\SOFTWARE\DscLcmController\MaintenanceWindows
[bool]$maintenanceWindowOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name MaintenanceWindowOverride 
[timespan]$autoCorrectInterval = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name AutoCorrectInterval
[bool]$autoCorrectIntervalOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name AutoCorrectIntervalOverride
[timespan]$monitorInterval = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name MonitorInterval
[timespan]$refreshInterval = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name RefreshInterval
[bool]$refreshIntervalOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name RefreshIntervalOverride
$maintenanceWindowMode = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name MaintenanceWindowMode

[datetime]$lastAutoCorrect = try {
    Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name LastAutoCorrect
}
catch {
    Get-Date -Date 0
}
[datetime]$lastMonitor = try {
    Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name LastMonitor
}
catch {
    Get-Date -Date 0
}
[datetime]$lastRefresh = try {
    Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name LastRefresh
}
catch {
    Get-Date -Date 0
}
[datetime]$lastLcmPostpone = try {
    Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name LastLcmPostpone
}
catch {
    Get-Date -Date 0
}

Write-Host '----------------------------------------------------------------------------'
Set-LcmPostpone

$inMaintenanceWindow = Test-InMaintenanceWindow
Write-Host
if ($inMaintenanceWindow) {
    if ($maintenanceWindowMode -eq 'AutoCorrect' -and $currentConfigurationMode -ne 'ApplyAndAutoCorrect') {
        Write-Host "MaintenanceWindowMode is '$maintenanceWindowMode' but LCM is set to '$currentConfigurationMode'. Changing LCM to 'ApplyAndAutoCorrect'"
        Set-LcmMode -Mode 'ApplyAndAutoCorrect'
        $lcmModeChanged = 'ApplyAndAutoCorrect'
    }
    elseif ($maintenanceWindowMode -eq 'Monitor' -and $currentConfigurationMode -ne 'ApplyAndMonitor') {
        Write-Host "MaintenanceWindowMode is '$maintenanceWindowMode' but LCM is set to '$currentConfigurationMode'. Changing LCM to 'ApplyAndMonitor'"
        Set-LcmMode -Mode 'ApplyAndMonitor'
        $lcmModeChanged = 'ApplyAndMonitor'
    }
}

if ($inMaintenanceWindow) {
    $doAutoCorrect = Test-StartDscAutoCorrect
    $doRefresh = Test-StartDscRefresh

    if ($doAutoCorrect) {
        Start-AutoCorrect
    }
    else {
        Write-Host "NO ACTION: 'doAutoCorrect' is false, not invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '1' (Consistency Check)."
    }

    if ($doRefresh) {
        Start-Refresh
    }
    else {
        Write-Host "NO ACTION: 'doRefresh' is false, not invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '5' (Pull and Consistency Check)."
    }
}

Write-Host
if ($lcmModeChanged) {
    Write-Host "Setting LCM back from '$lcmModeChanged' to '$currentConfigurationMode'."
    Set-LcmMode -Mode $currentConfigurationMode
}

Write-Host
if (-not $doAutoCorrect) {
    $doMonitor = Test-StartDscMonitor
    if ($doMonitor) {
        Start-Monitor
    }
    else {
        Write-Host "NO ACTION: 'doMonitor' is false, not invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '1' (Consistency Check)."
    }
}
else {
    Write-Host "In AutoCorrect mode, skipping Montior"
}

$logItem = [pscustomobject]@{
    CurrentTime                 = Get-Date
    InMaintenanceWindow         = [int]$inMaintenanceWindow
    DoAutoCorrect               = [int]$doAutoCorrect
    DoMonitor                   = [int]$doMonitor
    DoRefresh                   = [int]$doRefresh

    LastAutoCorrect             = $lastAutoCorrect
    LastMonitor                 = $lastMonitor
    AutoCorrectInterval         = $autoCorrectInterval
    AutoCorrectIntervalOverride = $autoCorrectIntervalOverride
    ConsistencyCheckErrors      = $autoCorrectErrors

    MonitorInterval             = $monitorInterval
    MonitorErrors               = $monitorErrors

    LastRefresh                 = $lastRefresh
    RefreshInterval             = $refreshInterval
    RefreshIntervalOverride     = $refreshIntervalOverride
    RefreshErrors               = $refreshErrors
    
} | Export-Csv -Path "$path\LcmControllerSummary.txt" -Append

if ($writeTranscripts) {
    Stop-Transcript
} 
'@

configuration DscLcmController {
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Monitor', 'AutoCorrect')]
        [string]$MaintenanceWindowMode,

        [Parameter(Mandatory)]
        [timespan]$MonitorInterval,

        [Parameter(Mandatory)]
        [timespan]$AutoCorrectInterval,
        
        [bool]$AutoCorrectIntervalOverride,

        [Parameter(Mandatory)]
        [timespan]$RefreshInterval,
        
        [bool]$RefreshIntervalOverride,

        [Parameter(Mandatory)]
        [timespan]$ControllerInterval,

        [bool]$MaintenanceWindowOverride,

        [bool]$WriteTranscripts
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    xRegistry DscLcmController_MaintenanceWindowMode {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'MaintenanceWindowMode'
        ValueData = $MaintenanceWindowMode
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmController_MonitorInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'MonitorInterval'
        ValueData = $MonitorInterval       
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmController_AutoCorrectInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'AutoCorrectInterval'
        ValueData = $AutoCorrectInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmController_AutoCorrectIntervalOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'AutoCorrectIntervalOverride'
        ValueData = [int]$AutoCorrectIntervalOverride
        ValueType = 'DWord'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmController_RefreshInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'RefreshInterval'
        ValueData = $RefreshInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmController_RefreshIntervalOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'RefreshIntervalOverride'
        ValueData = [int]$RefreshIntervalOverride
        ValueType = 'DWord'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmController_ControllerInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'ControllerInterval'
        ValueData = $ControllerInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmController_MaintenanceWindowOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'MaintenanceWindowOverride'
        ValueData = [int]$MaintenanceWindowOverride
        ValueType = 'DWord'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmController_WriteTranscripts {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'WriteTranscripts'
        ValueData = [int]$WriteTranscripts
        ValueType = 'DWord'
        Ensure    = 'Present'
        Force     = $true
    }

    File DscLcmControllerScript {
        Ensure          = 'Present'
        Type            = 'File'
        DestinationPath = 'C:\ProgramData\Dsc\LcmController\LcmController.ps1'
        Contents        = $dscLcmControllerScript
    }
    
    ScheduledTask DscControllerTask {
        DependsOn          = '[File]DscLcmControllerScript'
        TaskName           = 'DscLcmController'
        TaskPath           = '\DscController'
        ActionExecutable   = 'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe'
        ActionArguments    = '-File C:\ProgramData\Dsc\LcmController\LcmController.ps1'
        ScheduleType       = 'Once'
        RepeatInterval     = $ControllerInterval
        RepetitionDuration = 'Indefinitely'
        StartTime          = (Get-Date)
    }  
}
