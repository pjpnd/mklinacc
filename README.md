# mklinacc
<h2>Description</h2>
Enterprise domains may opt to use Active Directory for both Windows and Linux as a way to manage their accounts and systems as opposed to Kerberos/LDAP. This script creates a Linux user record within Active Directory for user authentication, generates a random password for the user, and adds them to the specified groups.

<h2>Notes</h2>
This is a neutral, baseline form of the script. To function properly, run this in an elevated (admin) PowerShell session. You will need to edit the script and make changes to the following variables to suit your specifc domain and user group needs. These are at the top of the script and are easy to adjust:

- $ouPath
- $domainName
- $accountGroups

<h2>Requirements</h2>
- <a href = "https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/integrating_rhel_systems_directly_with_windows_active_directory/connecting-rhel-systems-directly-to-ad-using-sssd_integrating-rhel-systems-directly-with-active-directory"> Active Directory on RHEL </a> configured with <a href= "https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_authentication_and_authorization_in_rhel/understanding-sssd-and-its-benefits_configuring-authentication-and-authorization-in-rhel"> SSSD </a> for your RHEL system(s) 

<h2>Installation and Use</h2>
Just download the PowerShell (.ps1) script file. You don't need the entire .zip package from github. Put the <code>.ps1</code> file in a convenient location, <code>cd</code> into it, run it using <code>.\mklinacc.ps1</code> and follow the onscreen instructions.

<h2>Planned Changes</h2>

- Creating an input flag to make password randomization optional (user should be able to choose to create the account with no password, set a custom password, or have the script randomize one)
- Further input validation/sanitization on user input when parsing to $displayName
- Verify running user has admin privileges when starting the script
