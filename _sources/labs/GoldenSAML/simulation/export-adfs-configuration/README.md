# Export AD FS Configuration

## Overview

The AD FS configuration contains properties of the Federation Service and can be stored in either a Microsoft SQL server database or a `Windows Internal Database (WID)`. You can choose either one, but not both. The `SimuLand` project uses a `WID` as the AD FS configuration database.

The AD FS configuration settings contains sensitive information such as the AD FS token signing certificate (encrypted format) which can be exported and decrypted to sign SAML tokens and impersonate users in a hybrid environment.

## Technique Variations

A threat actor could export the configuration of an AD FS server in the following ways:

| Variation | Description |
| --- | --- |
| [Local Named Pipe Connection](exportADFSConfigLocalNamedPipe.md) | A threat actor could connect to the local AD FS database via a specific named pipe |
| [Policy Store Transfer Service](exportADFSConfigWCFPolicyStore.md) | A threat actor could use SOAP messages (XML documents) to request/sync AD FS configuration settings over a Windows Communication Foundation (WCF) service named Policy Store transfer Service from the federation primary server. |
| [Non-Public Property via .NET Reflection](exportADFSConfigDotNETReflection.md) | A threat actor could access non-public properties via .NET reflection to export the AD FS configuration. |
