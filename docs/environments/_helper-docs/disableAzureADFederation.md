# Disable Azure Active Directory (AD) Federation

## Pre-Requirements
* Azure subscription
* Azure AD Tenant
* Permissions to disable federation from Azure AD

One of the only ways to remove the federation trust is via the Microsoft Azure AD Module for Windows PowerShell.

## Install the Microsoft Azure Active Directory Module for Windows PowerShell
1.  Open an elevated Windows PowerShell command prompt (run Windows PowerShell as an administrator).
2.  Run the following command to install the module:

```PowerShell
Install-Module MSOnline -Force
```
## Change Federation Authentication 

3.  Change Federation Authentication from Federated to Managed

```PowerShell
Set-MsolDomainAuthentication -DomainName <YourDomain.com> -Authentication managed
```

## Check Federation status

```PowerShell
Get-MsolDomainFederationSettings -DomainName <YourDomain.com>
```

## Reference
* [Connect to Microsoft 365 with PowerShell](https://docs.microsoft.com/en-us/microsoft-365/enterprise/connect-to-microsoft-365-powershell?view=o365-worldwide)
