# Prepare

Documents to prepare before deploying a lab environment. Some environments contributed through this initiative require at least a Microsoft 365 E5 license (paid or trial) and an Azure tenant. Documents in this folder are referenced in the right order, depending on the deployment, in the [2_deploy](../2_deploy) documents. 

| Document | Description |
|----------|-------------|
| [Start Microsoft 365 E5 Trial](addDomainToM365.md) | Sign up for Office 365 and Microsoft 365 E5 subscriptions. A Microsoft 365 E5 license can only be added to an existing Azure tenant. Therefore, it is important to first get an Office 365 E5 subscription to create an Azure tenant. |
| [Get an Azure Subscription](m365TenantGetAzSubscription.md) | Even though you already have a Microsoft 365 subscription with an Azure AD tenant, you will not be able to create resources in Azure. You need to sign up for an Azure subscription. |
| [Add Domain to Microsoft 365 Tenant](addDomainToM365.md) | Add registered custom domains to a Microsoft 365 tenant. Required when syncing "on-prem" Active Directory resources to Azure AD |
| [Enable Office 365 Audit Log Search](enableOffice365AuditLogSearch.md) | Office 365 auditing needs to be enabled before configuring Microsoft Cloud App Security (MCAS) or connecting other solutions such as Azure Sentinel data connectors to it. |
| [Configure Microsoft 365 Defender Security Products](configureM365Defender.md) | This guide focuses on configuring Microsoft 365 defender products before onboarding any device to Microsoft Defender for Endpoint (MDE) and Microsoft Defender for Identity (MDI) or connecting Azure AD applications to Microsoft Cloud App Security (MCAS). |
| [Get a trusted CA signed SSL certificate](getTrustedCASignedSSLCertificate.md) | Create a certificate signing request (CSR) to request a SSL certificate from a Certificate Authority (CA). Activate, install and export the new certificate. Simulating a federated trust between an “on-prem” environment and a Microsoft 365 Azure AD tenant requires an Active Directory Federation Services (AD FS) server with a trusted CA Signed SSL Certificate. |
| [Create Azure Storage private container](createPrivateContainerUploadFile) | Create an Azure storage account and a private container to host private files used during the deployment of a network environment. |
