[CmdletBinding()]
param (
    [string] ${taskConfigPath} = 'private/config.json'
)

${taskConfig} = Get-Content ${taskConfigPath} | ConvertFrom-Json
${tasksOrdered} = ${taskConfig}.tasksOrdered

[timespan] ${time} = (Get-Date).TimeOfDay
[timespan[]] ${boundsTime} = ${tasksOrdered} | ForEach-Object { ([datetime]${_}.time).timeofday }
[string] ${taskName} = ${tasksOrdered}[1].taskName

if (${time} -gt ${boundsTime}[0] -and ${time} -lt ${boundsTime}[1]) {
    ${taskName} = ${tasksOrdered}[0].taskName
}

Start-ScheduledTask -TaskName ${taskName}
