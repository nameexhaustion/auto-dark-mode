[CmdletBinding()]
param (
    [string] ${taskConfigPath} = 'private/config.json'
)

${taskConfig} = Get-Content ${taskConfigPath} | ConvertFrom-Json
${tasksOrdered} = ${taskConfig}.tasksOrdered

[datetime] ${time} = Get-Date
[datetime[]] ${boundsTime} = ${tasksOrdered} | ForEach-Object { ${_}.time }
[string] ${taskName} = ${tasksOrdered}[1].taskName

if (${time} -gt ${boundsTime}[0] -and ${time} -lt ${boundsTime}[1]) {
    ${taskName} = ${tasksOrdered}[0].taskName
}

Start-ScheduledTask -TaskName ${taskName}
