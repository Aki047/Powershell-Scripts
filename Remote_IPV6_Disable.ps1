# Prompt the user for the remote computer name
$computerName = Read-Host "Please enter the computer name"

Invoke-Command -ComputerName $computerName -ScriptBlock {
    # Find network adapter configs that are IPV6 enabled
    $adapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = TRUE'
    $ipv6EnabledAdapters = $adapters | Where-Object { $_.IPAddress -like "*:*" }

    # Display IPv6 enabled adapters
    $i = 1
    foreach ($adapter in $ipv6EnabledAdapters) {
        Write-Output "$i. IPv6 is enabled on the adapter: $($adapter.Description)"
        $i++
    }

    # Prompt user to select an adapter to disable IPv6
    $selectedAdapterIndex = Read-Host "Enter the number of the adapter to disable IPv6"
    $selectedAdapter = $ipv6EnabledAdapters[$selectedAdapterIndex - 1]

    if ($selectedAdapter) {
        # Attempt to disable IPv6 on the selected adapter
        try {
            $currentSetting = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\' -Name 'DisabledComponents' -ErrorAction Stop

            if ($currentSetting.DisabledComponents -ne 0xff) {
                # If IPv6 is enabled (not already set to 0xff), disable it
                Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\' -Name 'DisabledComponents' -Value 0xff
                Write-Output "IPv6 has been successfully disabled on $($selectedAdapter.Description)."
            } else {
                # If IPv6 is already disabled, no action needed
                Write-Output "IPv6 is already disabled on $($selectedAdapter.Description). No changes were made."
            }
        } catch {
            # Handle any errors that occur during the process
            Write-Output "Failed to update IPv6 settings on $($selectedAdapter.Description): $($_.Exception.Message)"
        }
    } else {
        Write-Output "Invalid selection. No changes made."
    }
}
