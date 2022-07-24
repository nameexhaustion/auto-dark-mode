param (
    [string] ${shell} = 'powershell.exe',
    [string] ${updateModeScriptPath} = "$(Get-Location)/auto_dark_mode/UpdateMode.ps1",
    [datetime] ${timeLightMode} = '09:00',
    [datetime] ${timeDarkMode} = '17:00'
)

. auto_dark_mode/Configs.ps1
./auto_dark_mode/RemoveTask.ps1

function New-ModeTask {
    [CmdletBinding()]
    param (
        [int] ${modeInt},
        [datetime] ${time},
        [string] ${taskDescription}
    )

    [string] ${userId} = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    [string] ${argument} = "-windowstyle hidden -command ${updateModeScriptPath} ${modeInt}"
    [CimInstance] ${action} = New-ScheduledTaskAction -WorkingDirectory $(Get-Location) -Execute ${shell} -Argument ${argument}
    [CimInstance] ${trigger} = New-ScheduledTaskTrigger -Daily -At ${time}
    [CimInstance] ${principal} = New-ScheduledTaskPrincipal -UserId "${userId}" -LogonType S4U
    [CimInstance] ${task} = New-ScheduledTask -Principal ${principal} -Action ${action} -Trigger ${trigger} -Description "${taskDescription}"

    return ${task}
}

[datetime] ${time} = ${timeLightMode}
[string] ${taskId} = ${taskIdLightMode}
[string] ${taskDescription} = "Set light mode at ${time}"
[CimInstance] ${task} = New-ModeTask -modeInt 1 -time ${time} -taskDescription ${taskDescription}
Register-ScheduledTask ${taskId} -InputObject ${task}

[datetime] ${time} = ${timeDarkMode}
[string] ${taskId} = ${taskIdDarkMode}
[string] ${taskDescription} = "Set dark mode at ${time}"
[CimInstance] ${task} = New-ModeTask -modeInt 0 -time ${time} -taskDescription ${taskDescription}
Register-ScheduledTask ${taskId} -InputObject ${task}

[string] ${taskName} = ${taskIdDarkMode}
[datetime] ${time} = (Get-Date).AddMinutes(1)

[hashtable[]] ${arr} = @(
    @{
        'time' = [string]${timeLightMode}
        'f'    = [scriptblock] {
            Start-ScheduledTask -TaskName ${taskIdLightMode}
        }
    }
    @{
        'time' = [string]${timeDarkMode}
        'f'    = [scriptblock] {
            Start-ScheduledTask -TaskName ${taskIdDarkMode}
        }
    }
)

[hashtable[]] ${bounds} = ${arr} | Sort-Object -Property time
[datetime[]] ${boundsTime} = ${arr} | ForEach-Object { ${_}['time'] }

if (${time} -gt ${boundsTime}[0] -and ${time} -lt ${boundsTime}[1]) {
    Invoke-Command ${bounds}[0]['f']
}
else {
    Invoke-Command ${bounds}[1]['f']
}
