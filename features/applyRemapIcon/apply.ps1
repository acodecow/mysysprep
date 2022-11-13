#Requires -RunAsAdministrator

$icons = @{
    quickaccess = "shell32.dll,213";
    library     = "explorer.exe";
    netdevices  = if ($osbver -lt 22000) { "shell32.dll,18" } else { "shell32.dll,164" };
}

if (($osbver -lt 22621) -and ($null -ne $icons.quickaccess)) {
    Set-Item (
        Get-CurrentAndNewUserPaths 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{679F85CB-0220-4080-B29B-5540CC05AAB6}\DefaultIcon'
    ) $icons.quickaccess
}

if ($icons.netdevices) {
    Set-Item (
        Get-CurrentAndNewUserPaths 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\DefaultIcon'
    ) $icons.netdevices
}

if ($icons.library) {
    Set-Item (
        Get-CurrentAndNewUserPaths 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{031E4825-7B94-4DC3-B131-E946B44C8DD5}\DefaultIcon'
    ) $icons.library
}
