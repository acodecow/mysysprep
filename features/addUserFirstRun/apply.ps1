#Requires -RunAsAdministrator

param($cfg)

$firstrunPath = "$(Get-BasePath -Scripts)\firstrun.ps1"

if ($text = Get-Content '.\script.ps1' -ea 0) {
    if ($cfg | Get-Member GetEnumerator) {
        $text += ''
        foreach ($pair in $cfg.GetEnumerator()) {
            if ($pair.Value) {
                $text += $pair.Name
            }
        }
    }
    $text | Out-File -Encoding unicode $firstrunPath
}

if (!$isAuditMode) {
    $it = (New-Object -ComObject WScript.Shell).CreateShortcut("C:\Users\Default\Desktop\Firstrun.lnk")
    $it.TargetPath = "powershell.exe"
    $it.Arguments = "-exec bypass -file `"$firstrunPath`""
    $it.IconLocation = "shell32.dll,99"
    $it.save()
}

& $firstrunPath