# Export AD FS DKM Master Key

## Overview

Even though a threat actor could access AD FS certificates from the AD FS configuration settings, they are saved as encrypted strings. AD FS certificates are encrypted using Distributed Key Manager (DKM) APIs and the DKM master key to decrypt them is stored in the domain controller. When the primary AD FS farm is configured, the AD FS DKM container is created in the domain controller and the DKM master key is stored as an attribute of an AD contact object located inside of the container.

## Technique Variations

A threat actor could obtain the AD FS DKM master key in the following ways:

| Variation | Description |
| --- | --- |
| [LDAP Queries](exportADFSDKMKeyLDAP.md) | A threat actor could directly access the AD object that contains the AD FS DKM master key via LDAP queries. |
| [Directory Replication Service (DRS) Remote Protocol](exportADFSDKMKeyDRS.md) | A threat actor could indirectly access the AD object that contains the AD FS DKM master key via [Directory Replication service (DRS)](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-drsr/06205d97-30da-4fdc-a276-3fd831b272e0). A technique known as DCSync. |