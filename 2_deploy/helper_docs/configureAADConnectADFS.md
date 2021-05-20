# Configure Azure AD Connect: ADFS

## Pre-Requirements
* [Microsoft 365 E5 License](../../1_prepare/startM365E5Trial.md)
* [Custom domain added to Microsoft 365](../../1_prepare/addDomainToM365.md).
* Active Directory Domain Controller and Active Directory Federation Services (AD FS) Server
    * Azure Bastion set up.

## Configure Azure AD Connect
1.	Connect to Domain Controller [via Azure Bastion](connectAzVmAzBastion.md)
2.	Double click on the Azure AD connect icon on the desktop to start the setup process.
3.	Agree to the license terms and privacy notice and continue.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_01_welcome_to_aad_connect.png)

4.	Click on the `Customize` option.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_02_aad_connect_customize.png)

5.	Keep the defaults and click on `Install`.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_03_install_required_components.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_04_install_required_components.png)

6.	Select `Federation with AD FS`. We are going to use the `on-prem` AD FS server as the identity provider to handle federation services.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_05_user_sign_in.png)

7.	Enter Azure AD Global Admin creds
 
![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_06_connect_to_aad.png)
 
![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_07_connect_to_aad.png)

8.	Connect `on-prem` forest. Verify the Forest name and click on `Add Directory`.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_08_connect_directories.png)

9.	Select the first option to create a new AD account. You have to enter the credentials of a domain admin in the `on-prem` environment.
 
![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_09_ad_forest_account.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_10_ad_forest_account.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_11_ad_connect_directories.png)

10.	Keep the defaults and click `Next`.
 
![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_12_aad_sign_in_configuration.png)

11.	Select specific domains and OUS. Select Users OU and click `Next`.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_13_domain_and_ou_filtering.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_14_domain_and_ou_filtering.png)

12.	Keep the defaults and click `Next`.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_15_identify_users.png)

13.	Keep the defaults and click `Next`. Synchronize all users and devices.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_16_filter_users_and_devices.png)

14.	Keep the defaults and click `Next`.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_17_optional_features.png)

15.	Enter the credentials of a domain admin in the `on-prem` environment.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_18_domain_admin_credentials.png)

16.	Choose `Use an existing AD FS farm`

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_19_adfs_farm.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_20_adfs_farm.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_21_select_federation_server.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_22_adfs_farm.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_23_adfs_farm.png)

17.	Select the Azure AD domain to federate and click `Next`.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_24_aad_domain.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_25_aad_domain.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_26_ready_to_configure.png)

18.	Keep the defaults and click `Install`.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_27_ready_to_configure.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_28_configuring.png)

19.	After the Azure AD Connect configuration succeeds, click `Next` to verify the federation settings.
 
![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_29_configuration_complete.png)

20.	keep the defaults for now and verify federation connectivity from the intranet. Click `Verify`.

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_30_verify_federation_connectivity.png)

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_31_verify_federation_connectivity.png)

21.	That’s it! Click “Exit”

## Verify Federated Access

### Azure AD Connect
1.	Browse to [Azure portal](https://portal.azure.com/)
2.	Azure AD > Azure AD Connect

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_32_verify_aad_connect.png)

### Azure AD Custom Domains
1.	Browse to [Azure portal](https://portal.azure.com/)
2.	Azure AD > Custom Domain Names

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_33_verify_aad_custom_domains.png)

### Microsoft 365 Active Users
1.	Browse to [Microsoft 365 Admin portal](https://admin.microsoft.com/)
2.	Users > Active Users

![](../../resources/images/deploy/helper_docs/configureAADConnectADFS/2021-05-19_34_verify_m365_active_users.png)
