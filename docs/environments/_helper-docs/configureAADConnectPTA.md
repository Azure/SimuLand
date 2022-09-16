# Configure Azure AD Connect: Pass-through Authentication

## Pre-Requirements
* [Microsoft 365 E5 License](startM365E5Trial.md)
* [Custom domain added to Microsoft 365](addDomainToM365.md).
* Active Directory Domain Controller and Active Directory Federation Services (AD FS) Server
    * Azure Bastion set up.

## Configure Azure AD Connect
1.	Connect to Domain Controller [via Azure Bastion](connectAzVmAzBastion.md)
2.	Double click on the Azure AD connect icon on the desktop to start the setup process.
3.	Agree to the license terms and privacy notice and continue.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_01_aad_connect_license_terms.png)

4.	Click on the `Customize` option.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_02_aad_connect_customize.png)

5.	Keep the defaults and click on `Install`.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_03_aad_connect_install_required_components.png)

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_04_aad_connect_install_required_components.png)

6.	Select `Pass-through authentication`.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_05_aad_connect_select_pta.png)

7.	Enter Azure AD Global Admin creds
 
![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_06_aad_connect_global_admin_login.png)

8.	Connect `on-prem` forest. Verify the Forest name and click on `Add Directory`.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_07_aad_connect_onprem_directory.png)

9.	Select the first option to create a new AD account. You have to enter the credentials of a domain admin in the `on-prem` environment.
 
![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_08_aad_connect_create_new_account.png)

10.	Keep the defaults and click `Next`.

11.	Select specific domains and OUS. Select Users OU and click `Next`.

12.	Keep the defaults and click `Next`.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_09_aad_connect_identify_users.png)

13.	Keep the defaults (`Synchronize all users and devices`) and click `Next`.

14.	Keep the default `optional Features` and click `Next`.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_10_aad_connect_optional_features.png)

15.	Keep the default settings and click on `Install`.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_11_aad_connect_ready_to_configure.png)

16.	Done.

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_12_aad_connect_done.png)

17.	That’s it! Click “Exit”

## Verify PTA Connection

### Azure AD Connect
1.	Browse to [Azure portal](https://portal.azure.com/)
2.	Azure AD > Azure AD Connect

![](../../images/deploy/helper_docs/configureAADConnectPTA/2022-09-15_13_aad_connect_enabled.png)