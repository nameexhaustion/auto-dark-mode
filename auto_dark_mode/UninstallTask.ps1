[CmdletBinding()]
param (
    [string] ${taskConfigPath} = 'private/config.json'
)

${taskConfig} = Get-Content ${taskConfigPath} | ConvertFrom-Json

${taskConfig}.tasks | ForEach-Object {
    Write-Output "Unregister ${_}"
    Unregister-ScheduledTask -Confirm:${false} ${_}
}
