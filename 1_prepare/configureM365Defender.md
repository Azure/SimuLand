# Initialize Microsoft 365 Defenders Security Products Configurations

This guide focuses on configuring Microsoft 365 defender products before onboarding any device to Microsoft Defender for Endpoint (MDE) and Microsoft Defender for Identity (MDI) or connecting Azure AD applications to Microsoft Cloud App Security (MCAS).

## Pre-requirements
* [Office 365 E5 subscription](startM365E5Trial.md)
* [Microsoft 365 E5 subscription](startM365E5Trial.md)
* [Office 365 Audit Log Search enabled](enableOffice365AuditLogSearch.md)

## Configure Microsoft Cloud App Security
1.	Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/)
2.	Go to “More Resources” and click on “[Microsoft Cloud App Security](https://portal.cloudappsecurity.com/)”.

![](../resources/images/prepare/configureM365Defender/2021-05-05_01_m365_security_center_mcas.png)

3.	You will be taken to the MCAS portal: [https://portal.cloudappsecurity.com/](https://portal.cloudappsecurity.com/)  

![](../resources/images/prepare/configureM365Defender/2021-05-05_02_mcas_console.png)

4.	Click on Investigate > Connected Apps.

![](../resources/images/prepare/configureM365Defender/2021-05-05_03_mcas_connected_apps.png)

5.	click on the three dots to the right of the `Office 365` application to edit its settings. Make sure your settings look like the image below. They should be set by default.

![](../resources/images/prepare/configureM365Defender/2021-05-05_04_mcas_connect_office_365.png)

6.	Finally, click on `Connect` to connect the “Office 365 app” to MCAS.

![](../resources/images/prepare/configureM365Defender/2021-05-05_05_mcas_connect_office_365_done.png) 

You can click on the Office 365 application again and run a quick test:

![](../resources/images/prepare/configureM365Defender/2021-05-05_06_mcas_connect_office_365_test.png)

If office 365 auditing propagated properly, you should see office 365 app connected.

![](../resources/images/prepare/configureM365Defender/2021-05-05_07_mcas_connected_apps_check.png)

This is very important to do before connecting other solutions such as Azure Sentinel to collect data from MCAS.

## Configure Microsoft Defender for Identity
1.	Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/)
2.	Go to “More Resources” and click on “Azure Advanced Threat Protection”.

![](../resources/images/prepare/configureM365Defender/2021-05-05_08_m365_security_center_mdi.png)

3.	Create a new MDI instance

![](../resources/images/prepare/configureM365Defender/2021-05-05_09_mdi_console.png)

4.	You should be able to add a username and password to connect to your Active Directory Forest. These credentials are used by the MDI sensor when it is installed on an endpoint. If you have not deployed your Active Directory yet, you can still set this up.

![](../resources/images/prepare/configureM365Defender/2021-05-05_10_mdi_onboard_wait.png)

![](../resources/images/prepare/configureM365Defender/2021-05-05_11_mdi_directory_services.png)

5. Finally, you can download the MDI sensor onboarding package. Make sure you save the `Access Key` value. It will be used while installing the MDI sensor on an endpoint. Use the compressed file while deploying a lab environment.

![](../resources/images/prepare/configureM365Defender/2021-05-05_12_mdi_sensors.png)

## Configure Microsoft Defender for Endpoint
1.	Navigate to [Microsoft 365 Security Center](https://security.microsoft.com/)
2.	Go to “More Resources” and click on “[Microsoft Defender Security Center](https://securitycenter.windows.com/)”

![](../resources/images/prepare/configureM365Defender/2021-05-05_13_m365_security_center_mde.png)  

3.	You will be redirected to [https://securitycenter.windows.com/](https://securitycenter.windows.com/)  where an account will be created automatically.

![](../resources/images/prepare/configureM365Defender/2021-05-05_14_mde_create_account.png)

4.	Once your account is created, it will automatically take care of step number 3 (Set up prefereces). Click on `Start using Microsoft Defender for Endpoint` to continue.

![](../resources/images/prepare/configureM365Defender/2021-05-05_15_mde_start_using_mde.png)

![](../resources/images/prepare/configureM365Defender/2021-05-05_16_mde_onboard_endpoints_wait.png)

5. Finally, go to `Settings` > `Onboarding` to download an MDE onboarding package. Select deployment method `Local Script` and click on `Download Package`. Use the compressed file while deploying a lab environment.

![](../resources/images/prepare/configureM365Defender/2021-05-05_17_mde_onboarding_package.png)
