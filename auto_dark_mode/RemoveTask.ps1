. auto_dark_mode/Configs.ps1

[ScriptBlock] ${f} = {
    Unregister-ScheduledTask -Confirm:${false} ${taskIdLightMode}
    Unregister-ScheduledTask -Confirm:${false} ${taskIdDarkMode}
}

Write-Output ${f}
Invoke-Command ${f}
