# Retrieve all user profiles on the system

$profiles = Get-WmiObject Win32_UserProfile | Where-Object { 

    # Filter out special profiles (like system accounts)

    $_.Special -eq $false -and 

    # Include only profiles that are not currently loaded (i.e., not logged in)

    $_.Loaded -eq $false 

}



# Check if there are any profiles to delete

if ($profiles.Count -eq 0) {

    Write-Host "No inactive user profiles found."

    Write-Host "Now quitting."

    Start-Sleep -Seconds 10  # Pause for 10 seconds

    exit

}



# Initialize counter for deleted profiles

$deletedCount = 0



# Loop through each profile that meets the criteria

foreach ($profile in $profiles) {

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



    # Refresh the profile list

    $profiles = Get-WmiObject Win32_UserProfile | Where-Object { 

        $_.Special -eq $false -and 

        $_.Loaded -eq $false 

    }



    # Check if there are any profiles left to delete

    if ($profiles.Count -eq 0) {

        Write-Host "$deletedCount profile(s) deleted - no inactive profiles left."

        Write-Host "Operation complete. Now quitting..."

        Start-Sleep -Seconds 10  # Pause for 10 seconds before quitting

        exit

    }

}



# Confirm operation completion if there are still profiles left

Write-Host "$deletedCount inactive user profiles deleted."

Write-Host "Operation complete. Now quitting..."

Start-Sleep -Seconds 10  # Pause for 10 seconds before quitting

