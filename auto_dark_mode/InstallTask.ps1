[CmdletBinding()]
param (
    [string] ${shell} = 'powershell.exe',
    [datetime] ${lightModeStart} = '09:00',
    [datetime] ${darkModeStart} = '17:00'
)

[string] ${setModeScriptPath} = "$(Get-Location)/auto_dark_mode/SetMode.ps1"
[string] ${syncModeScriptPath} = "$(Get-Location)/auto_dark_mode/SyncMode.ps1"
[string] ${userId} = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
[CimInstance] ${principal} = New-ScheduledTaskPrincipal -UserId "${userId}" -LogonType S4U

. auto_dark_mode/Config.ps1
New-Item -ItemType directory -Force private
./auto_dark_mode/UninstallTask.ps1

function New-ModeTask {
    [CmdletBinding()]
    param (
        [int] ${modeInt},
        [datetime] ${time},
        [string] ${taskDescription}
    )

    [string] ${argument} = "-command ${setModeScriptPath} ${modeInt}"
    [CimInstance] ${action} = New-ScheduledTaskAction -WorkingDirectory $(Get-Location) -Execute ${shell} -Argument ${argument}
    [CimInstance] ${settings} = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
    [CimInstance] ${trigger} = New-ScheduledTaskTrigger -Daily -At ${time}
    [CimInstance] ${task} = New-ScheduledTask -Action ${action} -Settings ${settings} -Principal ${principal} -Trigger ${trigger} -Description "${taskDescription}"

    return ${task}
}

[datetime] ${time} = ${lightModeStart}
[string] ${taskId} = ${taskIdLightMode}
[string] ${taskDescription} = "Set light mode at ${time}"
[CimInstance] ${task} = New-ModeTask -modeInt 1 -time ${time} -taskDescription ${taskDescription}
Register-ScheduledTask ${taskId} -InputObject ${task}

[datetime] ${time} = ${darkModeStart}
[string] ${taskId} = ${taskIdDarkMode}
[string] ${taskDescription} = "Set dark mode at ${time}"
[CimInstance] ${task} = New-ModeTask -modeInt 0 -time ${time} -taskDescription ${taskDescription}
Register-ScheduledTask ${taskId} -InputObject ${task}

[string] ${taskId} = ${taskIdSync}
[string] ${taskDescription} = 'Sync system theme mode'
[string] ${argument} = "-command ${syncModeScriptPath} -taskConfigPath ${taskConfigPath}"
[CimInstance] ${action} = New-ScheduledTaskAction -WorkingDirectory $(Get-Location) -Execute ${shell} -Argument ${argument}
[CimInstance] ${settings} = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
[CimInstance] ${trigger} = New-ScheduledTaskTrigger -AtLogOn -User "${userId}"
[CimInstance] ${task} = New-ScheduledTask -Action ${action} -Settings ${settings} -Principal ${principal} -Trigger ${trigger} -Description "${taskDescription}"
Register-ScheduledTask ${taskId} -InputObject ${task}

[hashtable[]] ${tasksOrdered} = @(
    @{
        'time'     = ${lightModeStart}
        'taskName' = ${taskIdLightMode}
    }
    @{
        'time'     = ${darkModeStart}
        'taskName' = ${taskIdDarkMode}
    }
) | Sort-Object -Property time

[hashtable] ${config} = @{
    'tasksOrdered' = ${tasksOrdered}
    'tasks'        = @(${taskIdLightMode}, ${taskIdDarkMode}, ${taskIdSync})
}

${config} | ConvertTo-Json | Out-File ${taskConfigPath}

Start-ScheduledTask -TaskName ${taskIdSync}
