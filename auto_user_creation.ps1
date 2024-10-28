# Active Directory User and Group Management Script

# Define the password for all users
$password = ConvertTo-SecureString "Jeleel_Dev11" -AsPlainText -Force
# This line sets a secure password for all users by converting the plain text password into a secure string.

# Define user details with creative names and new prefixes
$users = @(
    @{FirstName="Finance"; LastName="Guru F1"; Username="testuserf1"; Group="FinanceDept"},
    @{FirstName="Finance"; LastName="Expert F2"; Username="testuserf2"; Group="FinanceDept"},
    @{FirstName="Sales"; LastName="Champion S1"; Username="testusers1"; Group="SalesDept"},
    @{FirstName="Sales"; LastName="Ace S2"; Username="testusers2"; Group="SalesDept"},
    @{FirstName="IT Support"; LastName="Techie I1"; Username="testuseri1"; Group="ITSupportDept"},
    @{FirstName="IT Support"; LastName="Whiz I2"; Username="testuseri2"; Group="ITSupportDept"},
    @{FirstName="Service Support"; LastName="Helper C1"; Username="testuserc1"; Group="CustomerServiceDept"},
    @{FirstName="Service Support"; LastName="Assistant C2"; Username="testuserc2"; Group="CustomerServiceDept"},
    @{FirstName="Logistics"; LastName="Mover L1"; Username="testuserl1"; Group="LogisticsDept"},
    @{FirstName="Logistics"; LastName="Shaker L2"; Username="testuserl2"; Group="LogisticsDept"},
    @{FirstName="Guest"; LastName="Visitor G1"; Username="testuserg1"; Group="GuestPC"},
    @{FirstName="Guest"; LastName="Guest G2"; Username="testuserg2"; Group="GuestPC"},
    @{FirstName="Maintenance"; LastName="Guy M1"; Username="testuserm1"; Group="ITMaintenanceDept"},
    @{FirstName="Maintenance"; LastName="Lady M2"; Username="testuserm2"; Group="ITMaintenanceDept"},
    @{FirstName="Production"; LastName="Worker P1"; Username="testuserp1"; Group="ProductionDept"},
    @{FirstName="Production"; LastName="Operator P2"; Username="testuserp2"; Group="ProductionDept"}
)
# This array contains user details, including first name, last name, username, and the group they belong to.

# Define the groups
$groups = @(
    @{Name="SalesDept"; OU="OU=Lagos-Specific,OU=userGroups,OU=Home,DC=hybridhub,DC=local"},
    @{Name="ITSupportDept"; OU="OU=Lagos-Specific,OU=userGroups,OU=Home,DC=hybridhub,DC=local"},
    @{Name="CustomerServiceDept"; OU="OU=Lagos-Specific,OU=userGroups,OU=Home,DC=hybridhub,DC=local"},
    @{Name="ProductionDept"; OU="OU=HQ-Tokyo-Specific,OU=userGroups,OU=Home,DC=hybridhub,DC=local"},
    @{Name="GuestPC"; OU="OU=HQ-Tokyo-Specific,OU=userGroups,OU=Home,DC=hybridhub,DC=local"},
    @{Name="LogisticsDept"; OU="OU=HQ-Tokyo-Specific,OU=userGroups,OU=Home,DC=hybridhub,DC=local"},
    @{Name="FinanceDept"; OU="OU=HQ-Tokyo-Specific,OU=userGroups,OU=Home,DC=hybridhub,DC=local"},
    @{Name="ITMaintenanceDept"; OU="OU=HQ-Tokyo-Specific,OU=userGroups,OU=Home,DC=hybridhub,DC=local"}
)
# This array defines the groups and their respective Organizational Units (OUs).

# Create the groups if they do not exist
foreach ($group in $groups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$($group.Name)'" -SearchBase $group.OU -ErrorAction SilentlyContinue)) {
        try {
            New-ADGroup -Name $group.Name -GroupScope Global -Path $group.OU -GroupCategory Security
            Write-Host "Successfully created group: $($group.Name)"
        } catch {
            Write-Host "Failed to create group: $($group.Name) - $($_.Exception.Message)"
        }
    } else {
        Write-Host "Group $($group.Name) already exists."
    }
}
# This loop checks if each group exists and creates it if it doesn't. It logs the success or failure of each group creation.

# Define the OU path for users
$userOU = "OU=UserPool-Uncut,OU=General,OU=userGroups,OU=Home,DC=hybridhub,DC=local"
# This sets the Organizational Unit (OU) path where users will be created.

# Loop to delete existing users, create new users, and add them to groups
foreach ($user in $users) {
    $userPrincipalName = "$($user.Username)@hybridhub.local"

    # Delete existing user if it exists
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($user.Username)'" -ErrorAction SilentlyContinue
    if ($existingUser) {
        Remove-ADUser -Identity $existingUser -Confirm:$false
        Write-Host "Deleted existing user: $($user.Username)"
    }

    try {
        New-ADUser -Name "$($user.FirstName) $($user.LastName)" `
                   -GivenName $user.FirstName `
                   -Surname $user.LastName `
                   -SamAccountName $user.Username `
                   -UserPrincipalName $userPrincipalName `
                   -Path $userOU `
                   -AccountPassword $password `
                   -Enabled $true `
                   -PasswordNeverExpires $true `
                   -ChangePasswordAtLogon $false

        Add-ADGroupMember -Identity $user.Group -Members $user.Username
        Write-Host "Successfully created user: $($user.Username) and added to group: $($user.Group)"
    } catch {
        Write-Host "Failed to create user: $($user.Username) or add to group: $($user.Group) - $($_.Exception.Message)"
    }
}
# This loop performs the following actions for each user:
# - Deletes the user if they already exist.
# - Creates a new user with the specified details.
# - Adds the user to the appropriate group.
# - Logs the success or failure of each operation.
