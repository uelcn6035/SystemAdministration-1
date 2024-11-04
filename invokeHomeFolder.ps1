
# Define the URL to your script on GitHub
$scriptUrl = "https://raw.githubusercontent.com/uelcn6035/WindowsAdministration/main/invokeHomeFolder.ps1"

# Define the path to save the downloaded script
$localScriptPath = "C:\Temp\invokeHomeFolder.ps1"

# Download the script from GitHub
Invoke-WebRequest -Uri $scriptUrl -OutFile $localScriptPath

# Import the downloaded script
. $localScriptPath

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

# Create home folders for the users
Create-HomeFolders -basePath $basePath -usernames $usernames
