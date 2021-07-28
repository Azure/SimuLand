# Azure AD Hybrid Identity: Stealing the AD FS Token Signing Certificate to Forge SAML Tokens and Access Mail Data

## Overview

Microsoft’s identity solutions span on-premises and cloud-based capabilities. These solutions create a common user identity for authentication and authorization to all resources, regardless of location. We call this hybrid identity and one of the authentication methods available is federation with Active Directory Services (AD FS).

In this step-by-step guide, we simulate an adversary stealing the AD FS token signing certificate from an `on-prem` AD FS server to sign a new SAML token, impersonate a privileged user and eventually collect mail data via the Microsoft Graph API. This lab also focuses on showing the detection capabilities of Microsoft Defender security products and Azure Sentinel. Therefore, each simulation step is mapped to its respective alert and detection queries when possible.

## Deploy Environment

The first step is to deploy the lab environment. Use the following document to prepare and deploy the infrastructure and services required to run the simulation plan. 

[Deploy Environment Steps](../../2_deploy/aadHybridIdentityADFS/README.md)

## Simulate and Detect

This simulation starts with a compromised `on-prem` AD FS Server where a threat actor managed to obtain the credentials of the AD FS service account. Connect to the AD FS server (ADFS01) via the [Azure Bastion service](../../2_deploy/_helper_docs/connectAzVmAzBastion.md) as the AD FS service account.

### Credential Access

### 1. Export ADFS Token Signing Certificate - (Unsecured Credentials: Private Keys - T1552.004)

Simulate a threat actor exporting the AD FS token signing certificate. Access the AD FS configuration database locally and remotely, read the AD FS configuration settings, export AD FS certificates in encrypted format, extract the AD FS DKM master key value from the Domain Controller and use it to decrypt the AD FS token signing certificate.

[Export ADFS Token Signing Certificate Steps](../../3_simulate_detect/credential-access/exportADFSTokenSigningCertificate.md)

### 2. Forge SAML Token - (Forge Web Credentials: SAML Tokens - T1606.002)

Next, use the stolen AD FS token signing certificate and sign a new SAML token to impersonate a privileged user that could also access resources in Azure.

[Forge SAML Token Steps](../../3_simulate_detect/credential-access/signSAMLToken.md)

### Persistence

Furthermore, with the new SAML token, request an OAuth access token to use the Microsoft Graph API in order to grant delegated permissions and add credentials (password) to an OAuth application.

### 3. Request OAuth Access Token with SAML Assertion - (Valid Accounts: Cloud Accounts – T1078.004)

Follow the next steps to simulate a threat actor getting an OAuth access token for the Microsoft Graph API using the public `Azure Active Directory PowerShell application` as a client. Use the following information while running this step:

* Client ID: `1b730954-1685-4b74-9bfd-dac224a7b894` (Azure AD PowerShell Application ID)
* Scope: `https://graph.microsoft.com/.default`

[Request OAuth Access Token with SAML Assertion Steps](../../3_simulate_detect/credential-access/getOAuthTokenWithSAMLAssertion.md)

### 4. Grant OAuth permissions to Application - (Account Manipulation: Exchange Email Delegate Permissions - T1098.002)

Next, use the OAuth token to call the Microsoft Graph API and simulate an adversary granting delegated `Mail.ReadWrite` permissions to an Azure AD application. Usually, a threat actor would prefer to use an existing application that already has the desired permissions granted. However, in this step, we simulate a threat actor updating the `Required Resource Access` property of an application and updating the `OAuthPermissionGrant` of an OAuth application to grant new delegated permissions.

[Update Application OAuth Permissions Scopes Steps](../../3_simulate_detect/persistence/updateAppOAuthPermissionScopes.md)

[Grant OAuth Permissions to Application Steps](../../3_simulate_detect/persistence/updateAppDelegatedPermissionGrant.md)

### 5. Add Credentials to OAuth Application - (Account Manipulation: Additional Cloud Credentials – T1098.001)

Once permissions have been granted, we can add new credentials to the compromised OAuth application using the same OAuth access token and via the Microsoft Graph API. We can then use those credentials to sign in to the application on behalf of the impersonated user.

[Add credentials to OAuth Application Steps](../../3_simulate_detect/persistence/addCredentialsToApplication.md)

### 6. Request OAuth Access Token with SAML Assertion - (Valid Accounts: Cloud Accounts – T1078.004)

Simulate a threat actor, once again, using the forged SAML assertion to get an OAuth access token for the Microsoft Graph API, but this time using the compromised application as a client. You must use the new credentials (`secret text`) added to it in the previous step. Use the following information while running this step:

* Client ID: `id-of-compromised-application`
* Scope: `https://graph.microsoft.com/.default`
* Client Secret: `xxxx`

[Request OAuth Access Token with SAML Assertion Steps](../../3_simulate_detect/credential-access/getOAuthTokenWithSAMLAssertion.md)

### Collection

### 7. Access account mailbox via Graph API

Finally, use the new OAuth access token to call the Microsoft Graph API and read mail from the mailbox of the signed-in user.

[Access account mailbox via Graph API steps](../../3_simulate_detect/collection/mailAccessDelegatedPermissions.md)

