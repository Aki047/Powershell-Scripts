
Import-Module ActiveDirectory


$csvPath = "C:\Users\Public\Desktop\Tools\New_Users_Template.csv"
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
    # Check if the user already exists
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.User)'"
    if ($existingUser) {
        Write-Host "User $($user.User) already exists. Skipping creation."
        continue
    }

    # Prepare user parameters
    $userParams = @{
        GivenName              = $user.FirstName
        Surname                = $user.LastName
        SamAccountName         = $user.User
        UserPrincipalName      = $user.Email
        Name                   = "$($user.FirstName) $($user.LastName)"
        Office                 = $user.Office
        Description            = $user.JobTitle
        Department             = $user.Department
        Title                  = $user.JobTitle
        AccountPassword        = (ConvertTo-SecureString -AsPlainText $user.Password -Force)
        PasswordNeverExpires   = $false
        ChangePasswordAtLogon  = $false
        Enabled                = $true
        Path                   = "OU=AccountUsers,DC=ABCLegal.com,DC=com"
    }

    try {
        # Create the AD user
        New-ADUser @userParams
        Write-Host "User $($user.User) created successfully."

        # Find supervisor and set manager attribute if the supervisor exists
        $supervisor = Get-ADUser -Filter "Name -eq '$($user.Supervisor)'"
        if ($supervisor) {
            Set-ADUser -Identity $user.User -Manager $supervisor.DistinguishedName
        } else {
            Write-Host "Supervisor $($user.Supervisor) not found. Manager not set for $($user.User)."
        }

        # Copy group memberships from the specified existing member
        $existingMember = Get-ADUser -Filter "Name -eq '$($user.GroupAccessFrom)'" -Properties MemberOf
        if ($existingMember) {
            $existingMember.MemberOf | ForEach-Object {
                $group = Get-ADGroup -Identity $_
                Add-ADGroupMember -Identity $group -Members $user.User
            }
        } else {
            Write-Host "Reference user for group access $($user.GroupAccessFrom) not found. No groups copied."
        }

    } catch {
        Write-Host "Failed to create user $($user.User): $_"
    }
}

Write-Host "Script execution complete."
