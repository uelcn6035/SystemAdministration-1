# Define the path to the existing CSV file
$csvPath = "\\DC-01\Users\Administrator.DC-1\Downloads\AutoUsers_hybridhub.csv"

# Import the CSV file
$usernames = Import-Csv -Path $csvPath | Select-Object -ExpandProperty Username

# Define the base path for the shared home folder
$basePath = "\\DC-01\all_userhomefolder_rw$"

# Function to create home folders
function Create-HomeFolders {
    param (
        [string]$basePath,
        [string[]]$usernames
    )

    foreach ($username in $usernames) {
        $userFolderPath = Join-Path -Path $basePath -ChildPath $username
        try {
            New-Item -Path $userFolderPath -ItemType Directory -Force
            Write-Host "Successfully created home folder for $username at $userFolderPath"
        } catch {
            Write-Host "Failed to create home folder for $username at $userFolderPath - $($_.Exception.Message)"
        }
    }
}

# Create home folders for the users
Create-HomeFolders -basePath $basePath -usernames $usernames
