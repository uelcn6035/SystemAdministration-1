# Retrieve all user profiles on the system

$profiles = Get-WmiObject Win32_UserProfile | Where-Object { 

    # Filter out special profiles (like system accounts)

    $_.Special -eq $false

}



# Initialize a counter for profiles older than 10 days

$oldProfilesCount = 0

$oldProfiles = @()



# Loop through each profile to check its age

foreach ($profile in $profiles) {

    try {

        $lastUseTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($profile.LastUseTime)

        if ($lastUseTime -lt (Get-Date).AddDays(-10)) {

            $oldProfilesCount++

            $oldProfiles += $profile

            Write-Host "Profile: $($profile.LocalPath) - Last Used: $lastUseTime"

        }

    } catch {

        Write-Host "Failed to convert LastUseTime for profile: $($profile.LocalPath)"

    }

}



# Output the total number of profiles and the number of old profiles

Write-Host "Total profiles: $($profiles.Count)"

Write-Host "Profiles older than 10 days: $oldProfilesCount"



# Check if there are any profiles to delete

if ($oldProfilesCount -eq 0) {

    Write-Host "No profiles older than 10 days found. Now quitting..."

    Start-Sleep -Seconds 10  # Pause for 10 seconds

    exit

}



# Initialize counter for deleted profiles

$deletedCount = 0



# Loop through each old profile to delete it

foreach ($profile in $oldProfiles) {

    try {

        Write-Host "Deleting profile: $($profile.LocalPath)"

        # Remove the user profile

        $profile.Delete()

        Write-Host "Deleted profile: $($profile.LocalPath)"

        

        # Manually delete the profile folder

        $profileFolder = $profile.LocalPath

        if (Test-Path $profileFolder) {

            Remove-Item -Path $profileFolder -Recurse -Force

            Write-Host "Deleted profile folder: $profileFolder"

        }

        

        # Increment the counter

        $deletedCount++

    } catch {

        Write-Host "Failed to delete profile: $($profile.LocalPath)"

        Write-Host "Error: $_"

    }

}



# Confirm operation completion

Write-Host "$deletedCount inactive user profiles deleted."

Write-Host "Operation complete. Now quitting..."

Start-Sleep -Seconds 10  # Pause for 10 seconds before quitting
