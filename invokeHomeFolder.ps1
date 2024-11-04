# Define the base path for the shared home folder
$basePath = "\\DC-01\all_userhomefolder_rw$"

# List of usernames for which home folders need to be created
$usernames = @(
    "testuserf1",
    "testuserf2",
    "testusers1",
    "testusers2",
    "testuseri1",
    "testuseri2",
    "testuserp1",
    "testuserp2",
    "testuserl1",
    "testuserl2",
    "testuserg1",
    "testuserg2",
    "testuserm1",
    "testuserm2",
    "testuserpr1",
    "testuserpr2",
    "remoteadmin1"
)

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
