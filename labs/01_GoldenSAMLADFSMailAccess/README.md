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

Furthermore, with the new SAML token, request an access token to the Microsoft Graph API and grant delegated permissions and add credentials (password) to an Azure AD application.

### 3. Request Access Token with SAML Token - (Valid Accounts: Cloud Accounts – T1078.004)

Follow the next steps to simulate a threat actor getting an access token for the Microsoft Graph API using the Azure Active Directory PowerShell application as a client app. That application has the right permissions to perform the next two steps.

[Request Access Token with SAML Token Steps](../../3_simulate_detect/persistence/getAccessTokenSAMLBearerAssertionFlow.md)

### 4. Grant OAuth permissions to Application - (Account Manipulation: Exchange Email Delegate Permissions - T1098.002)

Next, use the new access token to simulate a threat actor granting delegated `Mail.ReadWrite` permissions to an Azure AD application. This allows the threat actor to use the application to access mail data on behalf of the impersonated user. Usually, a threat actor would prefer to use an existing application that contains the desired permissions.

[Grant OAuth Permissions to Application Steps](../../3_simulate_detect/persistence/grantDelegatedPermissionsToApplication.md)

### 5. Add Credentials to OAuth Application - (Account Manipulation: Additional Cloud Credentials – T1098.001)

Once permissions have been granted, we can add credentials to the registered application. We can then use those credentials to sign in to the application on behalf of the impersonated user.

[Add credentials to OAuth Application Steps](../../3_simulate_detect/persistence/addCredentialsToApplication.md)

### 6. Request Access Token with SAML Token - (Valid Accounts: Cloud Accounts – T1078.004)

Simulate a threat actor using the new credentials to get an access token for the Azure AD app on behalf of the impersonated user.

[Request Access Token with SAML Token Steps](../../3_simulate_detect/persistence/getAccessTokenSAMLBearerAssertionFlow.md)

### Collection

### 7. Access account mailbox via Graph API

Finally, use the new access token to read mail from the mailbox of the account impersonated.

[Access account mailbox via Graph API steps](../../3_simulate_detect/collection/mailAccessDelegatedPermissions.md)

