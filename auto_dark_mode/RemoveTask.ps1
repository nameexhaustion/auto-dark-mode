. auto_dark_mode/Configs.ps1

[ScriptBlock] ${f} = {
    Unregister-ScheduledTask -Confirm:${false} ${taskIdDarkMode}
    Unregister-ScheduledTask -Confirm:${false} ${taskIdLightMode}
}

Write-Output ${f}
Invoke-Command ${f}
