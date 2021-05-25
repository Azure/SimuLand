# Azure AD Hybrid Identity: Stealing the AD FS Token Signing Certificate to Forge SAML Tokens and Access Mail Data

## Overview

Microsoft’s identity solutions span on-premises and cloud-based capabilities. These solutions create a common user identity for authentication and authorization to all resources, regardless of location. We call this hybrid identity and one of the authentication methods available is federation with Active Directory Services (AD FS).
In this step-by-step guide, we simulate an adversary stealing the AD FS token signing certificate, from an “on-prem” AD FS server, in order to sign SAML token, impersonate a privileged user and eventually collect mail data in a tenant via the Microsoft Graph API. This lab also focuses on showing the detection capabilities of Microsoft Defender security products and Azure Sentinel. Therefore, each simulation step is mapped to its respective alert and detection queries when possible.

## Deploy Environment
The first step is to deploy the lab environment. Use the following document to prepare and deploy the infrastructure and services required to run the simulation plan. 

[Deploy Environment Steps](../2_deploy/aadHybridIdentityADFS/README.md)

## Simulate and Detect Adversary
This simulation starts with a compromised `on-prem` AD FS Server where a threat actor managed to obtain the credentials of the AD FS service account.

### Credential Access

**Export ADFS Token Signing Certificate - (Unsecured Credentials: Private Keys - T1552.004)**

Connect to the AD FS server (ADFS01) via the [Azure Bastion service](../2_deploy/helper_docs/configureAADConnectADFS) as the AD FS service account and simulate a threat actor exporting the AD FS token signing certificate. Access the AD FS configuration database locally and read the AD FS configuration settings to get the AD FS DKM master key value from the Domain Controller (DC) and use it to decrypt the token signing certificate that is also stored in the AD FS database configuration.

[Local Export ADFS Token Signing Certificate Steps](../3_simulate_detect/credential-access/localExportADFSTokenSigningCertificate.md)

**Forge SAML Token - (Forge Web Credentials: SAML Tokens - T1606.002)**

Next, sign a new SAML token to impersonate a privileged user that could also access resources in Azure. Remember that a threat actor could sign new SAML tokens outside of the compromised organization with the stolen AD FS token signing certificate.

[Forge SAML Token Steps](../3_simulate_detect/credential-access/signSAMLToken.md)

### Persistence
Furthermore, with the new SAML token, request an access token to the Microsoft Graph API to grant delegated permissions and add credentials (password) to an Azure AD application.

**Request Access Token with SAML Token - (Valid Accounts: Cloud Accounts – T1078.004)**

Follow the next steps to simulate a threat actor getting an access token for Microsoft Graph using the Azure Active Directory PowerShell application as a client app. That application has the right permissions to perform the next two steps in this simulation exercise.

[Request Access Token with SAML Token Steps](../3_simulate_detect/persistence/getAccessTokenSAMLBearerAssertionFlow.md)

**Grant OAuth permissions to Application - (Account Manipulation: Exchange Email Delegate Permissions - T1098.002)**

Next, use the new Microsoft Graph access token to simulate a threat actor granting delegated permissions to an Azure AD application to then be able to access mail data on behalf of the impersonated user. Usually, a threat actor would prefer to use an existing application that contains the desired permissions. Grant `Mail.ReadWrite` permissions.

[Grant OAuth Permissions to Application Steps](../3_simulate_detect/persistence/grantDelegatedPermissionsToApplication.md)

**Add Credentials to OAuth Application - (Account Manipulation: Additional Cloud Credentials – T1098.001)**

Once permissions have been granted, we can add credentials to the registered application to then request another Microsoft Graph access token and use the new application permissions.

[Add credentials to OAuth Application Steps](../3_simulate_detect/persistence/addCredentialsToApplication.md)

**Request Access Token with SAML Token - (Valid Accounts: Cloud Accounts – T1078.004)**

Simulate a threat actor using the credentials added to the Azure AD application to get a Microsoft Graph access token and use the `Mail.ReadWrite` permissions to read mail from the impersonated user.

[Request Access Token with SAML Token Steps](../3_simulate_detect/persistence/getAccessTokenSAMLBearerAssertionFlow.md)

### Collection

**Access account mailbox via Graph API**

Finally, access the mail box of the impersonated user and read some messages.

[Access account mailbox via Graph API steps](../3_simulate_detect/collection/mailAccessDelegatedPermissions.md)

