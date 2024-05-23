# Get BitLocker Recovery Key
$recoveryKey = (Get-BitLockerVolume -MountPoint "C:").KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }

# Get Computer Name
$computerName = $env:COMPUTERNAME

# Construct file name with computer name
$fileName = "$computerName BitLocker-RecoveryKey.txt"

# Specify network path
$networkPath = "\\abclegal.com\IT\Toolbox\Recovery Keys\BitLocker"

# Save recovery key to file
$recoveryKey.RecoveryPassword | Out-File -FilePath (Join-Path -Path $networkPath -ChildPath $fileName)

Write-Host "BitLocker recovery key saved to $($networkPath)\$($fileName)"
