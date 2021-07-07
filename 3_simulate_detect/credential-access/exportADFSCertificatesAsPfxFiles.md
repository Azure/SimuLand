# Export Active Directory Federation Services (AD FS) Certificates as PFX Files

After decrypting AD FS certificates, you can export the cipher text to a .pfx file. Remember that this step is also performed outside of the organization. Therefore, there are not detection rules for it.

## Preconditions
* Endpoint: ADFS01 or WORKSTATION6
    * Even when this step would happen outside of the organization, we can use the same PowerShell session on one of the endpoints where we [decrypted the AD FS certificates](decryptADFSCertificates.md) and exported the `cipher text` to a variable.
    * AD FS certificates (cipher text)
        * Use the output cipher text from that previous step as the variable `$pfx` and use it in the PowerShell snippet below.

## Export AD FS Token Signing Certificate

```PowerShell
$CertificatePath = 'C:\ProgramData\ADFSTokenSigningCertificate.pfx'
$pfx | Set-Content $CertificatePath -Encoding Byte

Get-item $CertificatePath
```

![](../../resources/images/simulate_detect/credential-access/exportADFSTokenSigningCertificate/2021-05-19_28_export_certificate.png)

## Output

You can use the PFX file of the AD FS token signing certificate for the next step where we [sign our own SAML token](signSAMLToken.md) to impersonate a privileged user in a federated environment.

## References
* [Exporting ADFS certificates revisited: Tactics, Techniques and Procedures (o365blog.com)](https://o365blog.com/post/adfs/)