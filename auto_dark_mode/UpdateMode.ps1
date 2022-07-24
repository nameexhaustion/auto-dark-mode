param (
    [Parameter(Mandatory)] [bool] ${mode}
)

function Set-SystemDarkMode {
    [CmdletBinding()]
    param (
        [int] ${modeInt}
    )

    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value ${modeInt} -Type Dword -Force
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value ${modeInt} -Type Dword -Force
}

Invoke-Command {
    [int] ${modeInt} = [int][bool]::Parse(${mode})
    Set-SystemDarkMode -modeInt ${modeInt}
}
