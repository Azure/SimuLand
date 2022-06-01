# Export AD FS Configuration via a Local Named Pipe

Locally, the AD FS WID does not have its own management user interface (UI), but one could connect to it via a specific `named pipe`.
Depending on the WID version, one could use the following named pipes to connect to the AD FS database and query its configuration settings:

* **WID 2008**: `\\.\pipe\MSSQL$MICROSOFT##SSEE\sql\query`
* **WID 2012+**: `\\.\pipe\MICROSOFT##WID\tsql\query`

![](../../../../images/labs/GoldenSAML/exportADFSConfiguration/2021-06-01_export_adfs_configuration_named_pipe.jpg)

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

### Get Database Connection String via WMI Class

The named pipe information can be obtained directly from the `ConfigurationDatabaseConnectionString` property of the `SecurityTokenService` class from the WMI `ADFS namespace`.

1.  Connect to the AD FS server via the [Azure Bastion service](../../../../environments/_helper-docs/connectAzVmAzBastion.md) as the AD FS service account.
2.  Open PowerShell and run the following commands:

```PowerShell
$ADFS = Get-WmiObject -Namespace root/ADFS -Class SecurityTokenService
$conn = $ADFS.ConfigurationDatabaseConnectionString
$conn
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_02_get_database_string_wmi_class.png)

### Connect to the Database and Read Configuration

3. Use the connection string to connect to the AD FS database (WID) and run a SQL `SELECT` statement to export its configuration settings from the `IdentityServerPolicy.ServiceSettings` table.

```PowerShell
$SQLclient = new-object System.Data.SqlClient.SqlConnection -ArgumentList $conn
$SQLclient.Open()
$SQLcmd = $SQLclient.CreateCommand()
$SQLcmd.CommandText = "SELECT ServiceSettingsData from IdentityServerPolicy.ServiceSettings"
$SQLreader = $SQLcmd.ExecuteReader()
$SQLreader.Read() | Out-Null
$settings=$SQLreader.GetTextReader(0).ReadToEnd()
$SQLreader.Dispose()
$settings
```

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_03_get_database_configuration.png)

## Detection

### Detect Named Pipe Connection

The connection to the AD FS database occurs via the `\\.\pipe\microsoft##wid\tsql\query` named pipe, and we could monitor for the connection to it with `Sysmon Event ID 18 (Pipe Connected)`.

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_04_event_sample.png)

#### Azure Sentinel Detection Rules

* [AD FS Database Named Pipe Connection Rule](https://github.com/Azure/Azure-Sentinel/blob/master/Detections/SecurityEvent/ADFSDBNamedPipeConnection.yaml)

### Detect AD FS SQL Statement to Export Service Settings

If we want to monitor for anyone interacting with the WID database via SQL statements, we would need to [create a server audit and database audit specification](https://docs.microsoft.com/en-us/sql/relational-databases/security/auditing/create-a-server-audit-and-database-audit-specification?view=sql-server-ver15). We can use the [Microsot SQL Server PowerShell module](https://docs.microsoft.com/en-us/powershell/module/sqlserver/?view=sqlserver-ps) to connect to the database and create audit rules.

**Create SQL Audit Rules**:

1.  On the AD FS server (ADFS01), open PowerShell as Administrator.
2.  Install the SqlServer PowerShell Module.

```PowerShell
Install-Module -Name SqlServer
Import-module SqlServer
```

3.  Create SQL Audit Rules.

```PowerShell
Invoke-SqlCmd -ServerInstance '\\.\pipe\microsoft##wid\tsql\query' -Query "
USE [master]
GO
CREATE SERVER AUDIT [ADFS_AUDIT_APPLICATION_LOG] TO APPLICATION_LOG WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)
GO
ALTER SERVER AUDIT [ADFS_AUDIT_APPLICATION_LOG] WITH (STATE = ON)
GO
USE [ADFSConfigurationV4]
GO
CREATE DATABASE AUDIT SPECIFICATION [ADFS_SETTINGS_ACCESS_AUDIT] FOR SERVER AUDIT [ADFS_AUDIT_APPLICATION_LOG] ADD (SELECT, UPDATE ON OBJECT::[IdentityServerPolicy].[ServiceSettings] BY [public])
GO
ALTER DATABASE AUDIT SPECIFICATION [ADFS_SETTINGS_ACCESS_AUDIT] WITH (STATE = ON)
GO
"
```

4.  Validate SQL Audit rule by running previous simulation steps either as the AD FS service account or local administrator:
* [Get Database Connection String via WMI Class](#get-database-connection-string-via-wmi-class)
* [Connect to database and run SQL statement to read configuration](#connect-to-database-and-run-sql-statement-to-read-configuration)

![](../../../../images/labs/goldemsaml/exportADFSTokenSigningCertificate/2021-05-19_04_adfs_sql_event_sample.png)

#### Azure Sentinel Hunting Queries

* [AD FS Database Local SQL Statements Rule](https://github.com/Azure/Azure-Sentinel/blob/master/Hunting%20Queries/SecurityEvent/ADFSDBLocalSqlStatements.yaml)

## Output

* AD FS Configuration Settings

## References

* [Exporting ADFS certificates revisited: Tactics, Techniques and Procedures (o365blog.com)](https://o365blog.com/post/adfs/)
* [The Role of the AD FS Configuration Database | Microsoft Docs](https://docs.microsoft.com/en-us/windows-server/identity/ad-fs/technical-reference/the-role-of-the-ad-fs-configuration-database)
* [Create a server audit and database audit specification](https://docs.microsoft.com/en-us/sql/relational-databases/security/auditing/create-a-server-audit-and-database-audit-specification?view=sql-server-ver15)
* [SQL Server Audit Action Groups and Actions](https://docs.microsoft.com/en-us/sql/relational-databases/security/auditing/sql-server-audit-action-groups-and-actions?view=sql-server-ver15)