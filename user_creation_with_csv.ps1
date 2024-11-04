# Define the path to store the downloaded CSV
$csvPath = "\\DC-01\Users\Administrator.DC-1\Downloads\AutoUsers_hybridhub.csv"

# Download the CSV file from GitHub
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/uelcn6035/WindowsAdministration/main/AutoUsers_hybridhub.csv" -OutFile $csvPath

# Import the CSV file
$users = Import-Csv -Path $csvPath

# Define the base path for the OUs
$baseOU = "OU=Home,DC=hybridhub,DC=local"
$userOU = "OU=UserPool-Uncut,OU=userGroups,$baseOU"
$groupOU = "OU=Grouping-Uncut,OU=userGroups,$baseOU"

# Create the base OU if it doesn't exist
$baseOUExists = Get-ADOrganizationalUnit -Filter "Name -eq 'userGroups'" -SearchBase $baseOU -ErrorAction SilentlyContinue
if (-not $baseOUExists) {
    try {
        New-ADOrganizationalUnit -Name "userGroups" -Path $baseOU -Description "Auto-created by PowerShell script"
        Write-Host "Successfully created base OU: userGroups"
    } catch {
        Write-Host "Failed to create base OU: userGroups - $($_.Exception.Message)"
    }
} else {
    Write-Host "Base OU userGroups already exists."
}

# Create the Users OU if it doesn't exist
$usersOUExists = Get-ADOrganizationalUnit -Filter "Name -eq 'UserPool-Uncut'" -SearchBase "OU=userGroups,$baseOU" -ErrorAction SilentlyContinue
if (-not $usersOUExists) {
    try {
        New-ADOrganizationalUnit -Name "UserPool-Uncut" -Path "OU=userGroups,$baseOU" -Description "Auto-created by PowerShell script"
        Write-Host "Successfully created OU: UserPool-Uncut"
    } catch {
        Write-Host "Failed to create OU: UserPool-Uncut - $($_.Exception.Message)"
    }
} else {
    Write-Host "OU UserPool-Uncut already exists."
}

# Create the Grouping OU if it doesn't exist
$groupingOUExists = Get-ADOrganizationalUnit -Filter "Name -eq 'Grouping-Uncut'" -SearchBase "OU=userGroups,$baseOU" -ErrorAction SilentlyContinue
if (-not $groupingOUExists) {
    try {
        New-ADOrganizationalUnit -Name "Grouping-Uncut" -Path "OU=userGroups,$baseOU" -Description "Auto-created by PowerShell script"
        Write-Host "Successfully created OU: Grouping-Uncut"
    } catch {
        Write-Host "Failed to create OU: Grouping-Uncut - $($_.Exception.Message)"
    }
} else {
    Write-Host "OU Grouping-Uncut already exists."
}

# Prompt for password
$password = Read-Host -AsSecureString "Enter the password for the new users"

# Loop to check and create groups if they do not exist
foreach ($group in $users.Group | Sort-Object -Unique) {
    $groupExists = Get-ADGroup -Filter "Name -eq '$group'" -SearchBase $groupOU -ErrorAction SilentlyContinue
    if (-not $groupExists) {
        try {
            New-ADGroup -Name $group -GroupScope Global -Path $groupOU -GroupCategory Security -Description "Auto-created by PowerShell script"
            Write-Host "Successfully created group: $group"
        } catch {
            Write-Host "Failed to create group: $group - $($_.Exception.Message)"
        }
    } else {
        Write-Host "Group $group already exists."
    }
}

# Initialize progress bar
$totalUsers = $users.Count
$currentUser = 0

# Loop to create new users or update existing users and add them to groups
foreach ($user in $users) {
    $currentUser++
    Write-Progress -Activity "Processing Users" -Status "Processing $currentUser of $totalUsers" -PercentComplete (($currentUser / $totalUsers) * 100)

    $userPrincipalName = "$($user.Username)@hybridhub.local"
    $homeDirectory = "\\DC-01\all_userhomefolder_rw$\$($user.Username)"

    # Check if the user already exists
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.Username)'" -ErrorAction SilentlyContinue
    if ($existingUser) {
        Write-Host "User $($user.Username) already exists."

        # Check if the user is already a member of the specified group
        $groupMembership = Get-ADUser -Identity $existingUser -Property MemberOf | Select-Object -ExpandProperty MemberOf
        $groupDN = (Get-ADGroup -Filter "Name -eq '$($user.Group)'" -SearchBase $groupOU -ErrorAction SilentlyContinue).DistinguishedName
        if ($groupMembership -contains $groupDN) {
            Write-Host "User $($user.Username) is already a member of group $($user.Group)."
        } else {
            # Add user to the specified group
            try {
                Add-ADGroupMember -Identity $user.Group -Members $user.Username
                Write-Host "Added user $($user.Username) to group $($user.Group)."
            } catch {
                Write-Host "Failed to add user $($user.Username) to group $($user.Group) - $($_.Exception.Message)"
            }
        }
    } else {
        try {
            $userParams = @{
                Name                  = "$($user.FirstName) $($user.LastName)"
                GivenName             = $user.FirstName
                Surname               = $user.LastName
                SamAccountName        = $user.Username
                UserPrincipalName     = $userPrincipalName
                Path                  = $userOU
                AccountPassword       = $password
                Enabled               = $true
                PasswordNeverExpires  = $true
                ChangePasswordAtLogon = $false
                Department            = $user.Department
                Title                 = $user.Title
                OfficePhone           = $user.PhoneNumber
                Office                = $user.OfficeLocation
                HomeDirectory         = $homeDirectory
                HomeDrive             = "E:"
                ProfilePath           = $user.ProfilePath
                Description           = "Auto-created by PowerShell script"
            }

            New-ADUser @userParams

            # Add user to the specified group
            Add-ADGroupMember -Identity $user.Group -Members $user.Username
            Write-Host "Successfully created user: $($user.Username) and added to group: $($user.Group)"
        } catch {
            Write-Host "Failed to create user: $($user.Username) or add to group: $($user.Group) - $($_.Exception.Message)"
        }
    }
}

# Complete progress bar
Write-Progress -Activity "Processing Users" -Status "Complete" -Completed
Write-Host "User processing complete."

# Define the URL to your script on GitHub
$scriptUrl = "https://raw.githubusercontent.com/uelcn6035/WindowsAdministration/main/invokeHomeFolder.ps1"

# Define the path to save the downloaded script
$localScriptPath = "\\DC-01\Users\Administrator.DC-1\Downloads\invokeHomeFolder.ps1"

# Download the script from GitHub
Write-Host "Downloading the home folder creation script from GitHub..."
Invoke-WebRequest -Uri $scriptUrl -OutFile $localScriptPath
Write-Host "Script downloaded to $localScriptPath"

# Set the execution policy to Bypass
Write-Host "Setting execution policy to Bypass..."
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Run the downloaded script directly
Write-Host "Running the home folder creation script..."
& $localScriptPath
Write-Host "Home folder creation script executed."

# Fun exit message
Write-Host ""
Write-Host "🎉🎉🎉 Hooray! All tasks completed successfully. 🎉🎉🎉" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit and celebrate!"

