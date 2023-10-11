<#
.Synopsis
Automatically creates Linux user accounts.
.DESCRIPTION
Creates a Linux user record in AD, generates a random password, adds to default groups. User will require an RSA token to authenticate onto Linux systems.
The user must have a signed RSA token form and a verified SAAR-N form prior to processing the account or issuing a token. Please refer to the SOP document:
Linux Account & Token Process for additional details. Adjusting for other domains will require the $ouPath and $domainName variables, as well as the $accountGroups
array be changed based on your specific domain configurations and user group requirements.
#>

# Set OU and domain name
$ouPath = "OU=PATH,OU=TO,OU=LINUX,OU=ACCOUNTS,DC=YOUR,DC=DOMAIN,DC=NAME"
$domainName = 'domain.com'

# Set user groups
$accountGroups = @(
    ''
    ''
    ''
)

# Initialize user input status variable
$validInput = $false

# Prompt user until valid input is provided
while (-not $validInput) {
    # Prompt for user input
    $firstName  = Read-Host "Enter the user's first name"
    $lastName   = Read-Host "Enter the user's last name"

    # Format input data display name and account name
    $displayName = "$lastName, $firstName (Lin)"
    $linName = $firstName.ToLower() + "." + $lastName.ToLower() + ".lin"

    # Verify account name passes RSA character limitation
    $checkName = $linName.Length
    if ($checkName -gt 20) {
            Write-Host "ERROR: Desired account name has failed the character limitation check, account names must not exceed 20 characters"
    } else {
        Write-Host "Desired account name passes character limitation check, proceeding..."
        $validInput = $true
    }
}

# Verify user does not currently exist in AD
$checkUser = Get-ADUser -Filter {SamAccountName -eq $linName}

if ($null -ne $checkUser) {
    Write-Host "ERROR: User currently exists in Active Directory"
    Write-Host "Exiting program..."
    Start-Sleep -Seconds 1
    exit 2
} else {
    Write-Host "Desired account name passes AD check, proceeding..."
    Start-Sleep -Seconds 1
}

# Generate a random 15 digit password for the user, can't be bothered to make this any better right now, it works
function New-RandomPassword {
    $length = 15
    $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()'
    $password = 1..$length | ForEach-Object { $characters[(Get-Random -Minimum 0 -Maximum $characters.Length)] }
    Write-Host "Password Generated: " + $password
    return -join $password
}

# Store random contents into the password variable and secure it
$password = New-RandomPassword
$securePW = ConvertTo-SecureString $password -AsPlainText -Force

# Set additional account properties, add or remove as needed
$accountProperties = @{
    Name                    = $displayName
    GivenName               = $firstName
    Surname                 = $lastName
    SamAccountName          = $linName
    UserPrincipalName       = "$linName@$domainName"
    DisplayName             = $displayName
    AccountPassword         = $securePW
    Enabled                 = $True
    Path                    = $ouPath
    Description             = "Linux User"
    PasswordNeverExpires    = $True
    CannotChangePassword    = $True
    ChangePasswordAtLogon   = $False
}

# Create the user account and add to standard groups
New-ADUser @accountProperties

if ($accountGroups.Count -gt 0) {
    foreach ($group in $accountGroups) {
        if ($group -is [string]) {
            Add-ADGroupMember -Identity $group -Members $linName
            Write-Host "User added to $group..."
        } else {
            Write-Host "Skipped adding to group: $group (Not a valid string)"
        }
    }
} else {
    Write-Host "No groups were provided for the user."
}

# Inform the admin that the account is finished and exit
Start-Sleep -Seconds 2
Write-Host "Account created successfully..."
Start-Sleep -Seconds 1
Write-Host "User's account name: $linName"
Start-Sleep -Seconds 1
Write-Host "Exiting..."
exit 0
