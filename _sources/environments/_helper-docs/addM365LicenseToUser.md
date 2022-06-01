# Add Microsoft 365 E5 License to User

## Pre-Requirements
* [Microsoft 365 E5 License](startM365E5Trial.md)
* Azure AD active users

## Update User’s License
1.	Browse to [Microsoft 365 Admin portal](https://admin.microsoft.com/)
2.	Users > Active Users
3.	Click on a user > `Licenses and Apps` > `Microsoft 365 E5 License`

![](../../images/deploy/helper_docs/addM365LicenseToUser/2021-05-19_01_m365_active_users.png)

4.	Make sure `Exchange Onlin`e and `Microsoft 365 Advanced Auditing` apps are selected by default. When you assign a license for Exchange Online, a mailbox is automatically created for the user.
5.	Click save changes.

![](../../images/deploy/helper_docs/addM365LicenseToUser/2021-05-19_02_m365_active_users.png)

6.	You can validate this change by going to Billing > Licenses > Microsoft 365 E5

![](../../images/deploy/helper_docs/addM365LicenseToUser/2021-05-19_03_m365_validate_user_license.png)