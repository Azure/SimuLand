# Register Azure AD Application and Create App Service Principal

## Pre-Requirements
* Azure AD tenant
* Azure AD User with permissions to register Azure AD applications

## Register Azure AD Application

1. Browse to [Azure Portal](https://portal.azure.com/)
2. Go to Azure AD > App Registrations > New registration
3. Name your app `SimuLandApp` or anything you want. Make sure you save the name of your app somewhere. You might need it while going through some of the simulation labs.
 
![](../../images/deploy/helper_docs/registerAADAppAndSP/2021-05-19_01_aad_app_registrations.png)

![](../../images/deploy/helper_docs/registerAADAppAndSP/2021-05-19_02_aad_enterprise_apps.png)

## Check Delegated Permissions

By default, when registering a new application via the Azure portal, it will be granted the `delegated` MS Graph permission `User.Read`.

1. Browse to [Azure Portal](https://portal.azure.com/)
2. Go to Azure AD > App Registrations
3. Search for `SimuLandApp`

![](../../images/deploy/helper_docs/registerAADAppAndSP/2021-05-19_03_aad_app_registrations.png)

4. Click on `API Permissions`. You should see the `User.Read` permission under `Microsoft Graph` API

![](../../images/deploy/helper_docs/registerAADAppAndSP/2021-05-19_06_grant_admin_consent.png)

That’s it.

Applications sometimes take a few hours to show in the Microsoft Cloud App Security (MCAS) portal.
1.	Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/)
2.	Browse to `More Resources` and click on `Microsoft Cloud App Security`.
3.	Investigate > OAuth Apps

![](../../images/deploy/helper_docs/registerAADAppAndSP/2021-05-19_08_m365_macs_oauth_apps.png)