# Export AD FS Certificates

## Overview

Federation servers require token-signing certificates to prevent attackers from altering or counterfeiting security tokens to gain unauthorized access to Federated resources. The AD FS certificates (token signing and decryption) are stored in the AD FS database configuration, and they are encrypted using Distributed Key Manager (DKM) APIs. DKM is a client-side functionality that uses a set of secret keys to encrypt and decrypt information. Only members of a specific security group in Active Directory Domain Services (AD DS) can access those keys in order to decrypt the data that is encrypted by DKM.

when the primary AD FS farm is configured, an AD container (AD FS DKM container) is created in the domain controller and the DKM master key is stored as an attribute of an AD contact object located inside of the container. The AD FS DKM master key can then be used to derive a symmetric key and decrypt AD FS certificates.

## Technique Variations

A threat actor could decrypt and export AD FS certificates in the following ways:

| Variation | Description |
| --- | --- |
| [AD FS DKM Master Key](exportADFSCertsDKMKey.md) | A threat actor could use the `AD FS DKM master key` retrieved from the domain controller to derive a key that can be used to decrypt AD FS certificate. |
