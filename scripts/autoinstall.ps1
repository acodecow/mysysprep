.\_adminrequire.ps1

Write-Host '==> Auto install all of "./packages"'
Write-Host "If prompt installation dialogs, allow and confirm ...`n"

.\autoinstall-choco.ps1

Push-Location ..\packages

function Start-InstallJob {
    param($name, $path, $params)
    Write-Host "Start to install $name ..."
    Start-Job -ArgumentList @($path, $params) -Name $name {
        Start-Process -Wait $args[0] $args[1]
    } > $null
}

$firefox = 'Firefox'
$thunderbird = 'Thunderbird'
$7zipZstd = '7zip-zstd'

foreach ($file in Get-ChildItem) {
    $filename = $file.Name
    $path = $file.FullName
    switch -Wildcard ($filename) {
        '7z*-zstd-x64.exe' {
            Start-InstallJob $7zipZstd $path '/S'
        }
        'Firefox Setup *.exe' {
            Start-InstallJob $firefox $path '/S'
        }
        'Thunderbird Setup *.exe'{
            Start-InstallJob $thunderbird $path '/S'
        }
    }
}

Write-Host

function Push-SystemPath {
    param([string]$path)
    if ($env:path -like "*$path*") { return }
    setx /m PATH "$env:path;$path" > $null
}

function Assert-Path {
    param([string]$path)
    Get-ChildItem $path -ea Stop > $null
}

function Get-JobOrWait {
    [OutputType([Management.Automation.Job])]
    param()
    $job = Get-Job -State Failed | Select-Object -First 1
    if ($null -eq $job) { $job = Get-Job -State Completed | Select-Object -First 1 }
    if ($null -eq $job) { $job = Get-Job | Wait-Job -Any }
    return $job
}

While ($job = Get-JobOrWait) {
    try {
        Receive-Job $job 2>$null
        if ($job.State -eq 'Failed') { 
            throw 
        }
        switch ($job.Name) {
            $7zipZstd {
                Push-SystemPath "C:\Program Files\7-Zip-Zstandard"
            }
            $firefox { 
                Assert-Path "C:\Program Files\Mozilla Firefox\firefox.exe"
            }
            $thunderbird{
                Assert-Path "C:\Program Files\Mozilla Thunderbird\thunderbird.exe"
            }
        }
    }
    catch {
        Write-Host "Failed to install $($job.Name):"
        Write-Host $Error "`n"
        continue
    }
    finally {
        Remove-Job $job
    }
    Write-Host "Successfully installed $($job.Name)."
}

Pop-Location