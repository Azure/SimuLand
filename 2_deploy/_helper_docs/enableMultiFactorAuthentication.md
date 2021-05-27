# Enable Multi-Factor Authentication

## Pre-Requirements
* [Microsoft 365 E5 License](../../1_prepare/startM365E5Trial.md)
* Azure AD active users

## Enable Multi-Factor Authentication
1.	Browse to [Microsoft 365 Admin portal](https://admin.microsoft.com/).
2.	Users > Active Users.
3.	Click on the `Multi-Factor authentication` tab.
 
![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_01_m365_active_users.png)

4.	Select user(s) and click on `Enable`. Next, click on `enable multi-factor auth`.

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_02_m365_enable_mfa.png)

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_03_m365_enable_mfa.png)

## Set up Authenticator
1.	Connect to a domain joined workstation (i.e. WORKSTATION6) [via Azure Bastion](connectAzVmAzBastion.md).
2.	Open browser, go to [https://aka.ms/MFASetup](https://aka.ms/MFASetup).
3.	Log in as the user whom you enabled MFA on.
4.	Click Next to start the set-up process.

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_04_help_us_protect_your_account.png)

5.	Follow all the steps to set up MFA with the Microsoft Authenticator application.

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_05_keep_account_secure.png)

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_06_set_up_account.png)

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_07_scan_qr_code.png)

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_08_lets_try_it_out.png)

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_09_notification_approved.png)

![](../../resources/images/deploy/helper_docs/enableMultiFactorAuthentication/2021-05-19_10_mfa_success.png)
